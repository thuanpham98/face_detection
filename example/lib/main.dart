import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:processing_camera_image/processing_camera_image.dart';
import 'package:rxdart/rxdart.dart';

import 'package:face_detection/face_detection.dart';

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
  late CameraController _cameraController;
  late Future<void> _instanceInit;
  late BehaviorSubject<CameraImage?> _pipe;
  late ProcessingCameraImage _processingCameraImage;
  bool _processing = false;

  @override
  void initState() {
    _pipe =
      BehaviorSubject<CameraImage?>.seeded(null);
    _processingCameraImage = ProcessingCameraImage();
    _instanceInit = initCamera();
    _pipe.listen(_processingImage);
    super.initState();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _pipe.close();
    super.dispose();
  }

  void _processingImage(CameraImage? img) async {
    try {
      if (img == null) {
        _processing = false;
        return;
      }

      final retImage = _processImage(img);

      Image8bit? convertRetImage = convertImage(img, retImage!);

      if (convertRetImage != null) {
        await FaceDetection.getFaceLandMark(
          convertRetImage.data,
          convertRetImage.heigh,
          convertRetImage.width,
        );
      }
      _processing = false;
    } catch (error) {
      _processing = false;
      log(error.toString());
      const IgnorePointer();
    }
  }

  Image8bit? convertImage(CameraImage oldImage, Image8bit newImage) {
    if (newImage.heigh > oldImage.width && oldImage.height < oldImage.width) {
      int visai = newImage.heigh - oldImage.width;
      return Image8bit(
          data: newImage.data.sublist(
              (visai) * (newImage.width), newImage.heigh * newImage.width),
          heigh: oldImage.width,
          width: oldImage.height);
    } else {
      return newImage;
    }
  }

  Future<void> initCamera() async {
    FaceDetection.initFaceLandmark();

    final cameras = await availableCameras();

    _cameraController = CameraController(cameras[1], ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.yuv420);

    await _cameraController.initialize();
    await _cameraController.startImageStream((image) {
      if (!_processing) {
        _processing = true;
        _pipe.sink.add(image);
      }
    });
  }

  Image8bit? _processImage(input) {
    return _processingCameraImage.processCameraImageToGray8Bit(
      height: input.height,
      width: input.planes[0].bytesPerRow > input.width
          ? input.planes[0].bytesPerRow
          : input.width,
      plane0: input.planes[0].bytes,
      rotationAngle: (input.height > input.width)
          ? 0
          : _cameraController.description.sensorOrientation.toDouble(),
      isFlipVectical: Platform.isAndroid ? true : false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: FutureBuilder<void>(
              future: _instanceInit,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(
                    _cameraController,
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
          ),
          LandmarkWidget(context: context, idx: 14),
        ],
      ),
    );
  }
}

class LandmarkWidget extends StatelessWidget {
  const LandmarkWidget({
    Key? key,
    required this.context,
    required this.idx,
  }) : super(key: key);

  final BuildContext context;
  final int idx;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return StreamBuilder<Map<String, dynamic>>(
      stream: FaceDetection.faceDetectStream(
              type: FaceDetectionStreamType.faceLandMark)
          .distinct(),
      builder: (context, snap) {
        Map<String, dynamic> data = {};
        List<Map<String, dynamic>> points = [];
        if (snap.hasData) {
          for (int i = 0, index = 0;
              i < List.from(snap.data?['holes'][0] ?? []).length;
              i = i + 5, index++) {
            if (index > idx) continue;
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

          data = points[idx];

          if (data.isEmpty) {
            return const SizedBox();
          }

          double sizeScale =
                  screenWidth / (data['cols'] ?? 1) * (data['scale'] ?? 1),
              sizeRows = screenWidth / (data['cols'] ?? 1) * (data['row'] ?? 1),
              sizeCols = screenWidth / (data['cols'] ?? 1) * (data['col'] ?? 1);
          return Positioned(
            left: sizeCols - 0.5 * sizeScale,
            top: sizeRows - 0.5 * sizeScale,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              width: sizeScale,
              height: sizeScale,
              child: Text(
                '${data['scale']}',
                style: const TextStyle(fontSize: 13, color: Colors.red),
              ),
              alignment: Alignment.center,
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
