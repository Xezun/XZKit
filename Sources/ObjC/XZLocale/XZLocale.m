//
//  XZLocale.m
//  XZLocale
//
//  Created by Xezun on 2024/9/15.
//

#import "XZLocale.h"
#import "XZRuntime.h"
#import "XZMacros.h"
#import "NSString+XZKit.h"
@import ObjectiveC;

XZLocaleLanguage   const XZLocaleLanguageChinese            = @"zh-Hans";
XZLocaleLanguage   const XZLocaleLanguageChineseTraditional = @"zh-Hant";
XZLocaleLanguage   const XZLocaleLanguageEnglish            = @"en";
NSNotificationName const XZLocaleDidChangePreferredLanguageNotification = @"XZLocaleDidChangePreferredLanguageNotification";

/// 语言偏好设置在 NSUserDefaults 中的键名。
static NSString * const AppleLanguages = @"AppleLanguages";
/// 记录了当前的语言偏好设置。
static XZLocaleLanguage _Nullable _preferredLanguage = nil;
/// 是否开启应用内切换语言功能。
static BOOL _supportsInAppLanguagePreferences    = NO;
/// 是否支持应用内切换语言功能。
static BOOL _isInAppLanguagePreferencesSupported  = NO;

@implementation XZLocale

+ (XZLocaleLanguage)effectiveLanguage {
    NSBundle * const mainBundle = NSBundle.mainBundle;
    return mainBundle.preferredLocalizations.firstObject ?: mainBundle.localizations.firstObject ?: (mainBundle.developmentLocalization ?: XZLocaleLanguageEnglish);
}

+ (XZLocaleLanguage)preferredLanguage {
    if (_preferredLanguage == nil) {
        _preferredLanguage = self.effectiveLanguage;
    }
    return _preferredLanguage;
}

+ (void)setPreferredLanguage:(XZLocaleLanguage)newValue {
    // 参数校验
    if (newValue == nil || newValue.length == 0) {
        return;
    }
    
    // 新旧值比较
    if ([_preferredLanguage isEqualToString:newValue]) {
        return;
    }
    
    // 判断是否支持目标语言
    if (![self.supportedLanguages containsObject:newValue]) {
        return;
    }
    _preferredLanguage = newValue.copy;
    
    // 如果没有开启应用内语言设置，不保存值。
    if (self.supportsInAppLanguagePreferences) {
        [NSNotificationCenter.defaultCenter postNotificationName:XZLocaleDidChangePreferredLanguageNotification object:self];
    }
    
    // 更新语言偏好设置
    NSArray<XZLocaleLanguage> *preferredLanguages = [NSUserDefaults.standardUserDefaults stringArrayForKey:AppleLanguages];
    if (preferredLanguages.count > 0) {
        NSInteger index = [preferredLanguages indexOfObject:newValue];
        if (index == 0) {
            return;
        }
        NSMutableArray * const newPreferences = [NSMutableArray arrayWithArray:preferredLanguages];
        if (index != NSNotFound) {
            [newPreferences removeObjectAtIndex:index];
        }
        [newPreferences insertObject:newValue atIndex:0];
        preferredLanguages = newPreferences;
    } else {
        preferredLanguages = @[newValue];
    }
    [NSUserDefaults.standardUserDefaults setObject:preferredLanguages forKey:AppleLanguages];
}

+ (NSLocaleLanguageDirection)languageDirectionForLanguage:(XZLocaleLanguage)language {
    NSString *identifier = [NSLocale canonicalLanguageIdentifierFromString:language];
    return [NSLocale characterDirectionForLanguage:identifier];
}

+ (NSArray<XZLocaleLanguage> *)supportedLanguages {
    return NSBundle.mainBundle.localizations;
}

+ (BOOL)supportsInAppLanguagePreferences {
    return _supportsInAppLanguagePreferences;
}

+ (void)setSupportsInAppLanguagePreferences:(BOOL)supportsInAppLanguagePreferences {
    NSAssert(NSThread.isMainThread, XZLocalizedString(@"方法 %s 只能在主线程调用。"),  __PRETTY_FUNCTION__);
    [self setInAppLanguagePreferencesSupported];
    _supportsInAppLanguagePreferences = supportsInAppLanguagePreferences;
}

+ (void)setInAppLanguagePreferencesSupported {
    if (_isInAppLanguagePreferencesSupported) {
        return;
    }
    _isInAppLanguagePreferencesSupported = YES;
    
    SEL const method = @selector(localizedStringForKey:value:table:);
    xz_objc_class_addMethodWithBlock(NSBundle.class, method, nil, nil, nil, ^id _Nonnull(SEL  _Nonnull selector) {
        return ^NSString *(NSBundle *self, NSString *key, NSString *value, NSString *tableName) {
            if (_supportsInAppLanguagePreferences) {
                // 开启状态下，NSBundle 查找本地化字符串，先查找语言包
                XZLocaleLanguage const preferredLanguage = XZLocale.preferredLanguage;
                NSBundle *       const languageBundle    = [self xz_languageResourceBundleForLanguage:preferredLanguage];
                // 这里已经是语言包，直接向原始实现发送消息
                return ((NSString *(*)(NSBundle *, SEL, NSString *, NSString *, NSString *))objc_msgSend)(languageBundle, selector, key, value, tableName);
            }
            return ((NSString *(*)(NSBundle *, SEL, NSString *, NSString *, NSString *))objc_msgSend)(self, selector, key, value, tableName);
        };
    });
}

+ (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)table bundle:(NSBundle *)bundle arguments:(va_list)arguments {
    key = NSLocalizedStringWithDefaultValue(key, table, bundle, value, @"");
    return [NSString xz_stringWithMarkup:(XZStringMarkupBraces) format:key arguments:arguments];
}

+ (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)table bundle:(NSBundle *)bundle, ... {
    va_list arguments;
    va_start(arguments, bundle);
    NSString *localizedString = [self localizedStringForKey:key value:value table:table bundle:bundle arguments:arguments];
    va_end(arguments);
    return localizedString;
}

@end



@implementation NSBundle (XZLocale)

- (NSBundle *)xz_languageResourceBundleForLanguage:(XZLocaleLanguage)language {
    static const void * const _languageBundles = &_languageBundles;
    NSMutableDictionary<NSString *, id> *languageBundles = objc_getAssociatedObject(self, _languageBundles);
    
    // 查找缓存
    NSBundle *resourceBundle = languageBundles[language];
    if (resourceBundle != nil) {
        return ((id)resourceBundle == (id)kCFNull) ? self : resourceBundle;
    }
    
    // 建立缓存
    if (languageBundles == nil) {
        languageBundles = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, _languageBundles, languageBundles, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    // 查找语言包，找不到返回自身，使用 NSNull 标记已经找过了。
    if ([self.bundleURL.lastPathComponent hasSuffix:@".lproj"]) {
        // 自身就是语言包
        languageBundles[language] = (id)kCFNull;
        resourceBundle = self;
    } else {
        NSString *path = [self pathForResource:language ofType:@"lproj"];
        if (path != nil) {
            resourceBundle = [NSBundle bundleWithPath:path];
        }
        if (resourceBundle != nil) {
            languageBundles[language] = resourceBundle;
        } else {
            languageBundles[language] = (id)kCFNull;
            resourceBundle = self;
        }
    }
    
    return resourceBundle;
}

@end
