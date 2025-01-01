//
//  NSBundle+XZKit.m
//  XZKit
//
//  Created by Xezun on 2021/11/21.
//

#import "NSBundle+XZKit.h"

@implementation NSBundle (XZKit)

- (NSString *)xz_buildVersionString {
    return self.infoDictionary[@"CFBundleVersion"] ?: @"0";
}

- (NSString *)xz_shortVersionString {
    return self.infoDictionary[@"CFBundleShortVersionString"] ?: @"0.0.0";
}

- (NSString *)xz_executableName {
    return self.infoDictionary[@"CFBundleExecutable"] ?: @"";
}

@end
