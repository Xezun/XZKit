//
//  NSBundle+XZAppLanguage.m
//  XZKit
//
//  Created by Xezun on 2021/2/6.
//

#import "NSBundle+XZAppLanguage.h"
@import ObjectiveC;

static const void * const _languageBundles = &_languageBundles;

@implementation NSBundle (XZAppLanguage)

- (BOOL)xz_supportsInAppLanguageSwitching {
    return NO;
}

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

- (NSString *)xz_localizedStringForLanguage:(XZAppLanguage)language Key:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
    NSBundle *languageBundle = [self xz_resourceBundleForLanguage:language];
    if (languageBundle != nil) {
        return [languageBundle localizedStringForKey:key value:value table:tableName];
    }
    return [self localizedStringForKey:key value:value table:tableName];
}

@end
