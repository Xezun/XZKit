#
# Be sure to run `pod lib lint XZCollectionViewFlowLayout.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XZCollectionViewFlowLayout'
  s.version          = '10.1.0'
  s.summary          = '支持多种对齐方式的 UICollectionView 流布局。'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                      为 UICollectionView 添加支持 leading、trailing、center、justified 等多种对齐方式的布局方案。 
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
  
  s.default_subspec = 'Code'
  
  s.subspec 'Code' do |ss|
    ss.source_files = 'XZKit/Code/XZCollectionViewFlowLayout/**/*.swift'
    # ss.project_header_files = 'XZCollectionViewFlowLayout/Code/**/Private/*.h'
  end
  
  s.subspec 'Debug' do |ss|
    ss.dependency 'XZCollectionViewFlowLayout/Code'
    ss.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_DEBUG=1' }
  end
  
  # s.resource_bundles = {
  #   'XZCollectionViewFlowLayout' => ['XZCollectionViewFlowLayout/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

