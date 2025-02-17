#
# Be sure to run `pod lib lint XZJSON.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XZJSON'
  s.version          = '10.2.0'
  s.summary          = '一款高效的 JSON 数据模型化工具'

  s.description      = <<-DESC
  基于 YYModel 打造，进行了大量优化，支持任意数据的模型化；采用了“工具类+协议”的方式实现，降低对原生代码的侵入，更符合 Apple 接口设计风格。
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
    ss.source_files = 'XZKit/Code/ObjC/XZJSON/**/*.{h,m}'
    ss.project_header_files = 'XZKit/Code/ObjC/XZJSON/**/Private/*.h'
    ss.dependency 'XZObjcDescriptor'
  end
  
end

