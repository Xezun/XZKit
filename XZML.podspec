Pod::Spec.new do |s|
  s.name             = 'XZML'
  s.version          = '3.0.0'
  s.summary          = '超文本标记语言'
  s.description      = <<-DESC
  一款用于快速创建富文本的轻量级的超文本标记语法。
  DESC

  s.homepage         = 'https://github.com/Xezun/XZKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Xezun' => 'xezun@icloud.com' }
  s.source           = { :git => 'https://github.com/Xezun/XZKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.readme           = "https://github.com/Xezun/XZKit/blob/main/Docs/XZML/README.md?raw=true"

  s.swift_version = '5.9'
  s.ios.deployment_target = '13.0'
  
  s.dependency "XZKit/XZML"

end

