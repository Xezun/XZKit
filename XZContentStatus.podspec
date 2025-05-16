#
# Be sure to run `pod lib lint XZContentStatus.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XZContentStatus'
  s.version          = '10.8.0'
  s.summary          = '页面状态提示控件'

  s.description      = <<-DESC
  更方便的处理页面状态的显示，提高开发效率
  DESC

  s.homepage         = 'https://github.com/Xezun/XZKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Xezun' => 'xezun@icloud.com' }
  s.source           = { :git => 'https://github.com/Xezun/XZKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.readme           = "https://github.com/Xezun/XZKit/blob/main/Docs/#{s.name}/README.md"

  s.swift_version = '5.0'
  s.ios.deployment_target = '13.0'
  s.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_FRAMEWORK=1' }
  
  s.default_subspec = 'Code'
  
  s.subspec 'Code' do |ss|
    ss.dependency 'XZTextIconView'
    ss.source_files = 'XZKit/Code/Swift/XZContentStatus/**/*.{h,m,swift}'
  end
  
  s.subspec 'DEBUG' do |ss|
    ss.dependency "#{s.name}/Code"
    ss.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_DEBUG=1' }
  end
  
end

