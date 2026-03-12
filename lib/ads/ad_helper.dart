

import 'package:flutter/foundation.dart';

class AdHelper {
  // Single Native Ad ID - used everywhere (home, history, all screens)
  static const String nativeAdId = 'ca-app-pub-3774337907915828/2562455201';

  // Single Rewarded Ad ID - used everywhere (credit screen, save button)
  static const String rewardedAdId = 'ca-app-pub-3774337907915828/2754026899';

  // Test ads (optional for debugging)
  static const String testNativeId = 'ca-app-pub-3940256099942544/3986624511';
  static const String testRewardedId = 'ca-app-pub-3940256099942544/1712485313';

  // Set to false for production
  static bool get useTestAds => false;

  /// Get Native Ad ID (same for all screens)
  /// No need for 'name' parameter anymore - always returns same ID
  static String getNative() {
    return useTestAds ? testNativeId : nativeAdId;
  }

  /// Get Rewarded Ad ID (same for all screens)
  /// No need for 'name' parameter anymore - always returns same ID
  static String getRewarded() {
    return useTestAds ? testRewardedId : rewardedAdId;
  }
}