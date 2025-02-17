#
# Be sure to run `pod lib lint XZDataDigester.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#



Pod::Spec.new do |s|
  s.name             = 'XZDataDigester'
  s.version          = '10.2.0'
  s.summary          = '对原生框架 CommonDigest 的封装，提高开发效率。'

  s.description      = <<-DESC
  XZDataDigester 对 CommonDigest 进行了封装，提供了面向对象的接口，使用更顺手，提高开发效率。
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
    ss.source_files = 'XZKit/Code/ObjC/XZDataDigester/**/*.{h,m}'
    ss.dependency 'XZExtensions/NSData'
    ss.dependency 'XZDefines/XZDefer'
  end
  
end

