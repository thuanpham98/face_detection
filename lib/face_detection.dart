import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter/services.dart';

class FaceDetection {
  static const MethodChannel _channel = MethodChannel('face_detection');

  static Future<dynamic> initFaceDetect() async {
    final byteData =
        await rootBundle.load('packages/face_detection/assets/facefinder');

    return await _channel.invokeMethod(
        'initDetectFace', {'cascade': byteData.buffer.asUint8List()});
  }

  static Future<dynamic> getFaceDetect(
      Uint8List data, int rows, int cols) async {
    return await _channel.invokeMethod(
        'runDetectFace', {'data': data, 'rows': rows, 'cols': cols});
  }
}
