//
//  XZLocale.h
//  XZLocale
//
//  Created by Xezun on 2024/9/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// App 语言，如 cn、en、ar 等。
typedef NSString *XZLocaleLanguage NS_EXTENSIBLE_STRING_ENUM NS_SWIFT_NAME(XZLocale.Language);

/// 简体中文，符号为 zh-Hans 字符串。
///
/// - `>= iOS 7.0`: zh-HK（香港繁体）
/// - `< iOS 9.0`: zh-Hans（简体）、zh-Hant（繁体）
/// - `>= iOS 9.0`: zh-Hans-CN（简体）、zh-Hant-CN（繁体）、zh-TW（台湾繁体）
FOUNDATION_EXPORT XZLocaleLanguage const XZLocaleLanguageChinese            NS_SWIFT_NAME(XZLocaleLanguage.Chinese);
/// 繁体中文，符号为 zh-Hant 字符串。
FOUNDATION_EXPORT XZLocaleLanguage const XZLocaleLanguageChineseTraditional NS_SWIFT_NAME(XZLocaleLanguage.ChineseTraditional);
/// 英文，符号为 en 字符串。
FOUNDATION_EXPORT XZLocaleLanguage const XZLocaleLanguageEnglish            NS_SWIFT_NAME(XZLocaleLanguage.English);

/// 语言偏好设置发生改变。
///
/// 如果页面没有为偏好语言配置本地化资源，那么实际显示语言可能并未改变。
FOUNDATION_EXPORT NSNotificationName const XZLocaleDidChangePreferredLanguageNotification NS_SWIFT_NAME(XZLocale.didChangePreferredLanguageNotification);

@class NSBundle;

/// 本地化支持组件。
///
/// 读取本地化字符串，推荐使用本组件建提供的宏，支持在本地化字符串中使用参数（最多支持 64 个参数）。
///
/// ```objc
/// XZLocalizedString(key, ...)
/// ```
///
/// 示例：以中文为本地化的默认语言时，展示某人在某时去过某地，比如，小明在10月1日去过天安门，如下代码。
///
/// ```objc
/// self.textLabel.text = XZLocalizedString(@"{1}在{2}去过{3}。", data.name, data.date, data.spot);
/// ```
///
/// 那么，在进行英文本地化时，就可以像下面这样配置本地化字符串表。
///
/// ```objc
/// "{1}在{2}去过{3}。" = "{1} went to {3} on {2}.";
/// ```
///
/// 虽然英文和中文的语序并不一致，但是在代码中，我们不需要调整的参数的书写顺序，只需要调整本地化字符串引用参数的顺序即可。
///
/// > 虽然 `NSString` 已支持的使用 `%n$` 指定参数顺序，比如 `%2$@` 表示第 2 个参数，但是 `XZLocale` 的设计目录是为与其它平台保持一致。
///
/// 由于 OC 参数列表限制，值 nil 之后的参数会被忽略。
///
/// > 虽然查找字符串中的参数的插值，会有产生额外操作，但是当本地化字符串没有参数时，使用的是原生的本地化方法，实际对性能影响已降至最低。
@interface XZLocale : NSObject

- (instancetype)init NS_UNAVAILABLE;

/// 当前生效的语言。
///
/// 该属性只能表明在创建新 UI 时生效的语言，不表示当前已有 UI 的显示语言。
@property (class, readonly) XZLocaleLanguage effectiveLanguage;

/// 应用首选语言。
///
/// 更新首选语言，默认需重启应用才会生效。
///
/// 结合 `isInAppLanguagePreferenceEnabled` 属性，可以开启在应用内切换应用语言。
///
/// ```objc
/// UIWindow * const window = _window;
/// CGRect const bounds = UIScreen.mainScreen.bounds;
///
/// _window = [[UIWindow alloc] initWithFrame:bounds];
/// _window.backgroundColor = UIColor.whiteColor;
/// UIViewController *rootVC = [UIStoryboard storyboardWithName:@"Main" bundle:nil].instantiateInitialViewController;
/// _window.rootViewController = rootVC;
/// [_window makeKeyAndVisible];
///
/// // 转场动画
/// _window.layer.shadowColor = UIColor.blackColor.CGColor;
/// _window.layer.shadowOpacity = 0.5;
/// _window.layer.shadowRadius = 5.0;
/// _window.windowLevel = window.windowLevel + 1;
/// _window.frame = CGRectOffset(bounds, bounds.size.height, 0);
/// [UIView animateWithDuration:0.5 animations:^{
///     self->_window.frame = bounds;
/// } completion:^(BOOL finished) {
///     window.hidden = YES; // 释放旧的 window
///     self->_window.layer.shadowColor = nil;
/// }];
/// ```
@property (class, nonatomic, copy) XZLocaleLanguage preferredLanguage;

/// 语言的书写方向。
/// - Parameter language: 语言
+ (NSLocaleLanguageDirection)languageDirectionForLanguage:(XZLocaleLanguage)language;

/// 应用支持的所有语言。
@property (class, nonatomic, copy, readonly) NSArray<XZLocaleLanguage> *supportedLanguages;

/// 是否开启应用内语言偏好设置。默认否。
///
/// 开启功能后，更改应用语言立即生效，新的页面将按照新的语言展示。
@property (class, nonatomic) BOOL supportsInAppLanguagePreferences;

/// 构造本地化字符串。
/// - Parameters:
///   - key: 本地化字符串或键
///   - table: 本地化表
///   - bundle: 表所在的包
///   - value: 默认值
///   - arguments: 参数列表
+ (NSString *)localizedStringForKey:(NSString *)key value:(nullable NSString *)value table:(nullable NSString *)table bundle:(nullable NSBundle *)bundle arguments:(nullable va_list)arguments;

/// 字符串本地化便利函数。请直接使用 `XZLocalizedString` 宏，而非此函数。
///  
/// 支持在本地化字符串中，使用形如 {1}、{2}、{3} 的参数占位符，其中的数字表示参数的顺序，参数必须为对象。
///
/// - Note: not for direct use
///  
/// - Parameters:
///   - key: 需要本地化字符串
///   - table: 本地化字符串表
///   - bundle: 本地化字符串包
///   - value: 默认字符
/// - Returns: 已本地化的字符串
+ (NSString *)localizedStringForKey:(NSString *)key value:(nullable NSString *)value table:(nullable NSString *)table bundle:(nullable NSBundle *)bundle, ... NS_REQUIRES_NIL_TERMINATION;

@end

@class NSArray;

@interface NSBundle (XZLocale)
/// 获取指定语言的语言包。如果没有找到语言包，则返回自身。
/// - Parameter language: 语言
- (NSBundle *)xz_languageResourceBundleForLanguage:(XZLocaleLanguage)language NS_SWIFT_NAME(resourceBundle(for:));
@end

#ifndef XZLocalizedString
        
#define _XZLocalTranslate(_key_, _table_, _bundle_, _value_, ...) [XZLocale localizedStringForKey:(_key_) value:(_value_) table:(_table_) bundle:(_bundle_), ##__VA_ARGS__, nil]

#define _XZLocalImplement(_00, \
_01, _02, _03, _04, _05, _06, _07, _08, _09, _10, \
_11, _12, _13, _14, _15, _16, _17, _18, _19, _20, \
_21, _22, _23, _24, _25, _26, _27, _28, _29, _30, \
_31, _32, _33, _34, _35, _36, _37, _38, _39, _40, \
_41, _42, _43, _44, _45, _46, _47, _48, _49, _50, \
_51, _52, _53, _54, _55, _56, _57, _58, _59, _60, \
_61, _62, _63, _64, _65, ...) _65

#define XZLocalizedString(key, ...) \
_XZLocalImplement(64, ##__VA_ARGS__, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, NSLocalizedStringWithDefaultValue)(key, nil, NSBundle.mainBundle, @"", ##__VA_ARGS__)

#define XZLocalizedStringFromTable(key, table, ...) \
_XZLocalImplement(64, ##__VA_ARGS__, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, NSLocalizedStringWithDefaultValue)(key, table, NSBundle.mainBundle, @"", ##__VA_ARGS__)

#define XZLocalizedStringFromTableInBundle(key, table, bundle, ...) \
_XZLocalImplement(64, ##__VA_ARGS__, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, NSLocalizedStringWithDefaultValue)(key, table, bundle, @"", ##__VA_ARGS__)

#define XZLocalizedStringWithDefaultValue(key, table, bundle, value, ...) \
_XZLocalImplement(64, ##__VA_ARGS__, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, \
_XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, _XZLocalTranslate, NSLocalizedStringWithDefaultValue)(key, table, bundle, value, ##__VA_ARGS__)

#endif // <= #ifndef XZLocalizedString

NS_ASSUME_NONNULL_END
