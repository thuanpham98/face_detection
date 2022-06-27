#import "FaceDetectionPlugin.h"
//#if __has_include(<face_detection/face_detection-Swift.h>)
//#import <face_detection/face_detection-Swift.h>
//#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
//// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
//#import "face_detection-Swift.h"
//#endif
#import "face_detection/face_detection-Swift.h"

@implementation FaceDetectionPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFaceDetectionPlugin registerWithRegistrar:registrar];
}
@end
