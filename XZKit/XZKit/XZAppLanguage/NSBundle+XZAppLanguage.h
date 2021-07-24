//
//  NSBundle+XZAppLanguage.h
//  XZKit
//
//  Created by Xezun on 2021/2/6.
//

#import <Foundation/Foundation.h>
#import <XZKit/XZAppLanguage.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (XZAppLanguage)

/// 是否支持 App 内语言切换。默认 NO。
/// @note 该属性会在切换语言时自动打开。
@property (nonatomic, readonly) BOOL xz_supportsInAppLanguageSwitching NS_SWIFT_NAME(supportsInAppLanguageSwitching);

/// 获取指定语言的语言包。
///
/// @param language 语言。
/// @return 语言包。
- (nullable NSBundle *)xz_resourceBundleForLanguage:(XZAppLanguage)language NS_SWIFT_NAME(resourceBundle(for:));

/// 获取指定语言的国际化字符串。
- (NSString *)xz_localizedStringForLanguage:(XZAppLanguage)language Key:(NSString *)key value:(nullable NSString *)value table:(nullable NSString *)tableName NS_SWIFT_NAME(localizedString(for:key:value:table:));

@end

NS_ASSUME_NONNULL_END
