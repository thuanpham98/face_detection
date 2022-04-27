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
  int frame = 0;
  bool preFrame = false;
  double holePoint = 0;
  final ProcessingCameraImage _processingCameraImage = ProcessingCameraImage();
  imglib.Image? currentImage;
  final Stopwatch stopwatch = Stopwatch();

  void _processinngImage(CameraImage? value) async {
    if (value != null) {
      final Uint8List? currentImage = await Future.microtask(() =>
          _processingCameraImage.processCameraImageToGray8Bit(
            height: value.height,
            width: value.width,
            plane0: value.planes[0].bytes,
            rotationAngle: _cameraController.description.sensorOrientation
                        .toDouble() ==
                    0.0
                ? 270
                : _cameraController.description.sensorOrientation.toDouble(),
          ));

      if (currentImage != null) {
        await FaceDetection.getFaceLandMark(
          currentImage,
          value.width,
          value.height,
        );
      }
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

  // imglib.Image? processImage(CameraImage _savedImage) {
  //   return _processingCameraImage.processCameraImageToGray(
  //     height: _savedImage.height,
  //     width: _savedImage.width,
  //     plane0: _savedImage.planes[0].bytes,
  //     rotationAngle: 270,
  //   );
  // }

  Widget _buildHoldWidget(BuildContext context, int idx) {
    return /////////////-----33333--------//
        StreamBuilder<Map<String, dynamic>>(
      stream: FaceDetection.faceDetectStream(
              type: FaceDetectionStreamType.faceLandMark)
          .distinct(),
      builder: (context, snap) {
        Map<String, dynamic> data = {};
        if (snap.hasData) {
          List<Map<String, int>> points = [];

          for (var i = 0; i < snap.data?['holes'][0].length; i++) {
            if (i % 5 == 0) {
              points.add({
                'rows': snap.data?['rows'],
                'cols': snap.data?['cols'],
                'row': snap.data?['holes'][0][i],
                'col': snap.data?['holes'][0][i + 1],
                'scale': snap.data?['holes'][0][i + 2],
                'q': snap.data?['holes'][0][i + 3]
              });
            }
          }
          points.sort((a, b) => ((a['col'] ?? 0) - (b['col'] ?? 0)));
          if (points.length > idx) {
            data = points[idx];
          }
          // holePoint += data['q'] ?? 0;
          // if (count % 8 == 0) {
          //   print(holePoint / 3);
          //   if (holePoint / 3 < 50) {
          //     blink++;
          //   }
          //   holePoint = 0;
          // }
          if (data['q'] < 50) {
            blink++;
          }
        }

        if (data.isEmpty) {
          return SizedBox.shrink();
        }
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
              style: TextStyle(fontSize: 13),
            ),
            alignment: Alignment.center,
          ),
        );
      },
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
            // StreamBuilder<Map<String, dynamic>>(
            //   stream: FaceDetection.faceDetectStream(
            //           type: FaceDetectionStreamType.faceLandMark)
            //       .distinct(),
            //   builder: (context, snap) {
            //     Map<String, dynamic> data = {};
            //     if (snap.hasData) {
            //       List<Map<String, int>> points = [];

            //       for (var i = 0; i < snap.data?['holes'][0].length; i++) {
            //         if (i % 5 == 0) {
            //           points.add({
            //             'rows': snap.data?['rows'],
            //             'cols': snap.data?['cols'],
            //             'row': snap.data?['holes'][0][i],
            //             'col': snap.data?['holes'][0][i + 1],
            //             'scale': snap.data?['holes'][0][i + 2],
            //             'q': snap.data?['holes'][0][i + 3]
            //           });
            //         }
            //       }
            //       points.sort((a, b) => ((a['col'] ?? 0) - (b['col'] ?? 0)));

            //     }
            //     if (data.isEmpty) {
            //       return SizedBox.shrink();
            //     }
            //     return Positioned(
            //       left: -0.5 *
            //               ((MediaQuery.of(context).size.width) /
            //                   (data['cols'] ?? 1) *
            //                   (data['scale'] ?? 1)) +
            //           ((MediaQuery.of(context).size.width) /
            //               (data['cols'] ?? 1) *
            //               (data['col'] ?? 1)),
            //       top: -0.5 *
            //               ((MediaQuery.of(context).size.width) /
            //                   (data['cols'] ?? 1) *
            //                   (data['scale'] ?? 1)) +
            //           ((MediaQuery.of(context).size.width) /
            //               (data['cols'] ?? 1) *
            //               (data['row'] ?? 1)),
            //       child: Container(
            //         decoration: BoxDecoration(
            //           border: Border.all(),
            //         ),
            //         width: (MediaQuery.of(context).size.width) /
            //             (data['cols'] ?? 1) *
            //             (data['scale'] ?? 1),
            //         height: (MediaQuery.of(context).size.width) /
            //             (data['cols'] ?? 1) *
            //             (data['scale'] ?? 1),
            //         child: Text(
            //           "$blink",
            //           style: TextStyle(fontSize: 13),
            //         ),
            //         alignment: Alignment.center,
            //       ),
            //     );
            //   },
            // ),

            /////////////---------------//
            // _buildHoldWidget(context, 0),

            // _buildHoldWidget(context, 1),

            // _buildHoldWidget(context, 2),

            _buildHoldWidget(context, 0),

            // _buildHoldWidget(context, 4),

            // _buildHoldWidget(context, 5),

            // _buildHoldWidget(context, 6),
            // _buildHoldWidget(context, 7),
            // _buildHoldWidget(context, 8),
            // _buildHoldWidget(context, 9),
            // _buildHoldWidget(context, 10),
            // _buildHoldWidget(context, 11),
            // _buildHoldWidget(context, 12),
            // _buildHoldWidget(context, 13),

            // _buildHoldWidget(context, 14),
            // _buildHoldWidget(context, 15),

            // _buildHoldWidget(context, 16),
            // _buildHoldWidget(context, 17),
          ],
        ),
      ),
    );
  }
}
