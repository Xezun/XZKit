//
//  NSBundle.m
//  XZKit
//
//  Created by Xezun on 2017/10/31.
//

#import "NSBundle+XZKit.h"

@interface XZKitBundleClass : NSBundle
@end

@implementation NSBundle (XZKit)

+ (NSBundle *)XZKitBundle {
    return [NSBundle bundleForClass:[XZKitBundleClass class]];
}

- (NSString *)xz_displayName {
    return [[self infoDictionary] objectForKeyedSubscript:@"CFBundleDisplayName"] ?: @"";
}

- (NSString *)xz_buildVersionString {
    return [[self infoDictionary] objectForKeyedSubscript:@"CFBundleVersion"] ?: @"0";
}

- (NSString *)xz_shortVersionString {
    return [[self infoDictionary] objectForKeyedSubscript:@"CFBundleShortVersionString"] ?: @"0";
}

@end

@implementation XZKitBundleClass
@end
