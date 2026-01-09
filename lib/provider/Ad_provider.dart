import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../ads/ad_helper.dart';
import '../in_app_purchase/credit_manager.dart';

class AdProvider with ChangeNotifier {
  final CreditManager creditManager;
  // AdProvider mein ye getter add karo:
  bool get canShowRewardedAd => isRewardedAdLoaded && !_isEarningCredits;

  AdProvider({required this.creditManager});

  /// Ad states
  final Map<AdType, bool> _loaded = {
    AdType.homeAd1: false,
    AdType.homeAd2: false,
    AdType.selectionAd: false,
    AdType.historyAd: false,
    AdType.rewardedAd: false,
    AdType.shareAd: false, // Naya ad type add kiya
  };

  // Ad objects
  NativeAd? _homeAd1;
  NativeAd? _homeAd2;
  NativeAd? _selectionAd;
  NativeAd? _historyAd;
  RewardedAd? _rewardedAd;
  RewardedAd? _shareAd; // Naya rewarded ad object

  bool _isEarningCredits = false;
  bool _isLoadingShareAd = false; // Share ad loading state

  /// Public getters
  bool get isHomeAd1 => _loaded[AdType.homeAd1]!;
  bool get isHomeAd2 => _loaded[AdType.homeAd2]!;
  bool get isSelectionAd => _loaded[AdType.selectionAd]!;
  bool get isHistoryAd => _loaded[AdType.historyAd]!;
  bool get isRewardedAdLoaded => _loaded[AdType.rewardedAd]!;
  bool get isShareAdLoaded => _loaded[AdType.shareAd]!;
  bool get isEarningCredits => _isEarningCredits;
  bool get isLoadingShareAd => _isLoadingShareAd;

  NativeAd? get homeAd1 => _homeAd1;
  NativeAd? get homeAd2 => _homeAd2;
  NativeAd? get selectionAd => _selectionAd;
  NativeAd? get historyAd => _historyAd;

  /// Preload ad
  Future<void> preloadAd(AdType type, {dynamic adSize}) async {
    switch (type) {
      case AdType.rewardedAd:
        return _loadRewarded();
      case AdType.shareAd:
        return _loadShareAd(); // Share ad load function
      default:
        return _loadNative(type, adSize);
    }
  }

  /// Load native ads
  Future<void> _loadNative(AdType type, dynamic size) async {
    final id = _adId(type);

    final ad = NativeAd(
      adUnitId: id,
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(templateType: size),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _setState(type, true);
          _assignNative(type, ad as NativeAd);
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint("❌ [Ad] Native ad failed: $err");
          _setState(type, false);
          ad.dispose();
        },
      ),
    );

    await ad.load();
  }

  void _assignNative(AdType type, NativeAd ad) {
    switch (type) {
      case AdType.homeAd1:
        _homeAd1 = ad;
        break;
      case AdType.homeAd2:
        _homeAd2 = ad;
        break;
      case AdType.selectionAd:
        _selectionAd = ad;
        break;
      case AdType.historyAd:
        _historyAd = ad;
        break;
      default:
        ad.dispose();
    }
  }

  /// Load share ad (specific rewarded ad)
  Future<void> _loadShareAd() async {
    if (_isLoadingShareAd) {
      debugPrint("⏳ [Ad] Already loading share ad");
      return;
    }

    try {
      _isLoadingShareAd = true;
      notifyListeners();

      debugPrint("📺 [Ad] Loading share ad...");

      await RewardedAd.load(
        adUnitId: AdHelper.getRewarded('shareAd'), // Share ad ID
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint("✅ [Ad] Share ad loaded");
            _shareAd = ad;
            _setState(AdType.shareAd, true);
            _isLoadingShareAd = false;
            notifyListeners();
          },
          onAdFailedToLoad: (err) {
            debugPrint("❌ [Ad] Share ad failed: $err");
            _setState(AdType.shareAd, false);
            _isLoadingShareAd = false;
            notifyListeners();
          },
        ),
      );
    } catch (e) {
      debugPrint("❌ [Ad] Share ad error: $e");
      _isLoadingShareAd = false;
      notifyListeners();
    }
  }

  /// Load general rewarded ad
  Future<void> _loadRewarded() async {
    if (_isEarningCredits) {
      debugPrint("⏳ [Ad] Already loading rewarded ad");
      return;
    }

    try {
      _isEarningCredits = true;
      notifyListeners();

      debugPrint("📺 [Ad] Loading rewarded ad...");

      await RewardedAd.load(
        adUnitId: AdHelper.getRewarded('generateAd'), // Generate ad ID
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint("✅ [Ad] Rewarded ad loaded");
            _rewardedAd = ad;
            _setState(AdType.rewardedAd, true);
            _isEarningCredits = false;
            notifyListeners();
          },
          onAdFailedToLoad: (err) {
            debugPrint("❌ [Ad] Rewarded ad failed: $err");
            _setState(AdType.rewardedAd, false);
            _isEarningCredits = false;
            notifyListeners();
          },
        ),
      );
    } catch (e) {
      debugPrint("❌ [Ad] Rewarded ad error: $e");
      _isEarningCredits = false;
      notifyListeners();
    }
  }

  /// Show share ad for credits
  Future<bool> showShareAdForCredits() async {
    if (_shareAd == null) {
      debugPrint("⚠️ [Ad] Share ad not loaded");
      return false;
    }

    try {
      bool earnedCredits = false;

      _shareAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          debugPrint("📺 [Ad] Share ad showed");
        },
        onAdDismissedFullScreenContent: (ad) {
          debugPrint("👋 [Ad] Share ad dismissed");
          ad.dispose();
          _shareAd = null;
          _setState(AdType.shareAd, false);
          // Preload next share ad
          _loadShareAd();
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          debugPrint("❌ [Ad] Failed to show share ad: $err");
          ad.dispose();
          _shareAd = null;
          _setState(AdType.shareAd, false);
        },
      );

      await _shareAd!.show(
        onUserEarnedReward: (ad, reward) async {
          debugPrint("🎁 [Ad] User earned reward from share ad!");

          // Add credits
          final success = await creditManager.rewardForAd();

          if (success) {
            earnedCredits = true;
            debugPrint("✅ [Ad] Added ${CreditManager.rewardedAdCredits} credits");
          }
        },
      );

      return earnedCredits;
    } catch (e) {
      debugPrint("❌ [Ad] Show share ad error: $e");
      return false;
    }
  }

  /// Show general rewarded ad for credits
  Future<bool> showRewardedAdForCredits() async {
    if (_rewardedAd == null) {
      debugPrint("⚠️ [Ad] Rewarded ad not loaded");
      return false;
    }

    try {
      bool earnedCredits = false;

      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          debugPrint("📺 [Ad] Rewarded ad showed");
        },
        onAdDismissedFullScreenContent: (ad) {
          debugPrint("👋 [Ad] Rewarded ad dismissed");
          ad.dispose();
          _rewardedAd = null;
          _setState(AdType.rewardedAd, false);
          // Preload next ad
          _loadRewarded();
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          debugPrint("❌ [Ad] Failed to show: $err");
          ad.dispose();
          _rewardedAd = null;
          _setState(AdType.rewardedAd, false);
        },
      );

      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) async {
          debugPrint("🎁 [Ad] User earned reward!");

          // Add credits
          final success = await creditManager.rewardForAd();

          if (success) {
            earnedCredits = true;
            debugPrint("✅ [Ad] Added ${CreditManager.rewardedAdCredits} credits");
          }
        },
      );

      return earnedCredits;
    } catch (e) {
      debugPrint("❌ [Ad] Show rewarded ad error: $e");
      return false;
    }
  }

  /// Helpers
  void _setState(AdType type, bool value) {
    _loaded[type] = value;
    notifyListeners();
  }

  String _adId(AdType type) {
    switch (type) {
      case AdType.homeAd1:
        return AdHelper.getNative('homeAd1');
      case AdType.homeAd2:
        return AdHelper.getNative('homeAd2');
      case AdType.selectionAd:
        return AdHelper.getNative('selectionAd');
      case AdType.historyAd:
        return AdHelper.getNative('historyAd');
      case AdType.rewardedAd:
        return AdHelper.getRewarded('generateAd');
      case AdType.shareAd:
        return AdHelper.getRewarded('shareAd');
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _homeAd1?.dispose();
    _homeAd2?.dispose();
    _selectionAd?.dispose();
    _historyAd?.dispose();
    _rewardedAd?.dispose();
    _shareAd?.dispose();
    super.dispose();
  }
}

enum AdType {
  homeAd1,
  homeAd2,
  selectionAd,
  historyAd,
  rewardedAd,
  shareAd,
}