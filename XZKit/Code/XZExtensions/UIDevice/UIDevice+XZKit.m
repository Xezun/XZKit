//
//  UIDevice+XZKit.m
//  XZKit
//
//  Created by Xezun on 2021/11/21.
//

#import "UIDevice+XZKit.h"
#import <sys/sysctl.h>

@implementation UIDevice (XZKit)

- (NSString *)xz_productModel {
    int name[] = {CTL_HW, HW_PRODUCT};
    size_t size = 100;
    if (sysctl(name, 2, NULL, &size, NULL, 0)) {
        return nil;
    }
    char * const hw_product = malloc(size * sizeof(char));
    defer(^{
        free(hw_product);
    });
    if (sysctl(name, 2, hw_product, &size, NULL, 0)) {
        return nil;
    };
    // sysctl 的输出结果为 C 字符串，末尾带 \0 结束字符。
    return [[NSString alloc] initWithCString:hw_product encoding:(NSASCIIStringEncoding)];
}

- (NSString *)xz_boardModel {
    int name[] = {CTL_HW, HW_TARGET};
    size_t size = 100;
    if (sysctl(name, 2, NULL, &size, NULL, 0)) {
        return nil;
    }
    char * const hw_target = malloc(size * sizeof(char));
    defer(^{
        free(hw_target);
    });
    if (sysctl(name, 2, hw_target, &size, NULL, 0)) {
        return nil;
    }
    return [[NSString alloc] initWithCString:hw_target encoding:(NSASCIIStringEncoding)];
}

@end
