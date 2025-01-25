#
# Be sure to run `pod lib lint XZKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XZKit'
  s.version          = '10.2.0'
  s.summary          = 'XZKit'
  s.description      = <<-DESC
                       XZKit三方拓展组件
                       DESC

  s.homepage         = 'https://github.com/Xezun/XZKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Xezun' => 'xezun@icloud.com' }
  s.source           = { :git => 'https://github.com/Xezun/XZKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.swift_version = '6.0'
  s.ios.deployment_target = '12.0'
  s.pod_target_xcconfig = {
    'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_FRAMEWORK=1',
    'OTHER_SWIFT_FLAGS' => '-D XZ_FRAMEWORK'
  }
  
  s.default_subspec = 'Code'
  
  s.subspec 'Code' do |ss|
    ss.public_header_files = 'XZKit/Code/ObjC/XZKit/**/*.h'
    ss.source_files        = 'XZKit/Code/ObjC/XZKit/**/*.{h,m}'
    # ss.project_header_files = 'XZKit/Code/**/Private/*.h'
    ss.dependency 'XZDefines'
    ss.dependency 'XZExtensions'
    ss.dependency 'XZCollectionViewFlowLayout'
    ss.dependency 'XZContentStatus'
    ss.dependency 'XZDataCryptor'
    ss.dependency 'XZDataDigester'
    ss.dependency 'XZGeometry'
    ss.dependency 'XZJSON'
    ss.dependency 'XZKeychain'
    ss.dependency 'XZLocale'
    ss.dependency 'XZML'
    ss.dependency 'XZMocoa'
    ss.dependency 'XZNavigationController'
    ss.dependency 'XZPageControl'
    ss.dependency 'XZPageView'
    ss.dependency 'XZRefresh'
    ss.dependency 'XZSegmentedControl'
    ss.dependency 'XZTextImageView'
    ss.dependency 'XZToast'
    ss.dependency 'XZURLQuery'
  end
  
#  s.subspec 'DEBUG' do |ss|
#    ss.dependency 'XZKit/Code'
#    ss.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_DEBUG=1' }
#  end
  
  # s.resource_bundles = {
  #   'XZDefines' => ['XZDefines/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

end

