import Flutter
import UIKit
import FaceDetection


public class SwiftFaceDetectionPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private static var CHANNEL_METHOD = "face_detection"
    private static var CHANNEL_EVENT = "faceDetectStream"
    private var eventSink: FlutterEventSink?
    private var _faceDetect : FaceDetectionFaceDetect?  =  Optional<FaceDetectionFaceDetect>.none
    private var _faceLandmark : FaceDetectionFaceLandMark? = Optional<FaceDetectionFaceLandMark>.none
    private var  streamData : Dictionary<String, Any> = [:]
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(name: CHANNEL_METHOD, binaryMessenger: registrar.messenger())
        let instance = SwiftFaceDetectionPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        let eventChannel = FlutterEventChannel(name: CHANNEL_EVENT, binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance)
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    public func onEventSinkCallback(data : Dictionary<String, Any>) {
        if (eventSink != nil) {
            eventSink?(data);
        }
    }
    
    public func initFaceDetect(_ call: FlutterMethodCall, result: @escaping FlutterResult){
        let rawData: Dictionary<String, Any> = call.arguments as! Dictionary<String, Any>
        let cascade = Data((rawData["cascade"] as! FlutterStandardTypedData).data)
        _faceDetect = FaceDetection.FaceDetectionInitFaceDetect(cascade)
        result("ok")
    }
    
    public func runFaceDetect(_ call: FlutterMethodCall, result: @escaping FlutterResult){
        let rawData: Dictionary<String, Any> = call.arguments as! Dictionary<String, Any>
        
        let rows : Int = rawData["rows"] as! Int
        let cols : Int = rawData["cols"] as! Int
        let data = Data((rawData["data"] as! FlutterStandardTypedData).data)
        _faceDetect?.getFacesDetect(data, cols: cols, rows: rows)
        
        streamData["type"] = "faceDetect"
        streamData["cols"] = _faceDetect?.cols
        streamData["rows"] = _faceDetect?.rows
        streamData["faces"] = _faceDetect?.faces
        streamData["num_face"] = _faceDetect?.numFace

        result(streamData)
        onEventSinkCallback(data: streamData)

        streamData.removeAll(keepingCapacity: false)
    }
    public func initFaceLandmark(_ call: FlutterMethodCall, result: @escaping FlutterResult){
        let rawData: Dictionary<String, Any> = call.arguments as! Dictionary<String, Any>
        let faceCascade = Data((rawData["faceCascade"] as! FlutterStandardTypedData).data)
        let puplocCascade = Data((rawData["puplocCascade"] as! FlutterStandardTypedData).data)
        let lp38 = Data((rawData["lp38"] as! FlutterStandardTypedData).data)
        let lp42 = Data((rawData["lp42"] as! FlutterStandardTypedData).data)
        let lp44 = Data((rawData["lp44"] as! FlutterStandardTypedData).data)
        let lp46 = Data((rawData["lp46"] as! FlutterStandardTypedData).data)
        let lp81 = Data((rawData["lp81"] as! FlutterStandardTypedData).data)
        let lp82 = Data((rawData["lp82"] as! FlutterStandardTypedData).data)
        let lp84 = Data((rawData["lp84"] as! FlutterStandardTypedData).data)
        let lp93 = Data((rawData["lp93"] as! FlutterStandardTypedData).data)
        let lp312 = Data((rawData["lp312"] as! FlutterStandardTypedData).data)
        _faceLandmark = FaceDetection.FaceDetectionInitFaceLandMark(faceCascade,puplocCascade,lp38,lp42,lp44,lp46,lp81,lp82,lp84,lp93,lp312)
        result("ok")
        
    }
    public func runFaceLandmark(_ call: FlutterMethodCall, result: @escaping FlutterResult){
        let rawData: Dictionary<String, Any> = call.arguments as! Dictionary<String, Any>
        
        let rows : Int = rawData["rows"] as! Int
        let cols : Int = rawData["cols"] as! Int
        let data = Data((rawData["data"] as! FlutterStandardTypedData).data)
        _faceLandmark?.getFaceLandMark(data, cols: cols, rows: rows)
        
       
        streamData["type"] = "faceLandMark"
        streamData["cols"] = _faceLandmark?.cols
        streamData["rows"] = _faceLandmark?.rows
        streamData["holes"] = _faceLandmark?.holesFace
        streamData["num_face"] = _faceLandmark?.numFace

        result(streamData)
        onEventSinkCallback(data: streamData)

        streamData.removeAll(keepingCapacity: false)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initDetectFace":
            initFaceDetect(call, result: result)
        case "runFaceDetect":
            runFaceDetect(call, result: result)
        case "initFaceLandmark":
            initFaceLandmark(call, result: result)
        case "runFaceLandmark":
            runFaceLandmark(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
