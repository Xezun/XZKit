Pod::Spec.new do |s|
  s.name             = 'XZNavigationController'
  s.version          = '3.0.0'
  s.summary          = '导航控制器'
  s.description      = <<-DESC
  一款支持自定义导航条的自定义导航控制器。
  DESC

  s.homepage         = 'https://github.com/Xezun/XZKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Xezun' => 'xezun@icloud.com' }
  s.source           = { :git => 'https://github.com/Xezun/XZKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.readme           = "https://github.com/Xezun/XZKit/blob/main/Docs/XZNavigationController/README.md?raw=true"

  s.swift_version = '5.9'
  s.ios.deployment_target = '13.0'
  
  s.dependency "XZKit/XZNavigationController"

end

