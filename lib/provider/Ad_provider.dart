import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../ads/ad_helper.dart';
import '../in_app_purchase/credit_manager.dart';

class AdProvider with ChangeNotifier {
  final CreditManager creditManager;

  AdProvider({required this.creditManager});

  // ============ GENERATE SCREEN ADS ============
  NativeAd? _generateNativeAd;
  bool _isGenerateNativeAdLoaded = false;

  // ============ HISTORY SCREEN ADS ============
  NativeAd? _historyNativeAd;
  bool _isHistoryNativeAdLoaded = false;

  // ============ REWARDED ADS (Shared across app) ============
  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoaded = false;
  bool _isLoadingRewardedAd = false;

  // ============ PUBLIC GETTERS ============

  // Generate Screen getters
  bool get isGenerateNativeAdLoaded => _isGenerateNativeAdLoaded;
  NativeAd? get generateNativeAd => _generateNativeAd;

  // History Screen getters
  bool get isHistoryNativeAdLoaded => _isHistoryNativeAdLoaded;
  NativeAd? get historyNativeAd => _historyNativeAd;

  // Rewarded Ad getters
  bool get isRewardedAdLoaded => _isRewardedAdLoaded;
  bool get isLoadingRewardedAd => _isLoadingRewardedAd;

  // ============ LOAD NATIVE ADS ============

  /// Load Native Ad for Generate Screen
  Future<void> loadGenerateNativeAd(TemplateType templateType) async {
    _generateNativeAd?.dispose();
    _generateNativeAd = null;
    _isGenerateNativeAdLoaded = false;
    notifyListeners();

    /*
    final ad = NativeAd(
      adUnitId: AdHelper.getNative(),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(templateType: templateType),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          debugPrint("✅ [Ad] Generate Native ad loaded");
          _generateNativeAd = ad as NativeAd;
          _isGenerateNativeAdLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint("❌ [Ad] Generate Native ad failed: $err");
          ad.dispose();
          _isGenerateNativeAdLoaded = false;
          notifyListeners();
        },
      ),
    );

    await ad.load();
    */
  }

  /// Load Native Ad for History Screen
  Future<void> loadHistoryNativeAd(TemplateType templateType) async {
    _historyNativeAd?.dispose();
    _historyNativeAd = null;
    _isHistoryNativeAdLoaded = false;
    notifyListeners();

    /*
    final ad = NativeAd(
      adUnitId: AdHelper.getNative(),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(templateType: templateType),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          debugPrint("✅ [Ad] History Native ad loaded");
          _historyNativeAd = ad as NativeAd;
          _isHistoryNativeAdLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint("❌ [Ad] History Native ad failed: $err");
          ad.dispose();
          _isHistoryNativeAdLoaded = false;
          notifyListeners();
        },
      ),
    );

    await ad.load();
    */
  }

  // ============ LOAD REWARDED ADS ============

  /// Load Rewarded Ad (Credit screen & Save button)
  Future<void> loadRewardedAd() async {
    /*
    if (_isLoadingRewardedAd) {
      debugPrint("⏳ [Ad] Already loading rewarded ad");
      return;
    }

    try {
      _isLoadingRewardedAd = true;
      notifyListeners();

      debugPrint("📺 [Ad] Loading rewarded ad...");

      await RewardedAd.load(
        adUnitId: AdHelper.getRewarded(),
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint("✅ [Ad] Rewarded ad loaded");
            _rewardedAd = ad;
            _isRewardedAdLoaded = true;
            _isLoadingRewardedAd = false;
            notifyListeners();
          },
          onAdFailedToLoad: (err) {
            debugPrint("❌ [Ad] Rewarded ad failed: $err");
            _isRewardedAdLoaded = false;
            _isLoadingRewardedAd = false;
            notifyListeners();
          },
        ),
      );
    } catch (e) {
      debugPrint("❌ [Ad] Rewarded ad error: $e");
      _isLoadingRewardedAd = false;
      notifyListeners();
    }
    */
    return;
  }

  // ============ SHOW REWARDED ADS ============

  /// Show Rewarded Ad for Credits
  Future<bool> showRewardedAdForCredits() async {
    /*
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
          _isRewardedAdLoaded = false;
          loadRewardedAd(); // Preload next ad
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          debugPrint("❌ [Ad] Failed to show: $err");
          ad.dispose();
          _rewardedAd = null;
          _isRewardedAdLoaded = false;
        },
      );

      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) async {
          debugPrint("🎁 [Ad] User earned reward!");
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
    */
    return false;
  }

  /// Show Rewarded Ad (Save Button - No Credits)
  Future<bool> showRewardedAd() async {
    /*
    if (_rewardedAd == null) {
      debugPrint("⚠️ [Ad] Rewarded ad not loaded for save");
      return false;
    }

    try {
      bool adShown = false;

      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          debugPrint("📺 [Ad] Rewarded ad showed");
          adShown = true;
        },
        onAdDismissedFullScreenContent: (ad) {
          debugPrint("👋 [Ad] Rewarded ad dismissed");
          ad.dispose();
          _rewardedAd = null;
          _isRewardedAdLoaded = false;
          loadRewardedAd(); // Preload next ad
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          debugPrint("❌ [Ad] Failed to show: $err");
          ad.dispose();
          _rewardedAd = null;
          _isRewardedAdLoaded = false;
        },
      );

      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint("🎁 [Ad] Rewarded ad watched");
          adShown = true;
        },
      );

      return adShown;
    } catch (e) {
      debugPrint("❌ [Ad] Show rewarded ad error: $e");
      return false;
    }
    */
    return false;
  }

  @override
  void dispose() {
    _generateNativeAd?.dispose();
    _historyNativeAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }
}