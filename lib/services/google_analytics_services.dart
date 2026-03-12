import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Card click events
  static Future<void> logInstantClick() async {
    await _analytics.logEvent(name: 'instant_click');
  }

  static Future<void> logExteriorClick() async {
    await _analytics.logEvent(name: 'exterior_click');
  }

  static Future<void> logWallClick() async {
    await _analytics.logEvent(name: 'wall_click');
  }

  static Future<void> logFloorClick() async {
    await _analytics.logEvent(name: 'floor_click');
  }

  static Future<void> logRemoveObjectClick() async {
    await _analytics.logEvent(name: 'remove_object_click');
  }

  static Future<void> logReplaceClick() async {
    await _analytics.logEvent(name: 'replace_click');
  }

  static Future<void> logFillSpaceClick() async {
    await _analytics.logEvent(name: 'fill_space_click');
  }

  static Future<void> logReferenceClick() async {
    await _analytics.logEvent(name: 'reference_click');
  }
}