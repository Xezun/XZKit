//
//  UIFont+XZKit.m
//  XZKit
//
//  Created by Xezun on 2021/10/5.
//

#import <CoreText/CoreText.h>
#import "UIFont+XZKit.h"
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZDefer.h>
#else
#import "XZDefer.h"
#endif

@implementation UIFont (XZKit)

+ (BOOL)xz_registerFontWithURL:(NSURL *)fontURL error:(NSError *__autoreleasing *)error {
    CFErrorRef cfError = NULL;
    BOOL const result = CTFontManagerRegisterFontsForURL((__bridge CFURLRef) fontURL, kCTFontManagerScopePersistent, &cfError);
    if (error) {
        *error = (__bridge NSError *)cfError;
    }
    return result;
}

- (NSCharacterSet *)xz_characterSet {
    CTFontRef const font = CTFontCreateWithName((__bridge CFStringRef)[self fontName], self.pointSize, NULL);
    NSCharacterSet * const value = (__bridge_transfer NSCharacterSet *)CTFontCopyCharacterSet(font);
    CFRelease(font);
    return value;
}

- (BOOL)xz_containsGlyphsInString:(NSString *)aString {
    if (![aString isKindOfClass:NSString.class]) {
        return NO;
    }
    
    NSInteger const length = aString.length;
    
    if (length == 0) {
        return NO;
    }
    
    NSCharacterSet * const characterSet = self.xz_characterSet;
    
    for (NSInteger i = 0; i < length; ) {
        CFRange range = CFRangeMake(i, length - i);
        if (CFStringFindCharacterFromSet((__bridge CFStringRef)aString, (__bridge CFCharacterSetRef)characterSet, range, 0, &range)) {
            if (range.location != i) {
                return NO;
            }
            i += range.length;
            continue;
        }
        return NO;
    }
    
    
    return YES;
}

- (void)xz_enumerateGlyphsInString:(NSString *)aString usingBlock:(void (^)(NSRange))block {
    if (block == nil || aString == nil || aString.length == 0) {
        return;
    }
    
    NSInteger const length = aString.length;
    
    if (length == 0) {
        return;
    }
    
    
    NSCharacterSet * const characterSet = self.xz_characterSet;
    
    NSRange range = NSMakeRange(0, 0);
    do {
        NSInteger const i = range.location + range.length;
        CFRange temp = CFRangeMake(i, length - i);
        if (CFStringFindCharacterFromSet((__bridge CFStringRef)aString, (__bridge CFCharacterSetRef)characterSet, temp, 0, &temp)) {
            if (temp.location == i) {
                range.length += temp.length;
            } else {
                if (range.length > 0) {
                    block(range);
                }
                range = NSMakeRange(temp.location, temp.length);
            }
        } else {
            if (range.length > 0) {
                block(range);
            }
            break;
        }
    } while (range.location < length);
    
    if (range.length > 0) {
        block(range);
    }
}

@end
