#
# Be sure to run `pod lib lint XZCollectionViewFlowLayout.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XZCollectionViewFlowLayout'
  s.version          = '10.10.0'
  s.summary          = '支持多种对齐方式的 UICollectionView 流布局。'

  s.description      = <<-DESC
  为 UICollectionView 添加支持 leading、trailing、center、justified 等多种对齐方式的布局方案。
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
  
  s.default_subspec = 'Code'
  
  s.subspec 'Code' do |ss|
    ss.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_FRAMEWORK=1' }
    
    ss.source_files = 'XZKit/Code/Swift/XZCollectionViewFlowLayout/**/*.swift'
  end
  
end

