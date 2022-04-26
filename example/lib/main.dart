import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:face_detection/face_detection.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;
import 'package:processing_camera_image/processing_camera_image.dart';
import 'package:rxdart/rxdart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final CameraController _cameraController;
  late Future<void> _instanceInit;
  final pipe = BehaviorSubject<CameraImage?>.seeded(null);
  int count = 0;
  int blink = 0;
  final ProcessingCameraImage _processingCameraImage = ProcessingCameraImage();
  imglib.Image? currentImage;
  // final stopwatch = Stopwatch();
  void _processinngImage(CameraImage? value) async {
    if (value != null) {
      // stopwatch.start();

      // currentImage = await Future.microtask(() => processImage(value));
      final Uint8List? currentImage =
          _processingCameraImage.processCameraImageToGray8Bit(
        height: value.height,
        width: value.width,
        plane0: value.planes[0].bytes,
        rotationAngle:
            _cameraController.description.sensorOrientation.toDouble() == 0.0
                ? 270
                : _cameraController.description.sensorOrientation.toDouble(),
      );

      if (currentImage != null) {
        // await Future.delayed(Duration(milliseconds: 24));
        await FaceDetection.getFaceLandMark(
          currentImage,
          value.width,
          value.height,
        );
      }
      // stopwatch.stop();
      // print('this is time process: ${stopwatch.elapsedMilliseconds}');
      // stopwatch.reset();
    }
  }

  final a = BehaviorSubject<Map<String, dynamic>>.seeded({
    "row": 0,
    "rows": 0,
    "cols": 0,
    "col": 0,
    "scale": 0,
    'q': 0,
  });

  @override
  void initState() {
    _instanceInit = initCamera();
    pipe.listen(_processinngImage);

    super.initState();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> initCamera() async {
    await FaceDetection.initFaceDetect();
    await FaceDetection.initFaceLandmark();
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[1], ResolutionPreset.low);
    await _cameraController.initialize();
    await _cameraController.startImageStream((image) {
      count++;
      if (count % 2 == 0) {
        pipe.sink.add(image);
      }
    });
  }

  imglib.Image? processImage(CameraImage _savedImage) {
    return _processingCameraImage.processCameraImageToGray(
      height: _savedImage.height,
      width: _savedImage.width,
      plane0: _savedImage.planes[0].bytes,
      rotationAngle: 270,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: FutureBuilder<void>(
                  future: _instanceInit,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return CameraPreview(
                        _cameraController,
                      );
                    }
                    return CircularProgressIndicator();
                  },
                ),
              ),
            ),
            StreamBuilder<Map<String, dynamic>>(
              stream: FaceDetection.faceDetectStream.distinct(),
              builder: (context, snap) {
                Map<String, dynamic> data = {};
                if (snap.hasData) {
                  data = snap.data ??
                      {
                        "row": 1,
                        "rows": 1,
                        "cols": 1,
                        "col": 1,
                        "scale": 1,
                        'q': 1,
                      };
                }
                if ((data['q'] as int) < 30) {
                  blink++;
                }
                // return Container();

                return Positioned(
                  left: -0.5 *
                          ((MediaQuery.of(context).size.width) /
                              (data['cols'] ?? 1) *
                              (data['scale'] ?? 1)) +
                      ((MediaQuery.of(context).size.width) /
                          (data['cols'] ?? 1) *
                          (data['col'] ?? 1)),
                  top: -0.5 *
                          ((MediaQuery.of(context).size.width) /
                              (data['cols'] ?? 1) *
                              (data['scale'] ?? 1)) +
                      ((MediaQuery.of(context).size.width) /
                          (data['cols'] ?? 1) *
                          (data['row'] ?? 1)),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(),
                    ),
                    width: (MediaQuery.of(context).size.width) /
                        (data['cols'] ?? 1) *
                        (data['scale'] ?? 1),
                    height: (MediaQuery.of(context).size.width) /
                        (data['cols'] ?? 1) *
                        (data['scale'] ?? 1),
                    child: Text(
                      "${blink}",
                      style: TextStyle(fontSize: 24),
                    ),
                    alignment: Alignment.center,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
