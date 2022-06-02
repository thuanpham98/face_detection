package vn.thuanpm.face_detection;

import androidx.annotation.*;

import java.util.HashMap;

import io.flutter.plugin.common.EventChannel;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import faceDetection.FaceDetection;
import faceDetection.FaceDetect;
import faceDetection.FaceLandMark;

public class FaceDetectionPlugin implements FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {

    private static MethodChannel methodChannel;
    private static final String METHOD_CHANNEL = "face_detection";
    private static final String EVENT_CHANNEL = "faceDetectStream";
    private static FaceDetect faceDetect;
    private static FaceLandMark faceLandMark;
    private static EventChannel.EventSink eventSink;
    HashMap<String, Object> streamData = new HashMap<String, Object>();

    @Override
    public void onCancel(Object arguments) {
        eventSink = null;
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        eventSink = events;
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        // method channel
        methodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), METHOD_CHANNEL);
        methodChannel.setMethodCallHandler(this);
        // event channel face detect
        EventChannel eventChannel =  new EventChannel(flutterPluginBinding.getBinaryMessenger(), EVENT_CHANNEL);
        eventChannel.setStreamHandler(this);
    }

    public void onEventSinkCallback(Object data) {
        if (eventSink != null) {
            eventSink.success(data);
        }
    }

    public void initFaceDetect(@NonNull MethodCall call, @NonNull Result result) {
        final byte[] cascade = call.argument("cascade");
        try {
            faceDetect = FaceDetection.initFaceDetect(cascade);
            result.success(true);
        } catch (Exception e) {
            result.error("1", "inti error", "Can not call native error");
        }
    }

    public void runFaceDetect(@NonNull MethodCall call, @NonNull Result result) {
        try {
            byte[] data = call.argument("data");
            Integer rows = call.argument("rows");
            Integer cols = call.argument("cols");
            assert (cols != null && rows != null);
            faceDetect.getFacesDetect(data, cols.longValue(), rows.longValue());

            streamData.put("type",(String) "faceDetect");
            streamData.put("cols", (int) faceDetect.getCols());
            streamData.put("rows", (int) faceDetect.getRows());
            streamData.put("faces", (String) faceDetect.getFaces());
            streamData.put("num_face", (int) faceDetect.getNumFace());

            result.success(streamData);
            onEventSinkCallback(streamData);
            
            streamData.clear();

        } catch (Exception e) {
            result.error("1", e.getMessage(), "error detect face");
        }
    }

    public void initFaceLandMark(@NonNull MethodCall call, @NonNull Result result) {
        try {
            byte[] faceCascade = call.argument("faceCascade");
            byte[] puplocCascade = call.argument("puplocCascade");
            byte[] lp38 = call.argument("lp38");
            byte[] lp42 = call.argument("lp42");
            byte[] lp44 = call.argument("lp44");
            byte[] lp46 = call.argument("lp46");
            byte[] lp81 = call.argument("lp81");
            byte[] lp82 = call.argument("lp82");
            byte[] lp84 = call.argument("lp84");
            byte[] lp93 = call.argument("lp93");
            byte[] lp312 = call.argument("lp312");
            assert (faceCascade != null && puplocCascade != null && lp38 != null && lp42 != null && lp44 != null
                    && lp46 != null && lp81 != null && lp82 != null && lp84 != null && lp93 != null && lp312 != null);
            faceLandMark = FaceDetection.initFaceLandMark(faceCascade, puplocCascade, lp38, lp42, lp44, lp46,
                    lp81, lp82, lp84, lp93, lp312);
            result.success("ok");
        } catch (Exception e) {
            result.error("2", e.getMessage(), "Error init face landmark");
        }

    }

    public void runFaceLandmark(@NonNull MethodCall call, @NonNull Result result) {
        try {
            byte[] data = call.argument("data");
            Integer rows = call.argument("rows");
            Integer cols = call.argument("cols");
            assert (cols != null && rows != null);
            faceLandMark.getFaceLandMark(data,cols.longValue(),rows.longValue());
           
            streamData.put("type",(String) "faceLandMark");
            streamData.put("cols", (int) faceLandMark.getCols());
            streamData.put("rows", (int) faceLandMark.getRows());
            streamData.put("holes", (String) faceLandMark.getHolesFace());
            streamData.put("num_face", (int) faceLandMark.getNumFace());

            result.success(streamData);
            onEventSinkCallback(streamData);
            
            streamData.clear();

        } catch (Exception e) {
            result.error("1", e.getMessage(), "error detect face land mark");
        }
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "runFaceDetect":
                runFaceDetect(call, result);
                break;
            case "initDetectFace":
                initFaceDetect(call, result);
                break;
            case "initFaceLandmark":
                initFaceLandMark(call, result);
                break;
            case "runFaceLandmark":
                runFaceLandmark(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        methodChannel.setMethodCallHandler(null);
    }
}
