//
//  XZKit.h
//  XZKit
//
//  Created by mlibai on 2017/12/8.
//  Copyright © 2017年 mlibai. All rights reserved.
//

#import <UIKit/UIKit.h>


// 规范相关：
// 域、标识符使用 com.mlibai.XZKit.子模块 结构。
//
// EdgeInsets 命名规范：
// 1. 表示具体的边距，省略edge：contentInsets、sectionInsets
// 2. 单独使用时，不可省略edge：edgeInsetsForSection(_:)、edgeInsetsForContent(_:)
//
// 文件命名规范：文件命名统一加前缀 XZ （包括 Swift），以避免使用者直接引用源文件与项目已有文件重名问题。
//
// - 命名不可变方法，最好使用过去分词，即后缀"ed"：
// - 如果由于动词后面直接跟名词，无法添加"ed"时，则使用现在分词命名不可变方法，即后缀"ing"。
// - 当一项操作恰好能够被一个名词描述时，使用名词为不可变方法命名；加前缀"form"，为可变方法命名。


//! Project version number for XZKit.
FOUNDATION_EXPORT double XZKitVersionNumber;

//! Project version string for XZKit.
FOUNDATION_EXPORT const unsigned char XZKitVersionString[];

#ifdef COCOAPODS

// Cocoapods 会自动生成 XZKit-umbrella.h 文件，但是不会生成 XZKit.h 文件，
// 但是 Xcode 在编译 framework 后会生成 XZKit-Swift.h 文件，其中自动引用了默认的 XZKit.h 文件，
// 所以所有子框架都需要引用 XZKit.h 文件，否则无法通过编译。
//
// Cocoapods 会根据 Podfile 中 target 的层级关系生成 umbrella 文件，因此多项目时，生成的 umbrella 文件可能不同。
#if __has_include(<XZKit/XZKit-umbrella.h>)

#import <XZKit/XZKit-umbrella.h>

#else // not __has_include(<XZKit/XZKit-umbrella.h>) start.

// MARK: - Constants
#if __has_include(<XZKit/XZKitConstants.h>)
#import <XZKit/XZKitConstants.h>
#endif
#if __has_include(<XZKit/XZKit+Geometry.h>)
#import <XZKit/XZKit+Geometry.h>
#endif
#if __has_include(<XZKit/XZKit+Runtime.h>)
#import <XZKit/XZKit+Runtime.h>
#endif
#if __has_include(<XZKit/XZKit+HexadecimalEncoding.h>)
#import <XZKit/XZKit+HexadecimalEncoding.h>
#endif

// MARK: - Category
#if __has_include(<XZKit/NSData+XZKit.h>)
#import <XZKit/NSData+XZKit.h>
#endif
#if __has_include(<XZKit/NSBundle+XZKit.h>)
#import <XZKit/NSBundle+XZKit.h>
#endif
#if __has_include(<XZKit/UIImage+XZKit.h>)
#import <XZKit/UIImage+XZKit.h>
#endif
#if __has_include(<XZKit/UIColor+XZKit.h>)
#import <XZKit/UIColor+XZKit.h>
#endif
#if __has_include(<XZKit/UIView+XZKit.h>)
#import <XZKit/UIView+XZKit.h>
#endif
#if __has_include(<XZKit/NSString+XZKit.h>)
#import <XZKit/NSString+XZKit.h>
#endif

// MARK: - AppLanguage
#if __has_include(<XZKit/XZAppLanguage.h>)
#import <XZKit/XZAppLanguage.h>
#endif

// MARK: - AppRedirection
#if __has_include(<XZKit/XZAppRedirection.h>)
#import <XZKit/XZAppRedirection.h>
#endif

// MARK: - CacheManager

// MARK: - DataDigester
#if __has_include(<XZKit/XZDataDigester.h>)
#import <XZKit/XZDataDigester.h>
#endif

// MARK: - DataCryptor
#if __has_include(<XZKit/XZDataCryptor.h>)
#import <XZKit/XZDataCryptor.h>
#endif

// MARK: - CarouselView
#if __has_include(<XZKit/XZCarouselView.h>)
#import <XZKit/XZCarouselView.h>
#endif
#if __has_include(<XZKit/XZCarouselViewController.h>)
#import <XZKit/XZCarouselViewController.h>
#endif
#if __has_include(<XZKit/XZImageViewer.h>)
#import <XZKit/XZImageViewer.h>
#endif
#if __has_include(<XZKit/XZImageCarouselView.h>)
#import <XZKit/XZImageCarouselView.h>
#endif

#endif // not __has_include(<XZKit/XZKit-umbrella.h>) end.


#else // not with COCOAPODS start.


// MARK: - Constants
#import <XZKit/XZKitConstants.h>
#import <XZKit/XZKit+Geometry.h>
#import <XZKit/XZKit+Runtime.h>
#import <XZKit/XZKit+HexadecimalEncoding.h>
#import <XZKit/NSData+XZKit.h>

// MARK: - Category
#import <XZKit/NSBundle+XZKit.h>
#import <XZKit/UIImage+XZKit.h>
#import <XZKit/UIColor+XZKit.h>
#import <XZKit/UIView+XZKit.h>
#import <XZKit/NSString+XZKit.h>

// MARK: - AppLanguage
#import <XZKit/XZAppLanguage.h>

// MARK: - AppRedirection
#import <XZKit/XZAppRedirection.h>

// MARK: - CacheManager
//#import <XZKit/UIImage+XZImageCacheManager.h>

// MARK: - DataDigester
#import <XZKit/XZDataDigester.h>

//#import <XZKit/NSString+XZDataDigester.h>

// MARK: - DataCryptor
#import <XZKit/XZDataCryptor.h>

// MARK: - CarouselView
#import <XZKit/XZCarouselView.h>
#import <XZKit/XZCarouselViewController.h>
#import <XZKit/XZImageViewer.h>
#import <XZKit/XZImageCarouselView.h>


#endif // not with COCOAPODS end.



// MARK: - Theme
//#import <XZKit/XZTheme.h>
//#import <XZKit/XZThemeDefines.h>
//#import <XZKit/XZThemeAttribute.h>
//#import <XZKit/XZThemeStyle.h>
//#import <XZKit/XZThemeState.h>
//#import <XZKit/XZThemeStyleValueParser.h>
//
//#import <XZKit/NSObject+XZTheme.h>
//#import <XZKit/UIView+XZTheme.h>
//#import <XZKit/UIViewController+XZTheme.h>
//#import <XZKit/UINavigationItem+XZTheme.h>
//
//#import <XZKit/XZThemeStyle+UIView.h>
//#import <XZKit/XZThemeStyle+UITabBarItem.h>
//#import <XZKit/XZThemeStyle+UIButton.h>
//#import <XZKit/XZThemeStyle+UILabel.h>
//#import <XZKit/XZThemeStyle+UITabBar.h>
//#import <XZKit/XZThemeStyle+UIImageView.h>





