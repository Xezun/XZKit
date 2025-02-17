#
# Be sure to run `pod lib lint XZExtensions.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#



Pod::Spec.new do |s|
  s.name             = 'XZExtensions'
  s.version          = '10.2.0'
  s.summary          = '对原生框架的拓展，提高开发效率'

  s.description      = <<-DESC
  XZExtensions 包含了对原生框架的拓展，丰富了原生框架的功能，提高了开发效率。
  DESC

  s.homepage         = 'https://github.com/Xezun/XZKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Xezun' => 'xezun@icloud.com' }
  s.source           = { :git => 'https://github.com/Xezun/XZKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'
  s.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_FRAMEWORK=1' }
  
  s.default_subspec = 'Code'
  
  s.subspec 'Code' do |ss|
    ss.source_files = 'XZKit/Code/ObjC/XZExtensions/**/*.{h,m}'
    ss.dependency 'XZDefines'
  end
  
  def s.defineSubspec(name, dependencies)
    self.subspec name do |ss|
      ss.public_header_files = "XZKit/Code/ObjC/XZExtensions/#{name}/**/*.h";
      ss.source_files        = "XZKit/Code/ObjC/XZExtensions/#{name}/**/*.{h,m}";
      for dependency in dependencies
        ss.dependency dependency;
      end
    end
  end
  
  s.defineSubspec 'CAAnimation',        [];
  s.defineSubspec 'CALayer',            [];
  s.defineSubspec 'NSArray',            [];
  s.defineSubspec 'NSAttributedString', ["XZExtensions/NSString"];
  s.defineSubspec 'NSBundle',           [];
  s.defineSubspec 'NSCharacterSet',     [];
  s.defineSubspec 'NSData',             [];
  s.defineSubspec 'NSDictionary',       ["XZExtensions/NSString", "XZExtensions/NSArray"];
  s.defineSubspec 'NSIndexSet',         [];
  s.defineSubspec 'NSObject',           ["XZExtensions/NSArray"];
  s.defineSubspec 'NSString',           ["XZExtensions/NSCharacterSet", "XZExtensions/NSData"];
  s.defineSubspec 'UIApplication',      [];
  s.defineSubspec 'UIBezierPath',       [];
  s.defineSubspec 'UIColor',            ["XZDefines/XZMacro"];
  s.defineSubspec 'UIDevice',           ["XZDefines/XZDefer"];
  s.defineSubspec 'UIFont',             ["XZDefines/XZDefer"];
  s.defineSubspec 'UIView',             [];
  s.defineSubspec 'UIImage',            ["XZDefines/XZDefer"];
  s.defineSubspec 'UIViewController',   ["XZExtensions/UIApplication", "XZDefines/XZRuntime"];
  s.defineSubspec 'XZShapeView',        [];

end

