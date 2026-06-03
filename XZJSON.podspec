Pod::Spec.new do |s|
  s.name             = 'XZJSON'
  s.version          = '3.0.0'
  s.summary          = 'JSON工具'
  s.description      = <<-DESC
  一款用于 JSON 序列化和模型化的高性能工具。
  DESC

  s.homepage         = 'https://github.com/Xezun/XZKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Xezun' => 'xezun@icloud.com' }
  s.source           = { :git => 'https://github.com/Xezun/XZKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.readme           = "https://github.com/Xezun/XZKit/blob/main/Docs/XZJSON/README.md?raw=true"

  s.swift_version = '5.9'
  s.ios.deployment_target = '13.0'
  
  s.dependency "XZKit/XZJSON"

end

