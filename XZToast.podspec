Pod::Spec.new do |s|
  s.name             = 'XZToast'
  s.version          = '2.0.0'
  s.summary          = '一种提示型消息展示组件'
  s.description      = <<-DESC
  按列队显示，支持上中下显示位置，支持自定义视图，支持进度的提示型消息展示组件。
  DESC

  s.homepage         = 'https://github.com/Xezun/XZKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Xezun' => 'xezun@icloud.com' }
  s.source           = { :git => 'https://github.com/Xezun/XZKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.readme           = "https://github.com/Xezun/XZKit/blob/main/README.md"

  s.swift_version = '5.9'
  s.ios.deployment_target = '13.0'
  
  # 项目配置
  s.pod_target_xcconfig = {
    # 注入 OC 编译变量
    'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_FRAMEWORK=1'
  }
  
  s.public_header_files  = "Sources/ObjC/Code/XZToast/*.h", 
                           "Sources/ObjC/Code/XZLog/*.h",
                           "Sources/ObjC/Code/XZGeometry/*.h",
                           "Sources/ObjC/Code/XZExtensions/UIApplication/*.h",
                           "Sources/ObjC/Code/XZExtensions/UIView/*.h",
                           "Sources/ObjC/Code/XZExtensions/XZShapeView/*.h"

  s.project_header_files = "Sources/ObjC/Code/XZToast/**/Private/**/*.h"

  s.source_files         = "Sources/ObjC/Code/XZToast/**/*.{h,m}",
                           "Sources/ObjC/Code/XZLog/**/*.{h,m}",
                           "Sources/ObjC/Code/XZGeometry/**/*.{h,m}",
                           "Sources/ObjC/Code/XZExtensions/UIApplication/**/*.{h,m}",
                           "Sources/ObjC/Code/XZExtensions/UIView/**/*.{h,m}",
                           "Sources/ObjC/Code/XZExtensions/XZShapeView/**/*.{h,m}"

end

