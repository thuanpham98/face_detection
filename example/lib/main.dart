import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:face_detection/face_detection.dart';
import 'package:flutter/foundation.dart';
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
  static final ProcessingCameraImage _processingCameraImage =
      ProcessingCameraImage();
  Uint8List? currentImage;
  bool processing = false;
  int count = 0;
  // final Stopwatch stopwatch = Stopwatch();
  final a = BehaviorSubject<Map<String, dynamic>>.seeded({
    "row": 0,
    "rows": 0,
    "cols": 0,
    "col": 0,
    "scale": 0,
    'q': 0,
  });

  void _processinngImage(CameraImage? img) async {
    if (img == null) {
      processing = false;
      return;
    }
    // stopwatch.start();

    final retImage = await compute(processImage, img);

    // print(retImage?.length.toString());
    if ((retImage != null)) {
      await FaceDetection.getFaceLandMark(
        retImage.data,
        retImage.heigh,
        retImage.width,
      );
    }
    processing = false;
    // stopwatch.stop();
    // print(stopwatch.elapsedMilliseconds);
    // stopwatch.reset();
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
    _cameraController = CameraController(cameras[1], ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.yuv420);
    await _cameraController.initialize();
    await _cameraController.startImageStream((image) {
      if (!processing) {
        processing = true;
        pipe.sink.add(image);
      }
      count++;
    });
  }

  static Image8bit? processImage(CameraImage _savedImage) {
    return _processingCameraImage.processCameraImageToGray8Bit(
      height: _savedImage.height,
      width: _savedImage.width,
      plane0: _savedImage.planes[0].bytes,
      rotationAngle: 270,
      isFlipVectical: true,
      // isFlipHoriozntal: true,
    );
  }

  Widget _buildHoldWidget(BuildContext context, int idx) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: FaceDetection.faceDetectStream(
              type: FaceDetectionStreamType.faceLandMark)
          .distinct(),
      builder: (context, snap) {
        Map<String, dynamic> data = {};
        List<Map<String, dynamic>> points = [];
        if (snap.hasData) {
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
        }
        print(points.length);
        if (idx < points.length) {
          data = points[idx];
        }

        if (points.length > 3) {
          print((points[3]['tt']));
          if ((points[3]['tt']) > 93) {
            print("Left");
          } else if ((points[3]['tt']) < 88) {
            print("Right");
          } else {
            print("ahead");
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
              "${data['row']}",
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

            _buildHoldWidget(context, 1),
            _buildHoldWidget(context, 2),
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
            // _buildHoldWidget(context, 16),
            // _buildHoldWidget(context, 16),

            // StreamBuilder<Map<String, dynamic>>(
            //   stream: FaceDetection.faceDetectStream(
            //           type: FaceDetectionStreamType.faceLandMark)
            //       .distinct(),
            //   builder: (context, snap) {
            //     Map<String, dynamic> data = {};
            //     List<Map<String, dynamic>> points = [];
            //     if (snap.hasData) {
            //       //   data = {
            //       //     "row": snap.data?['faces'][0]["Row"] ?? 1,
            //       //     "rows": snap.data?['rows'] ?? 1,
            //       //     "cols": snap.data?['cols'] ?? 1,
            //       //     "col": snap.data?['faces'][0]["Col"] ?? 1,
            //       //     "scale": snap.data?['faces'][0]["Scale"] ?? 1,
            //       //     'q': snap.data?['faces'][0]["Q"] ?? 1,
            //       //   };
            //       // }

            //       for (var i = 0; i < snap.data?['holes'][0].length; i++) {
            //         if (i % 5 == 0) {
            //           points.add({
            //             'rows': snap.data?['rows'],
            //             'cols': snap.data?['cols'],
            //             'row': snap.data?['holes'][0][i],
            //             'col': snap.data?['holes'][0][i + 1],
            //             'scale': snap.data?['holes'][0][i + 2],
            //             'q': snap.data?['holes'][0][i + 3],
            //             'tt': snap.data?['holes'][0][i + 4],
            //           });
            //         }
            //       }
            //       int index = 12;
            //       if (points.length > index) {}
            //       data = points[index];
            //     }

            //     if (data.isEmpty) {
            //       return Container(
            //         color: Colors.transparent,
            //       );
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
            //           "ahihi",
            //           style: TextStyle(fontSize: 13),
            //         ),
            //         alignment: Alignment.center,
            //       ),
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
