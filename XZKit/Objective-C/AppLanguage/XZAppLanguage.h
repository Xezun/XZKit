//
//  XZAppLanguage.h
//  XZKit
//
//  Created by Xezun on 2018/7/26.
//  Copyright © 2018年 XEZUN INC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// App 语言，如 cn、en、ar 等。
typedef NSString *XZAppLanguage NS_EXTENSIBLE_STRING_ENUM NS_SWIFT_NAME(AppLanguage);

/// 语言设置发生改变通知。
FOUNDATION_EXTERN NSNotificationName const XZAppLanguagePreferenceDidChangeNotification NS_SWIFT_NAME(AppLanguage.preferenceDidChangeNotification);
/// 语言设置改变通知中，当前偏好语言所用的 UserInfoKey 。
FOUNDATION_EXTERN NSString * const XZAppLanguagePreferenceUserInfoKey NS_SWIFT_NAME(AppLanguage.preferredLanguageUserInfoKey);
/// App 默认设置语言在 UserDefaults 中使用的键名。
FOUNDATION_EXTERN NSString * const XZAppLanguageUserDefaultsKey NS_SWIFT_NAME(AppLanguage.userDefaultsKey);


@interface NSUserDefaults (XZAppLanguage)

/// App 第一偏好语言，如 cn、en、ar 等。
/// @note 设置的语言必须是包所支持的语言。
/// @note 设置语言会将改变当前对象的类型，以启用 App 内容语言切换支持。
/// @note 某些语言的布局方向可能与当前语言不一致，需要开发者自行处理布局方向的问题（iOS 9以后使用 UIView.semanticContentAttribute 属性可以解决大部分布局方向的问题）。
/// @note 在 Swift 中，可使用 AppLanguage.preferred 代替此属性。
@property (nonatomic, nonnull, setter=xz_setPreferredLanguage:) XZAppLanguage xz_preferredLanguage NS_SWIFT_NAME(preferredLanguage);

@end


/// 英语 en 。
FOUNDATION_EXTERN XZAppLanguage const XZAppLanguageEnglish NS_SWIFT_NAME(AppLanguage.English);
/// 汉语 zh 。
FOUNDATION_EXTERN XZAppLanguage const XZAppLanguageChinese NS_SWIFT_NAME(AppLanguage.Chinese);
/// 法语 fr 。
FOUNDATION_EXTERN XZAppLanguage const XZAppLanguageFrench NS_SWIFT_NAME(AppLanguage.French);
/// 西班牙语 es 。
FOUNDATION_EXTERN XZAppLanguage const XZAppLanguageSpanish NS_SWIFT_NAME(AppLanguage.Spanish);
/// 葡萄牙语 pt 。
FOUNDATION_EXTERN XZAppLanguage const XZAppLanguagePortuguese NS_SWIFT_NAME(AppLanguage.Portuguese);
/// 俄罗斯语 ru 。
FOUNDATION_EXTERN XZAppLanguage const XZAppLanguageRussian NS_SWIFT_NAME(AppLanguage.Russian);
/// 阿拉伯语 ar 。
FOUNDATION_EXTERN XZAppLanguage const XZAppLanguageArabic NS_SWIFT_NAME(AppLanguage.Arabic);
/// 德语 de 。
FOUNDATION_EXTERN XZAppLanguage const XZAppLanguageGerman NS_SWIFT_NAME(AppLanguage.German);
/// 日语 ja 。
FOUNDATION_EXTERN XZAppLanguage const XZAppLanguageJapanese NS_SWIFT_NAME(AppLanguage.Japanese);



NS_ASSUME_NONNULL_END

