import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'dart:io';
import '../in_app_purchase/credit_manager.dart';

class AdProvider with ChangeNotifier {
  final CreditManager? creditManager;
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  AdProvider({this.creditManager});

  BannerAd? get bannerAd => _bannerAd;
  bool get isBannerAdLoaded => _isBannerAdLoaded;

  String get bannerAdUnitId {
    if (kDebugMode) {
      // Use Google Test IDs in Debug Mode
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111';
      } else {
        return 'ca-app-pub-3940256099942544/2934735716';
      }
    } else {
      // Use Real IDs in Release Mode
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111'; // Still using test for android as no real provided
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3774337907915828/2562455201'; // Real ios banner ad id
      }
    }
    return '';
  }

  Future<void> initialize() async {
    // Initializing MobileAds happens in main.dart as per user's logic
    loadBannerAd();
  }

  void loadBannerAd() {
    print('📱 AdProvider: Starting to load Banner Ad...');
    print('📱 AdProvider: Ad Unit ID: $bannerAdUnitId');
    
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('✅ AdProvider: Banner Ad Loaded Successfully!');
          _isBannerAdLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          print('❌ AdProvider: Banner Ad Failed to Load!');
          print('❌ Error Code: ${error.code}');
          print('❌ Error Message: ${error.message}');
          print('❌ Error Domain: ${error.domain}');
          
          ad.dispose();
          _isBannerAdLoaded = false;
          notifyListeners();
        },
        onAdOpened: (ad) => print('📱 AdProvider: Ad Opened'),
        onAdClosed: (ad) => print('📱 AdProvider: Ad Closed'),
        onAdImpression: (ad) => print('📱 AdProvider: Ad Impression Recorded'),
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
