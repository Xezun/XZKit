//
//  XZAppLanguageBundle.m
//  XZKit
//
//  Created by Xezun on 2021/2/6.
//

#import "XZAppLanguageBundle.h"
#import "NSBundle+XZAppLanguage.h"

@implementation XZAppLanguageBundle

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
    XZAppLanguage preferredLanguage = NSUserDefaults.standardUserDefaults.xz_preferredLanguage;
    return [self xz_localizedStringForLanguage:preferredLanguage Key:key value:value table:tableName];
}

- (BOOL)xz_supportsInAppLanguageSwitching {
    return YES;
}

@end
