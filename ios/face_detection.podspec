#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint face_detection.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'face_detection'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'

  
  s.preserve_paths = 'Frameworks/FaceDetection.xcframework/**/*'
  s.xcconfig = { 'OTHER_LDFLAGS' => '-framework FaceDetection' }
  # config path to frame word
  s.ios.vendored_frameworks ='Frameworks/FaceDetection.xcframework' 

  s.dependency 'Flutter'
  # s.dependency 'Frameworks/FaceDetection.xcframework/ios-arm64/FaceDetection.framework'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
