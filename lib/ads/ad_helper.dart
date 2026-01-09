/*import 'package:flutter/foundation.dart';

class AdHelper {
  /// REAL Ad IDs (iOS) — You will fill these later
  static const Map<String, String> _realAds = {
    // Rewarded Ads
    'generateAd': 'ca-app-pub-3774337907915828/2754026899',
    'saveAd': 'ca-app-pub-3774337907915828/6349850495',
    'shareAd': 'ca-app-pub-3774337907915828/8976013830',

    // Native Ads
    'homeAd1': 'ca-app-pub-3774337907915828/2562455201',
    'homeAd2': 'ca-app-pub-3774337907915828/6477649485',
    'selectionAd': 'ca-app-pub-3774337907915828/6780083571',
    'historyAd': 'ca-app-pub-3774337907915828/2486627100',
  };

  /// Google Test Ads (SAFE for debug)
  static const Map<String, String> _testAds = {
    'native': 'ca-app-pub-3940256099942544/3986624511',
    'rewarded': 'ca-app-pub-3940256099942544/1712485313'
  };

  /// Test ads only in debug mode (recommended)
  //static bool get useTestAds => kDebugMode;
  static bool get useTestAds => false;

  /// Native Ad getter
  static String getNative(String name) {
    return useTestAds ? _testAds['native']! : _realAds[name]!;
  }

  /// Rewarded Ad getter
  static String getRewarded(String name) {
    return useTestAds ? _testAds['rewarded']! : _realAds[name]!;
  }
}*/

import 'package:flutter/foundation.dart';

class AdHelper {

  static const Map<String, String> ads = {
    // Rewarded Ads
    'generateAd': 'ca-app-pub-3774337907915828/2754026899',
    'saveAd': 'ca-app-pub-3774337907915828/6349850495',
    'shareAd': 'ca-app-pub-3774337907915828/8976013830',

    // Native Ads
    'homeAd1': 'ca-app-pub-3774337907915828/2562455201',
    'homeAd2': 'ca-app-pub-3774337907915828/6477649485',
    'selectionAd': 'ca-app-pub-3774337907915828/6780083571',
    'historyAd': 'ca-app-pub-3774337907915828/2486627100',
  };

  // /// Google Test Ads (SAFE for debug)
  // static const Map<String, String> _testAds = {
  //   'native': 'ca-app-pub-3940256099942544/3986624511',
  //   'rewarded': 'ca-app-pub-3940256099942544/1712485313'
  // };

  /// Test ads only in debug mode (recommended)
  //static bool get useTestAds => kDebugMode;

  static String getNative(String name) {
    return ads[name]!;
  }

  /// Rewarded Ad getter
  static String getRewarded(String name) {
    return ads[name]!;
  }
}