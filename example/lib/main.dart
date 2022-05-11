import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:face_detection/face_detection.dart';
import 'package:flutter/material.dart';
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
  final ProcessingCameraImage _processingCameraImage = ProcessingCameraImage();
  Uint8List? currentImage;

  int count = 0;

  final a = BehaviorSubject<Map<String, dynamic>>.seeded({
    "row": 0,
    "rows": 0,
    "cols": 0,
    "col": 0,
    "scale": 0,
    'q': 0,
  });

  void _processinngImage(CameraImage? value) async {
    if (value != null) {
      currentImage = await Future.microtask(() => processImage(value));
      // print(currentImage);
      if (currentImage != null && (currentImage?.isNotEmpty ?? false)) {
        await FaceDetection.getFaceLandMark(
          currentImage!,
          value.height,
          value.width,
        );
      }
    }
  }

  @override
  void initState() {
    pipe.listen(_processinngImage);
    _instanceInit = initCamera();
    super.initState();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> initCamera() async {
    // await FaceDetection.initFaceDetect().then((value) => print(value));
    FaceDetection.initFaceLandmark().then((value) => print(value));
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[1], ResolutionPreset.low,
        imageFormatGroup: ImageFormatGroup.yuv420);
    await _cameraController.initialize();
    await _cameraController.startImageStream((image) {
      pipe.sink.add(image);
    });
  }

  Uint8List? processImage(CameraImage _savedImage) {
    return _processingCameraImage.processCameraImageToGray8Bit(
      height: _savedImage.width,
      width: _savedImage.height,
      plane0: _savedImage.planes[0].bytes,
      rotationAngle: 0,
      // isFlipVectical: true,
      // isFlipHoriozntal: true,
    );
  }

  // Widget _buildHoldWidget(BuildContext context, int idx) {
  //   return /////////////-----33333--------//
  //       StreamBuilder<Map<String, dynamic>>(
  //     stream: FaceDetection.faceDetectStream(
  //             type: FaceDetectionStreamType.faceLandMark)
  //         .distinct(),
  //     builder: (context, snap) {
  //       Map<String, dynamic> data = {
  //         "row": 0,
  //         "rows": 0,
  //         "cols": 0,
  //         "col": 0,
  //         "scale": 0,
  //         'q': 0,
  //       };
  //       if (snap.hasData) {
  //         data = {
  //           "row": (snap.data?["faces"][0]["row"]) ?? 1,
  //           "rows": snap.data?["rows"] ?? 1,
  //           "cols": snap.data?["cols"] ?? 1,
  //           "col": (snap.data?["faces"][0]["col"]) ?? 1,
  //           "scale": (snap.data?["faces"][0]["scale"]) ?? 1,
  //           'q': (snap.data?["faces"][0]["q"]) ?? 1,
  //         };
  //       }

  //       if (data.isEmpty) {
  //         return SizedBox.shrink();
  //       }
  //       return Positioned(
  //         left: -0.5 *
  //                 ((MediaQuery.of(context).size.width) /
  //                     (data['cols'] ?? 1) *
  //                     (data['scale'] ?? 1)) +
  //             ((MediaQuery.of(context).size.width) /
  //                 (data['cols'] ?? 1) *
  //                 (data['col'] ?? 1)),
  //         top: -0.5 *
  //                 ((MediaQuery.of(context).size.width) /
  //                     (data['cols'] ?? 1) *
  //                     (data['scale'] ?? 1)) +
  //             ((MediaQuery.of(context).size.width) /
  //                 (data['cols'] ?? 1) *
  //                 (data['row'] ?? 1)),
  //         child: Container(
  //           decoration: BoxDecoration(
  //             border: Border.all(),
  //           ),
  //           width: (MediaQuery.of(context).size.width) /
  //               (data['cols'] ?? 1) *
  //               (data['scale'] ?? 1),
  //           height: (MediaQuery.of(context).size.width) /
  //               (data['cols'] ?? 1) *
  //               (data['scale'] ?? 1),
  //           child: Text(
  //             "${data}",
  //             style: TextStyle(fontSize: 13),
  //           ),
  //           alignment: Alignment.center,
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: InkWell(
        child: Container(
          color: Colors.white.withOpacity(0.0),
          height: 36,
          width: 36,
          child: const Icon(Icons.photo_camera),
        ),
        onTap: () {},
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
              stream: FaceDetection.faceDetectStream(
                      type: FaceDetectionStreamType.faceLandMark)
                  .distinct(),
              builder: (context, snap) {
                Map<String, dynamic> data = {};
                List<Map<String, dynamic>> points = [];
                if (snap.hasData) {
                  //   data = {
                  //     "row": snap.data?['faces'][0]["Row"] ?? 1,
                  //     "rows": snap.data?['rows'] ?? 1,
                  //     "cols": snap.data?['cols'] ?? 1,
                  //     "col": snap.data?['faces'][0]["Col"] ?? 1,
                  //     "scale": snap.data?['faces'][0]["Scale"] ?? 1,
                  //     'q': snap.data?['faces'][0]["Q"] ?? 1,
                  //   };
                  // }

                  for (var i = 0; i < snap.data?['holes'][0].length; i++) {
                    if (i % 5 == 0) {
                      points.add({
                        'rows': snap.data?['rows'],
                        'cols': snap.data?['cols'],
                        'row': snap.data?['holes'][0][i],
                        'col': snap.data?['holes'][0][i + 1],
                        'scale': snap.data?['holes'][0][i + 2],
                        'q': snap.data?['holes'][0][i + 3],
                        'tt': snap.data?['holes'][0][i + 4],
                      });
                    }
                  }
                  // points.sort((a, b) => ((a['col'] ?? 0) - (b['col'] ?? 0)));
                  data = points[3];
                }
                if (points.length > 3) {
                  print(points[3]['tt']);
                }
                // print(snap.data);
                // return SizedBox.shrink();
                // print(points[3]);
                if (data.isEmpty) {
                  return Container(
                    color: Colors.transparent,
                  );
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
                      "ahihi",
                      style: TextStyle(fontSize: 13),
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
