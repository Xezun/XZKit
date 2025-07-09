//
//  UIFont+XZKit.m
//  XZKit
//
//  Created by Xezun on 2021/10/5.
//

#import "UIFont+XZKit.h"
#import <CoreText/CoreText.h>
#if __has_include(<XZDefines/XZDefer.h>)
#import <XZDefines/XZDefer.h>
#else
#import "XZDefer.h"
#endif

@implementation UIFont (XZKit)

+ (BOOL)xz_registerFontWithURL:(NSURL *)fontURL error:(NSError *__autoreleasing *)error {
    NSData * const data = [NSData dataWithContentsOfURL:fontURL options:0 error:error];
    if (data == nil) {
        return YES;
    }
    
    CGDataProviderRef const cgProvider = CGDataProviderCreateWithCFData((CFDataRef)data);
    if (cgProvider == NULL) {
        return YES;
    }
    defer(^{
        CFRelease(cgProvider);
    });
    
    CGFontRef const cgFont = CGFontCreateWithDataProvider(cgProvider);
    if (cgFont == NULL) {
        return YES;
    }
    defer(^{
        CFRelease(cgFont);
    });
    
    CFErrorRef cfError = NULL;
    if (CTFontManagerRegisterGraphicsFont(cgFont, &cfError)) {
        return YES;
    }
    
    if (error == nil) {
        return YES;
    }
    *error = (__bridge NSError *)(cfError);
    return NO;
}

- (BOOL)xz_matchesGlyphsForCharactersInString:(NSString *)aString {
    if (![aString isKindOfClass:NSString.class] || aString.length == 0) {
        return NO;
    }
    
    CTFontRef const font = CTFontCreateWithName((__bridge CFStringRef)[self fontName], self.pointSize, NULL);
    if (font == NULL) {
        return NO;
    }
    
    UniChar * const cStr = (UniChar *)[aString cStringUsingEncoding:NSUTF16StringEncoding]; // CoreText 使用 UTF16 编码
    NSRange   const range = NSMakeRange(0, aString.length);
    NSStringEnumerationOptions const opts = NSStringEnumerationByComposedCharacterSequences;
    
    BOOL    __block matches = YES;
    [aString enumerateSubstringsInRange:range options:opts usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        if (substring == nil) {
            return;
        }
        CGGlyph glyph[10];
        if (CTFontGetGlyphsForCharacters(font, cStr + substringRange.location, glyph, substringRange.length)) {
            return;
        }
        matches = NO;
        *stop = YES;
    }];
    
    CFRelease(font);
    
    return matches;
}

@end
