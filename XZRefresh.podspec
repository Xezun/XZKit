Pod::Spec.new do |s|
  s.name             = 'XZRefresh'
  s.version          = '3.0.0'
  s.summary          = 'iOS史上最流畅的下拉刷新组件'
  s.description      = <<-DESC
  拓展 UIScrollView 支持下拉/上拉刷新功能，支持自定义刷新视图，支持控制刷新过程。
  DESC

  s.homepage         = 'https://github.com/Xezun/XZKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Xezun' => 'xezun@icloud.com' }
  s.source           = { :git => 'https://github.com/Xezun/XZKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.readme           = "https://github.com/Xezun/XZKit/blob/main/Docs/XZRefresh/README.md?raw=true"

  s.swift_version = '5.9'
  s.ios.deployment_target = '13.0'
  
  s.dependency "XZKit/XZRefresh"

end

