package vn.thuanpm.face_detection;

import androidx.annotation.NonNull;

import java.util.HashMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import faceDetection.FaceDetection;
import faceDetection.MobilePigo;
import faceDetection.MobilePigoLandMark;
/** FaceDetectionPlugin */
public class FaceDetectionPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private static final String CHANNEL = "face_detection";
  private MobilePigo mobilePigo ;
  private MobilePigoLandMark mobilePigoLandMark;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), CHANNEL);
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("runDetectFace")) {
        if (!call.hasArgument("data")) {
            System.out.println("no Input data");
            return;
        }
        try {
            byte[] data = call.argument("data");
            int rows =call.argument("rows");
            int cols = call.argument("cols");

            mobilePigo.getFacesDetect(data,(long)cols,(long)rows);
            
            HashMap<String, Object> ret = new HashMap<String, Object>();
            ret.put("cols", (int) mobilePigo.getCols());
            ret.put("rows", (int) mobilePigo.getRows());
            ret.put("faces", (String) mobilePigo.getFaces());
            result.success(ret);
            return;
        } catch (Exception e) {
            result.error("1", e.getMessage(), "error detect face");
        }
    } else if(call.method.equals("initDetectFace")){
         byte[] cascade = call.argument("cascade");
         try {
             mobilePigo = FaceDetection.initFaceDetect(cascade);
             System.out.println(cascade);
             result.success(true);
             return;
         }catch (Exception e){
             result.error("0", e.getMessage(), "error init detect face");
         }

    }
    else if(call.method.equals("initFaceLandmark")){
        byte[] facecascade = call.argument("faceCascade");
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
        mobilePigoLandMark = FaceDetection.initFaceLandMark(facecascade,puplocCascade,lp38,lp42,lp44,lp46,lp81,lp82,lp84,lp93,lp312);
        result.success("ok");
    }
    else if(call.method.equals("runFaceLandmark")){

        byte[] data = call.argument("data");
        mobilePigoLandMark.getFaceLandMark(data);
        HashMap<String, Integer> ret = new HashMap<String, Integer>();
        ret.put("q", (int) mobilePigoLandMark.getQ());
        ret.put("scale", (int) mobilePigoLandMark.getScale());
        ret.put("cols", (int) mobilePigoLandMark.getCols());
        ret.put("rows", (int) mobilePigoLandMark.getRows());
        ret.put("row", (int) mobilePigoLandMark.getRow());
        ret.put("col", (int) mobilePigoLandMark.getCol());
        ret.put("noseCol", (int) mobilePigoLandMark.getNoseCol());
        ret.put("noseRow", (int) mobilePigoLandMark.getNoseRow());
        result.success(ret);
        return;
    }
    else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
