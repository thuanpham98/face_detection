
import 'dart:async';

import 'package:flutter/services.dart';

class FaceDetection {
  static const MethodChannel _channel = MethodChannel('face_detection');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
