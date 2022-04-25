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

  static Future<dynamic> initFaceLandmark() async {
    final ByteData cascadeRaw =
        await rootBundle.load('packages/face_detection/assets/facefinder');
    final ByteData puplocRaw =
        await rootBundle.load('packages/face_detection/assets/puploc');
    final ByteData lp38Raw =
        await rootBundle.load('packages/face_detection/assets/lp38');
    final ByteData lp42Raw =
        await rootBundle.load('packages/face_detection/assets/lp42');
    final ByteData lp44Raw =
        await rootBundle.load('packages/face_detection/assets/lp44');
    final ByteData lp46Raw =
        await rootBundle.load('packages/face_detection/assets/lp46');
    final ByteData lp81Raw =
        await rootBundle.load('packages/face_detection/assets/lp81');
    final ByteData lp82Raw =
        await rootBundle.load('packages/face_detection/assets/lp82');
    final ByteData lp84Raw =
        await rootBundle.load('packages/face_detection/assets/lp84');
    final ByteData lp93Raw =
        await rootBundle.load('packages/face_detection/assets/lp93');
    final ByteData lp312Raw =
        await rootBundle.load('packages/face_detection/assets/lp312');

    final Uint8List cascadebytes = cascadeRaw.buffer
        .asUint8List(cascadeRaw.offsetInBytes, cascadeRaw.lengthInBytes);
    final Uint8List puplocbytes = puplocRaw.buffer
        .asUint8List(puplocRaw.offsetInBytes, puplocRaw.lengthInBytes);
    final Uint8List lp38Rawbytes = lp38Raw.buffer
        .asUint8List(lp38Raw.offsetInBytes, lp38Raw.lengthInBytes);

    final Uint8List lp42Rawbytes = lp42Raw.buffer
        .asUint8List(lp42Raw.offsetInBytes, lp42Raw.lengthInBytes);
    final Uint8List lp44Rawbytes = lp44Raw.buffer
        .asUint8List(lp44Raw.offsetInBytes, lp44Raw.lengthInBytes);
    final Uint8List lp46Rawbytes = lp46Raw.buffer
        .asUint8List(lp46Raw.offsetInBytes, lp46Raw.lengthInBytes);
    final Uint8List lp81Rawbytes = lp81Raw.buffer
        .asUint8List(lp81Raw.offsetInBytes, lp81Raw.lengthInBytes);
    final Uint8List lp82Rawbytes = lp82Raw.buffer
        .asUint8List(lp82Raw.offsetInBytes, lp82Raw.lengthInBytes);
    final Uint8List lp84Rawbytes = lp84Raw.buffer
        .asUint8List(lp84Raw.offsetInBytes, lp84Raw.lengthInBytes);
    final Uint8List lp93Rawbytes = lp93Raw.buffer
        .asUint8List(lp93Raw.offsetInBytes, lp93Raw.lengthInBytes);
    final Uint8List lp312Rawbytes = lp312Raw.buffer
        .asUint8List(lp312Raw.offsetInBytes, lp312Raw.lengthInBytes);

    return await _channel.invokeMethod(
      'initFaceLandmark',
      {
        "faceCascade": cascadebytes,
        "puplocCascade": puplocbytes,
        "lp38": lp38Rawbytes,
        "lp42": lp42Rawbytes,
        "lp44": lp44Rawbytes,
        "lp46": lp46Rawbytes,
        "lp81": lp81Rawbytes,
        "lp82": lp82Rawbytes,
        "lp84": lp84Rawbytes,
        "lp93": lp93Rawbytes,
        "lp312": lp312Rawbytes,
      },
    );
  }
}
