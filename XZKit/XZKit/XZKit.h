//
//  XZKit.h
//  XZKit
//
//  Created by Xezun on 2017/12/8.
//  Copyright © 2017年 XEZUN INC. All rights reserved.
//

#import <UIKit/UIKit.h>


// 规范相关：
// 域、标识符前缀：com.xezun.XZKit.<Moudle> 。
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
//
//
// - 对于存在 Swift 版本的类的自定义类目，不再设置 NS_SWIFT_NAME ，因为它们已经不再通用。
//
// 术语翻译：
// frame: 范围
// block: 块函数


//! Project version number for XZKit.
FOUNDATION_EXPORT double XZKitVersionNumber;

//! Project version string for XZKit.
FOUNDATION_EXPORT const unsigned char XZKitVersionString[];

#import <XZKit/XZMacro.h>
#import <XZKit/XZDefines.h>
#import <XZKit/XZDebugMode.h>
#import <XZKit/XZDefer.h>
#import <XZKit/XZLog.h>
#import <XZKit/XZCharacterCase.h>
#import <XZKit/XZHexEncoding.h>
//#import <XZKit/XZRuntime.h>
//#import <XZKit/XZObjCTypeDescriptor.h>
#import <XZKit/XZTimestamp.h>
#import <XZKit/XZJSON.h>
#import <XZKit/XZGeometry.h>

// MARK: - XZGeometry
//#import <XZKit/NSValue+XZGeometry.h>
//#import <XZKit/NSCoder+XZGeometry.h>
//
//// MARK: - Category
//#import <XZKit/NSBundle+XZKit.h>
//#import <XZKit/UIImage+XZKit.h>
//#import <XZKit/UIView+XZKit.h>
//
//// MARK: - DataDigester
//#import <XZKit/XZDataDigester.h>
//#import <XZKit/NSData+XZDataDigester.h>
//#import <XZKit/NSString+XZDataDigester.h>
//
//// MARK: - DataCryptor
//#import <XZKit/XZDataCryptor.h>
//
//// MARK: - Image
//#import <XZKit/XZImage.h>
//#import <XZKit/UIImage+XZImage.h>
//
//// MARK: - Color
//#import <XZKit/XZColor.h>
//#import <XZKit/UIColor+XZColor.h>
//
//// MARK: - AppLanguage
//#import <XZKit/XZAppLanguage.h>
//#import <XZKit/NSBundle+XZAppLanguage.h>
//
//// MARK: - AppRedirection
//#import <XZKit/XZAppRedirection.h>
//
//// MARK: - CacheManager
////#import <XZKit/UIImage+XZImageCacheManager.h>
//
//
//
//// MARK: - CarouselView
//#import <XZKit/XZCarouselView.h>
//#import <XZKit/XZCarouselViewController.h>
//#import <XZKit/XZImageViewer.h>
//#import <XZKit/XZImageCarouselView.h>
//
//#import <XZKit/XZAnimatedImage.h>





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





