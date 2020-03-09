import 'dart:async';

import 'package:flutter/services.dart';

class Exposurelistview {
  static const MethodChannel _channel =
      const MethodChannel('exposurelistview');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
