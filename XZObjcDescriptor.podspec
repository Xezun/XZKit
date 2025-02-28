#
# Be sure to run `pod lib lint XZObjcDescriptor.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#



Pod::Spec.new do |s|
  s.name             = 'XZObjcDescriptor'
  s.version          = '10.6.0'
  s.summary          = 'ObjC 运行时面向对象'

  s.description      = <<-DESC
  运行时底层元素的面向对象描述。
  DESC

  s.homepage         = 'https://github.com/Xezun/XZKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Xezun' => 'xezun@icloud.com' }
  s.source           = { :git => 'https://github.com/Xezun/XZKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.readme           = 'https://github.com/Xezun/XZKit/blob/main/Docs/#{s.name}/README.md'

  s.swift_version = '6.0'
  s.ios.deployment_target = '12.0'
  s.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_FRAMEWORK=1' }
  
  s.default_subspec = 'Code'
  
  s.subspec 'Code' do |ss|
    ss.public_header_files = 'XZKit/Code/ObjC/XZObjcDescriptor/**/*.h'
    ss.source_files        = 'XZKit/Code/{ObjC,Swift}/XZObjcDescriptor/**/*.{h,m,swift}'
    ss.dependency 'XZDefines/XZMacro'
  end
  
end

