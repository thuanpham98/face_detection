import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:face_detection/face_detection.dart';

void main() {
  const MethodChannel channel = MethodChannel('face_detection');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FaceDetection.platformVersion, '42');
  });
}
