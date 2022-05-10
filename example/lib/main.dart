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
  final ProcessingCameraImage _processingCameraImage = ProcessingCameraImage();
  imglib.Image? currentImage;

  int count = 0;

  void _processinngImage(CameraImage? value) async {
    if (value != null) {
      currentImage = await Future.microtask(() => processImage(value));
      if (currentImage != null) {
        // await FaceDetection.getFaceLandMark(
        //   currentImage,
        //   value.width,
        //   value.height,
        // );
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
    await FaceDetection.initFaceDetect().then((value) => print(value));
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[1], ResolutionPreset.low,
        imageFormatGroup: ImageFormatGroup.yuv420);
    await _cameraController.initialize();
    await _cameraController.startImageStream((image) {
      pipe.sink.add(image);
    });
  }

  imglib.Image? processImage(CameraImage _savedImage) {
    // return _processingCameraImage.processCameraImageToRGBIOS(
    //   bytesPerPixelPlan1: 2,
    //   bytesPerRowPlane0: _savedImage.planes[0].bytesPerRow,
    //   bytesPerRowPlane1: _savedImage.planes[0].bytesPerRow,
    //   height: _savedImage.height,
    //   plane0: _savedImage.planes[0].bytes,
    //   plane1: _savedImage.planes[1].bytes,
    //   rotationAngle: 0,
    //   width: _savedImage.width,
    // );
    return _processingCameraImage.processCameraImageToGrayIOS(
      height: _savedImage.height,
      width: _savedImage.width,
      plane0: _savedImage.planes[0].bytes,
      rotationAngle: 0,
      backGroundColor: Colors.red.value,
      isFlipVectical: false,
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
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Scaffold(
                        body: Center(
                          child: Image.memory(Uint8List.fromList(
                              imglib.encodeJpg(currentImage!))),
                        ),
                      )));
        },
      ),
      body: Center(
        child: FutureBuilder<void>(
          future: _instanceInit,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return AspectRatio(
                aspectRatio: 1 /
                    (_cameraController.value.previewSize?.aspectRatio ?? 4 / 3),
                child: CameraPreview(_cameraController),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
