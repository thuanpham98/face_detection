import Flutter
import UIKit
import FaceDetection

public class SwiftFaceDetectionPlugin: NSObject, FlutterPlugin {
    private static let CHANNEL_METHOD = "face_detection"
    private var _faceDetect : FaceDetectionFaceDetect?  =  Optional<FaceDetectionFaceDetect>.none
    private var  streamData = Optional<Dictionary<String, Any>>.none
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: CHANNEL_METHOD, binaryMessenger: registrar.messenger())
    let instance = SwiftFaceDetectionPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case "initDetectFace":
        let data: Dictionary<String, Any> = call.arguments as! Dictionary<String, Any>
        let cascade = Data((data["cascade"] as! FlutterStandardTypedData).data)
        _faceDetect = FaceDetection.FaceDetectionInitFaceDetect(cascade).self
        result(_faceDetect?.maxSize)
      default:
        result(FlutterMethodNotImplemented)
    }
  }
}
