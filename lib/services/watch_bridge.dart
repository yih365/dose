import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Bridges between Flutter and the native Android Wearable Data Layer.
// Only active on Android; no-ops on all other platforms.
class WatchBridge {
  static const _method = MethodChannel('com.dose.dose/watch');
  static const _events = EventChannel('com.dose.dose/watch_events');

  // Stream of log events received from the Pixel Watch.
  // Each event is a Map with keys 'type' (String) and 'mg' (int).
  static Stream<Map<String, dynamic>> get watchLogs {
    if (!_isAndroid) return const Stream.empty();
    return _events.receiveBroadcastStream().map((e) => Map<String, dynamic>.from(e as Map));
  }

  // Push the updated daily total to the watch so the tile refreshes.
  static Future<void> pushDailyTotal({required int totalMg, required int limitMg}) async {
    if (!_isAndroid) return;
    await _method.invokeMethod('pushDailyTotal', {
      'total_mg': totalMg,
      'limit_mg': limitMg,
    });
  }

  static bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;
}
