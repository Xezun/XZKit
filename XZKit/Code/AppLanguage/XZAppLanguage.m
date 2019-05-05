//
//  XZAppLanguage.m
//  XZKit
//
//  Created by mlibai on 2018/7/26.
//  Copyright © 2018年 mlibai. All rights reserved.
//

#import "XZAppLanguage.h"
#import <XZKit/XZKit+Runtime.h>

@interface _XZAppLanguageBundle : NSBundle
- (nonnull NSString *)localizedStringForKey:(nonnull NSString *)key
                                      value:(nullable NSString *)value
                                      table:(nullable NSString *)tableName;
- (BOOL)xz_supportsInAppLanguageSwitching;
@end

NSNotificationName _Nonnull const XZAppPreferredLanguageDidChangeNotification = @"XZAppPreferredLanguageDidChangeNotification";
NSString * _Nonnull const XZAppPreferredLanguageUserInfoKey = @"XZAppPreferredLanguageUserInfoKey";
NSString * _Nonnull const XZAppAppleLanguagesUserDefaultsKey = @"AppleLanguages";

XZAppLanguage _Nonnull const XZAppLanguageEnglish    = @"en";
XZAppLanguage _Nonnull const XZAppLanguageChinese    = @"zh";
XZAppLanguage _Nonnull const XZAppLanguageFrench     = @"fr";
XZAppLanguage _Nonnull const XZAppLanguageSpanish    = @"es";
XZAppLanguage _Nonnull const XZAppLanguagePortuguese = @"pt";
XZAppLanguage _Nonnull const XZAppLanguageRussian    = @"ru";
XZAppLanguage _Nonnull const XZAppLanguageArabic     = @"ar";
XZAppLanguage _Nonnull const XZAppLanguageGerman     = @"de";
XZAppLanguage _Nonnull const XZAppLanguageJapanese   = @"ja";

static const void * const _preferredLanguage = &_preferredLanguage;
static const void * const _customBundleClass = &_customBundleClass;

@implementation NSUserDefaults (XZAppLanguage)

- (XZAppLanguage)xz_preferredLanguage {
    NSString *preferredLanguage = objc_getAssociatedObject(self, _preferredLanguage);
    if (preferredLanguage != nil) {
        return preferredLanguage;
    }
    NSArray<NSString *> *preferredLanguages = [self objectForKey:XZAppAppleLanguagesUserDefaultsKey];
    if ([preferredLanguages isKindOfClass:[NSArray class]] && preferredLanguages.count > 0) {
        preferredLanguage = preferredLanguages[0];
    } else {
        preferredLanguage = NSBundle.mainBundle.preferredLocalizations.firstObject ?: @"en";
    }
    objc_setAssociatedObject(self, _preferredLanguage, preferredLanguage, OBJC_ASSOCIATION_COPY_NONATOMIC);
    return preferredLanguage;
}

- (void)xz_setPreferredLanguage:(XZAppLanguage)newLanguage {
    if ([self.xz_preferredLanguage isEqualToString:newLanguage]) {
        return;
    }
    
    // 判断 App 是否支持。
    NSArray<NSString *> *supportedLanguages = NSBundle.mainBundle.localizations;
    if (![supportedLanguages containsObject:newLanguage]) {
        NSLog(@"The main bundle does not contain the localization language `%@`.", newLanguage);
        return;
    }
    
    // 判断 mainBundle 支付支持动态切换。
    if (![NSBundle.mainBundle xz_supportsInAppLanguageSwitching]) {
        if ([NSBundle.mainBundle isMemberOfClass:[NSBundle class]]) {
            object_setClass(NSBundle.mainBundle, _XZAppLanguageBundle.class);
        } else {
            Class oldClass = NSBundle.mainBundle.class;
            Class newClass = objc_getAssociatedObject(oldClass, _customBundleClass);
            if (newClass == nil) {
                NSString *className = xz_objc_class_name_create(oldClass);
                newClass = objc_allocateClassPair(oldClass, className.UTF8String, 0);
                { // 获取语言的方法。
                    SEL selector = @selector(localizedStringForKey:value:table:);
                    Method method = class_getClassMethod(_XZAppLanguageBundle.class, selector);
                    class_addMethod(newClass, selector, method_getImplementation(method), method_getTypeEncoding(method));
                }
                { // 当前对象是否支持切换语言。
                    SEL selector = @selector(xz_supportsInAppLanguageSwitching);
                    Method method = class_getClassMethod(_XZAppLanguageBundle.class, selector);
                    class_addMethod(newClass, selector, method_getImplementation(method), method_getTypeEncoding(method));
                }
                objc_registerClassPair(newClass);
                objc_setAssociatedObject(oldClass, _customBundleClass, newClass, OBJC_ASSOCIATION_ASSIGN);
            }
            object_setClass(NSBundle.mainBundle, newClass);
        }
    }
    
    // 记录内容。如果需要频繁根据语言来处理业务逻辑，可以提高性能。
    objc_setAssociatedObject(self, _preferredLanguage, newLanguage, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    // 写入到 UserDefaults 。
    NSArray<NSString *> *preferredLanguages = [self objectForKey:XZAppAppleLanguagesUserDefaultsKey];
    if ([preferredLanguages isKindOfClass:[NSArray class]] && preferredLanguages.count > 0) {
        NSMutableArray *newPreferredLanguages = [NSMutableArray arrayWithCapacity:preferredLanguages.count];
        [newPreferredLanguages addObject:newLanguage];
        for (NSString *preferredLanguage in preferredLanguages) {
            if ([preferredLanguage isEqualToString:newLanguage]) {
                continue;
            }
            [newPreferredLanguages addObject:preferredLanguage];
        }
        preferredLanguages = newPreferredLanguages;
    } else {
        preferredLanguages = @[newLanguage];
    }
    [self setObject:preferredLanguages forKey:XZAppAppleLanguagesUserDefaultsKey];
    
    // 某些语言是从右向左布局的，改变布局方向的逻辑不属于此功能范围。
    
    // 发送通知。
    NSDictionary *userInfo = @{XZAppPreferredLanguageUserInfoKey: newLanguage};
    [NSNotificationCenter.defaultCenter postNotificationName:XZAppPreferredLanguageDidChangeNotification object:self userInfo:userInfo];
}

@end



static const void * const _languageBundles = &_languageBundles;

@implementation NSBundle (XZAppLanguage)

- (NSBundle *)xz_resourceBundleForLanguage:(XZAppLanguage)language {
    NSMutableDictionary<NSString *, id> *languageBundles = objc_getAssociatedObject(self, _languageBundles);
    NSBundle *languageBundle = languageBundles[language];
    if ([languageBundle isKindOfClass:[NSBundle class]]) {
        return languageBundle;
    } else if (languageBundle != nil) {
        return nil;
    }
    
    NSString *bundlePath = [self pathForResource:language ofType:@"lproj"];
    if (bundlePath == nil) {
        // 如果指定语言包不存在则取 Base 语言包。
        bundlePath = [self pathForResource:@"Base" ofType:@"lproj"];
    }
    if (bundlePath != nil) {
        languageBundle = [NSBundle bundleWithPath:bundlePath];
    }
    
    if (languageBundles == nil) {
        languageBundles = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, _languageBundles, languageBundles, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    languageBundles[language] = languageBundle ?: [NSNull null];
    
    return languageBundle;
}

- (BOOL)xz_supportsInAppLanguageSwitching {
    return NO;
}

- (NSString *)xz_localizedStringForLanguage:(XZAppLanguage)language Key:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
    NSBundle *languageBundle = [self xz_resourceBundleForLanguage:language];
    if (languageBundle != nil) {
        return [languageBundle localizedStringForKey:key value:value table:tableName];
    }
    return [self localizedStringForKey:key value:value table:tableName];
}

@end




@implementation _XZAppLanguageBundle 

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
    XZAppLanguage preferredLanguage = NSUserDefaults.standardUserDefaults.xz_preferredLanguage;
    return [self xz_localizedStringForLanguage:preferredLanguage Key:key value:value table:tableName];
}

- (BOOL)xz_supportsInAppLanguageSwitching {
    return YES;
}

@end
