//
//  UIDevice+XZKit.m
//  XZKit
//
//  Created by Xezun on 2021/11/21.
//

#import <sys/sysctl.h>
#import "UIDevice+XZKit.h"
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZDefer.h>
#else
#import "XZDefer.h"
#endif

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

- (NSString *)xz_productName {
    NSString *model = self.xz_productModel;
    if (model == nil || model.length == 0) {
        return self.model;
    }
    static NSDictionary *_devices = nil;
    if (_devices == nil) {
        _devices = @{
            @"iPhone3,1": @"iPhone 4",
            @"iPhone3,2": @"iPhone 4",
            @"iPhone3,3": @"iPhone 4",
            @"iPhone4,1": @"iPhone 4S",
            @"iPhone5,1": @"iPhone 5",
            @"iPhone5,2": @"iPhone 5",
            @"iPhone5,3": @"iPhone 5c",
            @"iPhone5,4": @"iPhone 5c",
            @"iPhone6,1": @"iPhone 5s",
            @"iPhone6,2": @"iPhone 5s",
            @"iPhone7,1": @"iPhone 6 Plus",
            @"iPhone7,2": @"iPhone 6",
            @"iPhone8,1": @"iPhone 6s",
            @"iPhone8,2": @"iPhone 6s Plus",
            @"iPhone8,4": @"iPhone SE",
            @"iPhone9,1": @"iPhone 7",
            @"iPhone9,2": @"iPhone 7 Plus",
            @"iPhone9,3": @"iPhone 7",
            @"iPhone9,4": @"iPhone 7 Plus",
            @"iPhone10,1": @"iPhone 8",
            @"iPhone10,2": @"iPhone 8 Plus",
            @"iPhone10,4": @"iPhone 8",
            @"iPhone10,5": @"iPhone 8 Plus",
            @"iPhone10,3": @"iPhone X",
            @"iPhone10,6": @"iPhone X",
            @"iPhone11,2": @"iPhone XS",
            @"iPhone11,4": @"iPhone XS Max",
            @"iPhone11,6": @"iPhone XS Max",
            @"iPhone11,8": @"iPhone XR",
            @"iPhone12,1": @"iPhone 11",
            @"iPhone12,3": @"iPhone 11 Pro",
            @"iPhone12,5": @"iPhone 11 Pro Max",
            @"iPhone12,8": @"iPhone SE 2",
            @"iPhone13,1": @"iPhone 12 mini",
            @"iPhone13,2": @"iPhone 12",
            @"iPhone13,3": @"iPhone 12 Pro",
            @"iPhone13,4": @"iPhone 12 Pro Max",
            @"iPhone14,4": @"iPhone 13 mini",
            @"iPhone14,5": @"iPhone 13",
            @"iPhone14,2": @"iPhone 13 Pro",
            @"iPhone14,3": @"iPhone 13 Pro Max",
            @"iPhone14,6": @"iPhone SE 3",
            @"iPhone14,7": @"iPhone 14",
            @"iPhone14,8": @"iPhone 14 Plus",
            @"iPhone15,2": @"iPhone 14 Pro",
            @"iPhone15,3": @"iPhone 14 Pro Max",
            @"iPhone15,4": @"iPhone 15",
            @"iPhone15,5": @"iPhone 15 Plus",
            @"iPhone16,1": @"iPhone 15 Pro",
            @"iPhone16,2": @"iPhone 15 Pro Max",
            @"iPhone17,1": @"iPhone 16 Pro",
            @"iPhone17,2": @"iPhone 16 Pro Max",
            @"iPhone17,3": @"iPhone 16",
            @"iPhone17,4": @"iPhone 16 Plus",
            @"iPhone18,1": @"iPhone 17 Pro",
            @"iPhone18,2": @"iPhone 17 Pro Max",
            @"iPhone18,3": @"iPhone 17",
            @"iPhone18,4": @"iPhone 17 Plus",
            // 模拟器
            @"i386":    @"Simulator",
            @"x86_64":    @"Simulator",
            // iPad
            @"iPod1,1": @"iPod Touch 1G",
            @"iPod2,1": @"iPod Touch 2G",
            @"iPod3,1": @"iPod Touch 3G",
            @"iPod4,1": @"iPod Touch 4G",
            @"iPod5,1": @"iPod Touch 5G",
            @"iPod7,1": @"iPod Touch 6G",
            @"iPod9,1": @"iPod Touch 7G",
            @"iPad1,1": @"iPad",
            @"iPad1,2": @"iPad 3G",
            @"iPad2,1": @"iPad 2",
            @"iPad2,2": @"iPad 2",
            @"iPad2,3": @"iPad 2",
            @"iPad2,4": @"iPad 2",
            @"iPad2,5": @"iPad Mini",
            @"iPad2,6": @"iPad Mini",
            @"iPad2,7": @"iPad Mini",
            @"iPad3,1": @"iPad 3",
            @"iPad3,2": @"iPad 3",
            @"iPad3,3": @"iPad 3",
            @"iPad3,4": @"iPad 4",
            @"iPad3,5": @"iPad 4",
            @"iPad3,6": @"iPad 4",
            @"iPad4,1": @"iPad Air",
            @"iPad4,2": @"iPad Air",
            @"iPad4,3": @"iPad Air",
            @"iPad4,4": @"iPad Mini 2",
            @"iPad4,5": @"iPad Mini 2",
            @"iPad4,6": @"iPad Mini 2",
            @"iPad4,7": @"iPad Mini 3",
            @"iPad4,8": @"iPad Mini 3",
            @"iPad4,9": @"iPad Mini 3",
            @"iPad5,1": @"iPad Mini 4",
            @"iPad5,2": @"iPad Mini 4",
            @"iPad5,3": @"iPad Air 2",
            @"iPad5,4": @"iPad Air 2",
            @"iPad6,3": @"iPad Pro 9.7",
            @"iPad6,4": @"iPad Pro 9.7",
            @"iPad6,7": @"iPad Pro 12.9",
            @"iPad6,8": @"iPad Pro 12.9",
            @"iPad6,11": @"iPad 5",
            @"iPad6,12": @"iPad 5",
            @"iPad7,1": @"iPad Pro 12.9 inch 2nd gen",
            @"iPad7,2": @"iPad Pro 12.9 inch 2nd gen",
            @"iPad7,3": @"iPad Pro 10.5 inch",
            @"iPad7,4": @"iPad Pro 10.5 inch",
            @"iPad7,5": @"iPad 6",
            @"iPad7,6": @"iPad 6",
            @"iPad7,11": @"iPad 7",
            @"iPad7,12": @"iPad 7",
            @"iPad8,1": @"iPad Pro 11-inch",
            @"iPad8,2": @"iPad Pro 11-inch",
            @"iPad8,3": @"iPad Pro 11-inch",
            @"iPad8,4": @"iPad Pro 11-inch",
            @"iPad8,5": @"iPad Pro 12.9-inch 3rd gen",
            @"iPad8,6": @"iPad Pro 12.9-inch 3rd gen",
            @"iPad8,7": @"iPad Pro 12.9-inch 3rd gen",
            @"iPad8,8": @"iPad Pro 12.9-inch 3rd gen",
            @"iPad8,9": @"iPad Pro 11-inch 2nd gen",
            @"iPad8,10": @"iPad Pro 11-inch 2nd gen",
            @"iPad8,11": @"iPad Pro 12.9-inch 4th gen",
            @"iPad8,12": @"iPad Pro 12.9-inch 4th gen",
            @"iPad11,1": @"iPad Mini 5",
            @"iPad11,2": @"iPad Mini 5",
            @"iPad11,3": @"iPad Air 3",
            @"iPad11,4": @"iPad Air 3",
            @"iPad11,6": @"iPad 8",
            @"iPad11,7": @"iPad 8",
            @"iPad13,1": @"iPad Air 4",
            @"iPad13,2": @"iPad Air 4",
            @"iPad12,1": @"iPad 9",
            @"iPad12,2": @"iPad 9",
            @"iPad14,1": @"iPad Mini 6",
            @"iPad14,2": @"iPad Mini 6",
            @"iPad13,4": @"iPad Pro 11-inch 3nd gen",
            @"iPad13,5": @"iPad Pro 11-inch 3nd gen",
            @"iPad13,6": @"iPad Pro 11-inch 3nd gen",
            @"iPad13,7": @"iPad Pro 11-inch 3nd gen",
            @"iPad13,8": @"iPad Pro 12.9-inch 5th gen",
            @"iPad13,9": @"iPad Pro 12.9-inch 5th gen",
            @"iPad13,10": @"iPad Pro 12.9-inch 5th gen",
            @"iPad13,11": @"iPad Pro 12.9-inch 5th gen",
            @"iPad13,16": @"iPad Air 5",
            @"iPad13,17": @"iPad Air 5",
            @"iPad13,18": @"iPad 10",
            @"iPad13,19": @"iPad 10",
            @"iPad14,3": @"iPad Pro 11-inch 4th gen",
            @"iPad14,4": @"iPad Pro 11-inch 4th gen",
            @"iPad14,5": @"iPad Pro 12.9-inch 6th gen",
            @"iPad14,6": @"iPad Pro 12.9-inch 6th gen",
            @"iPad14,8": @"iPad Air 6th Gen",
            @"iPad14,9": @"iPad Air 6th Gen",
            @"iPad14,10": @"iPad Air 7th Gen",
            @"iPad14,11": @"iPad Air 7th Gen",
            @"iPad16,3": @"iPad Pro 11 inch 5th Gen",
            @"iPad16,4": @"iPad Pro 11 inch 5th Gen",
            @"iPad16,5": @"iPad Pro 12.9 inch 7th Gen",
            @"iPad16,6": @"iPad Pro 12.9 inch 7th Gen",
        };
    }
    return _devices[model] ?: self.model;
}

@end
