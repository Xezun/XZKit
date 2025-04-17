#
# Be sure to run `pod lib lint XZSegmentedControl.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XZSegmentedControl'
  s.version          = '10.5.0'
  s.summary          = 'A customizable segmented control for iOS'

  s.description      = <<-DESC
  XZSegmentedControl is a powerfull customizable replacement of UISegmentedControl。
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
    ss.source_files = 'XZKit/Code/ObjC/XZSegmentedControl/**/*.{h,m}'
    ss.project_header_files = 'XZKit/Code/ObjC/XZSegmentedControl/**/Private/*.h'
    ss.dependency 'XZDefines/XZMacro'
  end
  
  s.subspec 'DEBUG' do |ss|
    ss.dependency 'XZSegmentedControl/Code'
    ss.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_DEBUG=1' }
  end
  
  s.subspec 'DEBUG' do |ss|
    ss.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_DEBUG=1' }
  end

end

