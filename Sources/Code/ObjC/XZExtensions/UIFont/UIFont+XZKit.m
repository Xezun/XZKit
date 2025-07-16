//
//  UIFont+XZKit.m
//  XZKit
//
//  Created by Xezun on 2021/10/5.
//

@import ObjectiveC;
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
    static void *_characterSet = nil;
    
    NSCharacterSet * value = objc_getAssociatedObject(self, &_characterSet);
    if (value == nil) {
        CTFontRef const font = CTFontCreateWithName((__bridge CFStringRef)[self fontName], self.pointSize, NULL);
        value = (__bridge_transfer NSCharacterSet *)CTFontCopyCharacterSet(font);
        objc_setAssociatedObject(self, &_characterSet, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        CFRelease(font);
    }
    return value;
}

- (BOOL)xz_containsGlyphsForCharactersInString:(NSString *)aString {
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

- (void)xz_enumerateMatchesGlyphsInString:(NSString *)aString usingBlock:(void (^)(NSRange))block {
    if (block == nil || aString == nil || aString.length == 0) {
        return;
    }
    
    NSInteger const length = aString.length;
    
    if (length == 0) {
        return;
    }
    
    
    NSCharacterSet * const characterSet = self.xz_characterSet;
    
    for (NSInteger i = 0; i < length; ) {
        CFRange range = CFRangeMake(i, length - i);
        if (CFStringFindCharacterFromSet((__bridge CFStringRef)aString, (__bridge CFCharacterSetRef)characterSet, range, 0, &range)) {
            if (range.location != i) {
                
            }
            i += range.length;
            continue;
        }
        return NO;
    }
    
    
    
    CTFontRef const font = CTFontCreateWithName((__bridge CFStringRef)[self fontName], self.pointSize, NULL);
    // CoreText 使用 UTF16 编码
    unichar * const cext = calloc(textLength, sizeof(UniChar));
    defer(^{
        free(cext);
    });
    [aString getCharacters:cext range:NSMakeRange(0, textLength)];
    
    BOOL    __block start = NO;
    NSRange __block range = NSMakeRange(NSNotFound, 0);
    
    [aString enumerateSubstringsInRange:NSMakeRange(0, textLength) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        CGGlyph glyph[10];
        if (CTFontGetGlyphsForCharacters(font, cext + enclosingRange.location, glyph, enclosingRange.length)) {
            if (start) {
                range.length += enclosingRange.length;
            } else {
                start = YES;
                range = enclosingRange;
            }
            return;
        }
        if (start) {
            block(range);
            range.location = NSNotFound;
            start = NO;
        }
    }];
    
    if (start) {
        block(range);
    }
}

@end
