#
# Be sure to run `pod lib lint XZKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
# pod lib lint --verbose

Pod::Spec.new do |s|
  
    s.cocoapods_version = ">= 1.7.2"
  
    s.name    = "XZKit"
    s.version = "4.3.3"
    s.summary = "XZKit 封装了 iOS App 开发过程中常用的功能和组件!"
    
    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!
    
    s.description = <<-DESC
                    本框架主要包含：常用拓展库、多线程、缓存、数据摘要和加密、视图状态组件、自定义导航控制器及导航条、网络框架规范、控制器重定向、
                    轮播组件和轮播图、进度条、UICollectionView 自定义布局、App 内容语言切换等功能。
                    DESC
    
    s.homepage = 'https://xzkit.xezun.com'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license  = { :type => 'MIT', :file => 'LICENSE' }
    s.author   = { 'mlibai' => 'developer@xezun.com' }
    s.source   = { :git => 'https://github.com/xezun/XZKit.git', :tag => s.version.to_s }
    s.social_media_url = 'https://xzkit.xezun.com/'
    
    s.module_name    = 'XZKit'
    s.swift_versions = ["4.2", "5.0"]
    s.requires_arc   = true
    s.ios.deployment_target = '8.0'
    
    s.xcconfig = {
        "GCC_PREPROCESSOR_DEFINITIONS" => '$(inherited) XZKIT_FRAMEWORK=1'
    }
    # s.pod_target_xcconfig = {
    #     'OTHER_CFLAGS' => '-fembed-bitcode'
    #     'DEFINES_MODULE' => 'YES'
    # }
    
    # 使用 .framework 作为 Pods 源时。
    # s.vendored_frameworks = 'Products/XZKit.framework'
    
    # 框架文件和公共头文件。
    # XZKit.h 没有这个头文件会导致无法编译，Xcode 编译 framework 时自动生成的桥接头文件 XZKit-Swift.h 文件包含该文件。
    s.public_header_files = "XZKit/Code/XZKit.h"
    s.source_files = "XZKit/Code/XZKit.h"
    # 因为分成了多个子模块，指定单一 modulemap 无法适应所有情况，所以需要 Pods 自动生成 modulemap ，而不能指定。
    # s.module_map = 'XZKit/XZKit/module.modulemap'
    # s.frameworks = 'UIKit'
    # s.dependency 'AFNetworking', '~> 2.3'
    
    # 默认使用 XZKit.framework
    # s.default_subspecs = "XZKit"

    # 源代码，整个框架。
    # s.subspec "XZKit" do |ss|
    #     # ss.resource_bundles = {
    #         # 须使用 +bundleForClass: 方法构造的 NSBundle 来获取资源。
    #         # +bundleWithIdentifier: 构造的 NSBundle 无法获取资源 iOS 11，原因未知。
    #     #    'XZKit' => ['XZKit/Resource/Assets.xcassets']
    #     # }
    #     ss.public_header_files = 'XZKit/Code/**/*.h'
    #     ss.source_files = 'XZKit/Code/**/*.{h,m,swift}'
    # end

    # 子框架 
    
    # 已编译的框架包。
    # s.subspec 'Framework' do |ss|
    #     ss.vendored_frameworks = 'Products/XZKit.framework'
    # end

    s.subspec 'XZKitConstants' do |ss|
      ss.public_header_files = 'XZKit/Code/XZKit.h',
                               'XZKit/Code/XZKitConstants/**/*.h'
      ss.source_files = 'XZKit/Code/XZKit.h',
                        'XZKit/Code/XZKitConstants/**/*.{h,m,swift}'
    end
    
    s.subspec 'AppLanguage' do |ss|
        ss.public_header_files = 'XZKit/Code/XZKit.h',
                                 'XZKit/Code/AppLanguage/**/*.h'
        ss.source_files = 'XZKit/Code/XZKit.h',
                          'XZKit/Code/AppLanguage/**/*.{h,m,swift}'
                          
        ss.dependency 'XZKit/XZKitConstants'
    end
    
    s.subspec 'AppRedirection' do |ss|
        ss.public_header_files = 'XZKit/Code/XZKit.h',
                                 'XZKit/Code/AppRedirection/*.h'
        ss.source_files = 'XZKit/Code/XZKit.h',
                          'XZKit/Code/AppRedirection/*.{h,m,swift}'

        ss.dependency "XZKit/XZKitConstants"
    end
    
    s.subspec 'CacheManager' do |ss|
        ss.public_header_files = 'XZKit/Code/XZKit.h',
                                 'XZKit/Code/CacheManager/*.h'
        ss.source_files = 'XZKit/Code/XZKit.h',
                          'XZKit/Code/CacheManager/*.{h,m,swift}'

        ss.dependency 'XZKit/Foundation'
    end
    
    s.subspec 'CarouselView' do |ss|
        ss.public_header_files = 'XZKit/Code/XZKit.h',
                                 'XZKit/Code/CarouselView/Public/**/*.h'
        ss.source_files = 'XZKit/Code/XZKit.h',
                          'XZKit/Code/CarouselView/**/*.{h,m,swift}'
       
       ss.dependency "XZKit/XZKitConstants"
    end
    
    s.subspec 'ContentStatus' do |ss|
        ss.public_header_files = 'XZKit/Code/XZKit.h'
        ss.source_files = 'XZKit/Code/XZKit.h',
                          'XZKit/Code/ContentStatus/*.{h,m,swift}'

        ss.dependency "XZKit/TextImageView"
    end
    
    s.subspec 'DataCryptor' do |ss|
        ss.public_header_files = 'XZKit/Code/XZKit.h',
                                 'XZKit/Code/DataCryptor/*.h'
        ss.source_files = 'XZKit/Code/XZKit.h',
                          'XZKit/Code/DataCryptor/*.{h,m,swift}'
    end
    
    s.subspec 'DataDigester' do |ss|
        ss.public_header_files = 'XZKit/Code/XZKit.h',
                                 'XZKit/Code/DataDigester/*.h'
        ss.source_files = 'XZKit/Code/XZKit.h',
                          'XZKit/Code/DataDigester/*.{h,m,swift}'

        ss.dependency "XZKit/XZKitConstants"
    end
    
    s.subspec 'Foundation' do |ss|
        ss.public_header_files = 'XZKit/Code/XZKit.h',
                                 'XZKit/Code/Foundation/**/*.h'
        ss.source_files = 'XZKit/Code/XZKit.h',
                          'XZKit/Code/Foundation/**/*.{h,m,swift}'
                        
        ss.dependency "XZKit/XZKitConstants"
        ss.dependency "XZKit/DataDigester"
        ss.dependency "XZKit/DataCryptor"
    end
    
    s.subspec 'NavigationController' do |ss|
        ss.public_header_files = 'XZKit/Code/XZKit.h'
        ss.source_files = 'XZKit/Code/XZKit.h',
                          'XZKit/Code/NavigationController/*.{h,m,swift}'

        ss.dependency "XZKit/XZKitConstants"
    end
    
    s.subspec 'Networking' do |ss|
        ss.public_header_files = 'XZKit/Code/XZKit.h'
        ss.source_files = 'XZKit/Code/XZKit.h',
                          'XZKit/Code/Networking/*.{h,m,swift}'
    end
    
    s.subspec 'ProgressView' do |ss|
        ss.public_header_files = 'XZKit/Code/XZKit.h'
        ss.source_files = 'XZKit/Code/XZKit.h',
                          'XZKit/Code/ProgressView/*.{h,m,swift}'
    end

    s.subspec 'DisplayTimer' do |ss|
        ss.public_header_files = 'XZKit/Code/XZKit.h'
        ss.source_files = 'XZKit/Code/XZKit.h',
                          'XZKit/Code/DisplayTimer/*.{h,m,swift}'
    end

    s.subspec 'TextImageView' do |ss|
        ss.public_header_files = 'XZKit/Code/XZKit.h', 
                                 'XZKit/Code/TextImageView/*.h'
        ss.source_files = 'XZKit/Code/XZKit.h',
                          'XZKit/Code/TextImageView/*.{h,m,swift}'
                          
        ss.dependency "XZKit/XZKitConstants"
    end
    
    s.subspec 'UICollectionViewFlowLayout' do |ss|
        ss.public_header_files = 'XZKit/Code/XZKit.h'
        ss.source_files = 'XZKit/Code/XZKit.h',
                          'XZKit/Code/UICollectionViewFlowLayout/*.{h,m,swift}'

        ss.dependency "XZKit/XZKitConstants"
    end
    
    s.subspec 'UIKit' do |ss|
        ss.public_header_files = 'XZKit/Code/XZKit.h',
                                 'XZKit/Code/UIKit/**/*.h'
        ss.source_files = 'XZKit/Code/XZKit.h',
                          'XZKit/Code/UIKit/**/*.{h,m,swift}'

        ss.dependency "XZKit/XZKitConstants"
        ss.dependency "XZKit/Foundation"
        ss.dependency "XZKit/CacheManager"
    end
    
end
