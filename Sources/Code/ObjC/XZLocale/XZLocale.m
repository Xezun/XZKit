//
//  XZLocale.m
//  XZLocale
//
//  Created by Xezun on 2024/9/15.
//

#import "XZLocale.h"
#import "XZRuntime.h"
#import "XZMacros.h"
#import "XZLog.h"
#import "NSString+XZKit.h"
@import ObjectiveC;

XZLanguage              const XZLanguageChinese            = @"zh-Hans";
XZLanguage              const XZLanguageChineseTraditional = @"zh-Hant";
XZLanguage              const XZLanguageEnglish            = @"en";
NSNotificationName      const XZLanguagePreferencesDidChangeNotification = @"XZLanguagePreferencesDidChangeNotification";

/// 语言偏好设置在 NSUserDefaults 中的键名。
static NSString * const AppleLanguages = @"AppleLanguages";
/// 记录了当前的语言偏好设置。
static XZLanguage _Nullable _preferredLanguage = nil;
/// 是否开启应用内切换语言功能。
static BOOL _isInAppLanguagePreferencesEnabled    = NO;
/// 是否支持应用内切换语言功能。
static BOOL _isInAppLanguagePreferencesSupported  = NO;

@implementation XZLocalization

+ (XZLanguage)effectiveLanguage {
    NSBundle * const mainBundle = NSBundle.mainBundle;
    return mainBundle.preferredLocalizations.firstObject ?: mainBundle.localizations.firstObject ?: XZLanguageEnglish;
}

+ (XZLanguage)preferredLanguage {
    if (_preferredLanguage != nil) {
        return _preferredLanguage;
    }
    NSBundle * const mainBundle = NSBundle.mainBundle;
    _preferredLanguage = mainBundle.preferredLocalizations.firstObject ?: mainBundle.localizations.firstObject ?: XZLanguageEnglish;
    return _preferredLanguage;
}

+ (void)setPreferredLanguage:(XZLanguage)newValue {
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
        XZLog(@"语言设置失败，不支持 %@ 语言。", newValue);
        return;
    }
    _preferredLanguage = newValue.copy;
    
    // 如果没有开启应用内语言设置，不保存值。
    if (self.isInAppLanguagePreferencesEnabled) {
        [NSNotificationCenter.defaultCenter postNotificationName:XZLanguagePreferencesDidChangeNotification object:self];
    }
    
    // 更新语言偏好设置
    NSArray<XZLanguage> *preferredLanguages = [NSUserDefaults.standardUserDefaults stringArrayForKey:AppleLanguages];
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

+ (NSLocaleLanguageDirection)languageDirectionForLanguage:(XZLanguage)language {
    NSString *identifier = [NSLocale canonicalLanguageIdentifierFromString:language];
    return [NSLocale characterDirectionForLanguage:identifier];
}

+ (NSArray<XZLanguage> *)supportedLanguages {
    return NSBundle.mainBundle.localizations;
}

+ (BOOL)isInAppLanguagePreferencesEnabled {
    return _isInAppLanguagePreferencesEnabled;
}

+ (void)setInAppLanguagePreferencesEnabled:(BOOL)isInAppLanguagePreferencesEnabled {
    NSAssert(NSThread.isMainThread, XZLocalizedString(@"方法 %s 只能在主线程调用。"),  __PRETTY_FUNCTION__);
    [self setInAppLanguagePreferencesSupported];
    _isInAppLanguagePreferencesEnabled = isInAppLanguagePreferencesEnabled;
}

+ (void)setInAppLanguagePreferencesSupported {
    if (_isInAppLanguagePreferencesSupported) {
        return;
    }
    _isInAppLanguagePreferencesSupported = YES;
    
    SEL const method = @selector(localizedStringForKey:value:table:);
    xz_objc_class_addMethodWithBlock(NSBundle.class, method, nil, nil, nil, ^id _Nonnull(SEL  _Nonnull selector) {
        return ^NSString *(NSBundle *self, NSString *key, NSString *value, NSString *tableName) {
            if (_isInAppLanguagePreferencesEnabled) {
                // 开启状态下，NSBundle 查找本地化字符串，先查找语言包
                XZLanguage const preferredLanguage = XZLocalization.preferredLanguage;
                NSBundle * const languageBundle    = [self xz_languageResourceBundleForLanguage:preferredLanguage];
                // 这里已经是语言包，直接向原始实现发送消息
                return ((NSString *(*)(NSBundle *, SEL, NSString *, NSString *, NSString *))objc_msgSend)(languageBundle, selector, key, value, tableName);
            }
            return ((NSString *(*)(NSBundle *, SEL, NSString *, NSString *, NSString *))objc_msgSend)(self, selector, key, value, tableName);
        };
    });
}

+ (NSString *)localizedString:(NSString *)stringToBeLocalized fromTable:(NSString *)table inBundle:(NSBundle *)bundle defaultValue:(NSString *)defaultValue arguments:(va_list)arguments {
    stringToBeLocalized = NSLocalizedStringWithDefaultValue(stringToBeLocalized, table, bundle, defaultValue, @"");
    return [NSString xz_stringWithPredicate:(XZMarkupPredicateBraces) format:stringToBeLocalized arguments:arguments];
}

+ (NSString *)localizedString:(NSString *)stringToBeLocalized fromTable:(NSString *)table inBundle:(NSBundle *)bundle defaultValue:(NSString *)defaultValue, ... {
    va_list arguments;
    va_start(arguments, defaultValue);
    NSString *localizedString = [self localizedString:stringToBeLocalized fromTable:table inBundle:bundle defaultValue:defaultValue arguments:arguments];
    va_end(arguments);
    return localizedString;
}

@end

@implementation NSBundle (XZLocalization)

- (NSBundle *)xz_languageResourceBundleForLanguage:(XZLanguage)language {
    static const void * const _languageBundles = &_languageBundles;
    NSMutableDictionary<NSString *, id> *languageBundles = objc_getAssociatedObject(self, _languageBundles);
    
    // 查找缓存
    NSBundle *resourceBundle = languageBundles[language];
    if (resourceBundle != nil) {
        return ((id)resourceBundle == NSNull.null) ? self : resourceBundle;
    }
    
    // 建立缓存
    if (languageBundles == nil) {
        languageBundles = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, _languageBundles, languageBundles, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    // 查找语言包，找不到返回自身，使用 NSNull 标记已经找过了。
    if ([self.bundleURL.lastPathComponent hasSuffix:@".lproj"]) {
        // 自身就是语言包
        languageBundles[language] = NSNull.null;
        resourceBundle = self;
    } else {
        NSString *path = [self pathForResource:language ofType:@"lproj"];
        if (path != nil) {
            resourceBundle = [NSBundle bundleWithPath:path];
        }
        if (resourceBundle != nil) {
            languageBundles[language] = resourceBundle;
        } else {
            languageBundles[language] = NSNull.null;
            resourceBundle = self;
        }
    }
    
    return resourceBundle;
}

@end
