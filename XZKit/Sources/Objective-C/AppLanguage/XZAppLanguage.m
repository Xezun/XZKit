//
//  XZAppLanguage.m
//  XZKit
//
//  Created by Xezun on 2018/7/26.
//  Copyright © 2018年 XEZUN INC. All rights reserved.
//

#import "XZAppLanguage.h"
#import "XZAppLanguageBundle.h"
#import "NSBundle+XZAppLanguage.h"
#import <XZKit/XZRuntime.h>

static const void * const _preferredLanguage = &_preferredLanguage;
static const void * const _customBundleClass = &_customBundleClass;

@implementation NSUserDefaults (XZAppLanguage)

- (XZAppLanguage)xz_preferredLanguage {
    NSString *preferredLanguage = objc_getAssociatedObject(self, _preferredLanguage);
    if (preferredLanguage != nil) {
        return preferredLanguage;
    }
    NSArray<NSString *> *preferredLanguages = [self objectForKey:XZAppLanguageUserDefaultsKey];
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
    if (!NSBundle.mainBundle.xz_supportsInAppLanguageSwitching) {
        // 如果 mainBundle 是 NSBundle 的实例，直接更改 class 为 XZAppLanguageBundle 。
        // 如果不是，因为 class_setSuperclass 被废弃，需要动态创建继承自 mainBundle 当前类型的子类。
        if ([NSBundle.mainBundle isMemberOfClass:[NSBundle class]]) {
            object_setClass(NSBundle.mainBundle, [XZAppLanguageBundle class]);
        } else {
            Class const oldClass = NSBundle.mainBundle.class;
            Class newClass = objc_getAssociatedObject(oldClass, _customBundleClass);
            if (newClass == nil) {
                newClass = xz_objc_class_create(oldClass, ^(Class  _Nonnull __unsafe_unretained newClass) {
                    xz_objc_class_addMethods(newClass, [XZAppLanguageBundle class]);
                });
                
                objc_setAssociatedObject(oldClass, _customBundleClass, newClass, OBJC_ASSOCIATION_ASSIGN);
            }
            object_setClass(NSBundle.mainBundle, newClass);
        }
    }
    
    // 记录内容。如果需要频繁根据语言来处理业务逻辑，可以提高性能。
    objc_setAssociatedObject(self, _preferredLanguage, newLanguage, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    // 写入到 UserDefaults 。
    NSArray<NSString *> *preferredLanguages = [self objectForKey:XZAppLanguageUserDefaultsKey];
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
    [self setObject:preferredLanguages forKey:XZAppLanguageUserDefaultsKey];
    
    // 某些语言是从右向左布局的，改变布局方向的逻辑不属于此功能范围。
    
    // 发送通知。
    NSDictionary *userInfo = @{XZAppLanguagePreferenceUserInfoKey: newLanguage};
    [NSNotificationCenter.defaultCenter postNotificationName:XZAppLanguagePreferenceDidChangeNotification object:self userInfo:userInfo];
}

@end



NSNotificationName const XZAppLanguagePreferenceDidChangeNotification = @"XZAppLanguagePreferenceDidChangeNotification";
NSString * const XZAppLanguagePreferenceUserInfoKey = @"XZAppLanguagePreferenceUserInfoKey";
NSString * const XZAppLanguageUserDefaultsKey       = @"AppleLanguages";

XZAppLanguage const XZAppLanguageEnglish    = @"en";
XZAppLanguage const XZAppLanguageChinese    = @"zh";
XZAppLanguage const XZAppLanguageFrench     = @"fr";
XZAppLanguage const XZAppLanguageSpanish    = @"es";
XZAppLanguage const XZAppLanguagePortuguese = @"pt";
XZAppLanguage const XZAppLanguageRussian    = @"ru";
XZAppLanguage const XZAppLanguageArabic     = @"ar";
XZAppLanguage const XZAppLanguageGerman     = @"de";
XZAppLanguage const XZAppLanguageJapanese   = @"ja";
