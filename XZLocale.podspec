#
# Be sure to run `pod lib lint XZLocale.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XZLocale'
  s.version          = '10.2.0'
  s.summary          = 'XZLocale 本地化支持组件'

  s.description      = <<-DESC
  组件 XZLocale 增加了原生的本地化功能，支持在本地化字符串中使用参数。
  DESC

  s.homepage         = 'https://github.com/Xezun/XZKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Xezun' => 'xezun@icloud.com' }
  s.source           = { :git => 'https://github.com/Xezun/XZKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.swift_version = '6.0'
  s.ios.deployment_target = '12.0'
  s.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_FRAMEWORK=1' }
  
  s.subspec 'Code' do |ss|
    ss.source_files = 'XZKit/Code/ObjC/XZLocale/**/*.{h,m}'
    ss.dependency 'XZDefines/XZRuntime'
  end
  
end

