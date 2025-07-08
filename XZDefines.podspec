#
# Be sure to run `pod lib lint XZDefines.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XZDefines'
  s.version          = '10.10.0'
  s.summary          = 'XZKit 的基础部分'

  s.description      = <<-DESC
  XZDefines 包含 XZKit 中常用的一些基础定义。
  DESC

  s.homepage         = 'https://github.com/Xezun/XZKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Xezun' => 'xezun@icloud.com' }
  s.source           = { :git => 'https://github.com/Xezun/XZKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.readme           = "https://github.com/Xezun/XZKit/blob/main/Docs/#{s.name}/README.md"
  
  s.swift_version = '5.9'
  s.ios.deployment_target = '13.0'
  
  s.default_subspec = 'Code'

  s.subspec 'Code' do |ss|
    ss.public_header_files = 'XZKit/Code/ObjC/XZDefines/**/*.h'
    ss.source_files        = 'XZKit/Code/{ObjC,Swift}/XZDefines/**/*.{h,m,swift}'
    
    ss.dependency 'XZLog'
  end
  
end

