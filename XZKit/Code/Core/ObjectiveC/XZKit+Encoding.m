//
//  XZKit+NSString.m
//  XZKit
//
//  Created by Xezun on 2019/3/30.
//  Copyright © 2019 XEZUN INC. All rights reserved.
//

#import "XZKit+Encoding.h"

/// 十六进制字符表。
static unichar const XZHexadecimalCharacterTable[2][16] = {
    {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'},
    {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'}
};

/// 返回 NO 表示参数 hexchar 不合法。
static BOOL UInt8FromUnichar(unichar const hexchar, UInt8 * const number);

@implementation NSData (XZEncoding)

+ (NSData *)xz_dataWithHexadecimalEncodedString:(NSString *)hexadecimalEncodedString {
    NSUInteger const stringLength = hexadecimalEncodedString.length;
    NSMutableData *data = [NSMutableData dataWithCapacity:stringLength * 0.5];
    if (stringLength > 2) {
        UInt8 bit = 0, bit1 = 0, bit2 = 0;
        [hexadecimalEncodedString cStringUsingEncoding:(NSNEXTSTEPStringEncoding)];
        for (NSInteger i = 0; i <= stringLength - 2;) {
            if (!UInt8FromUnichar([hexadecimalEncodedString characterAtIndex:i++], &bit1)) {
                return data;
            }
            if (!UInt8FromUnichar([hexadecimalEncodedString characterAtIndex:i++], &bit2)) {
                return data;
            }
            bit = bit1 * 16 + bit2;
            [data appendBytes:&bit length:1];
        }
    }
    return data;
}

- (NSString *)xz_hexadecimalEncodedString {
    return [self xz_hexadecimalEncodedStringWithCharacterCase:XZCharacterUppercase];
}

- (NSString *)xz_hexadecimalEncodedStringWithCharacterCase:(XZCharacterCase)characterCase {
    return [NSString xz_stringHexadecimalEncodedWithData:self characterCase:characterCase];
}

@end


@implementation NSString (XZEncoding)

+ (NSString *)xz_stringHexadecimalEncodedWithBytes:(const void *)bytes length:(NSUInteger)numberOfBytes characterCase:(XZCharacterCase)characterCase {
    NSUInteger const count = numberOfBytes * 2; // unichar 为 unsigned short 在 64 位平台占两个字符。
    unichar * const buffer = malloc(count * sizeof(unichar));
    
    NSUInteger index = 0;
    for (NSUInteger i = 0; i < numberOfBytes; i++) {
        index = i * 2;
        buffer[index]     = XZHexadecimalCharacterTable[characterCase][((UInt8 *)bytes)[i] >> 4];
        buffer[index + 1] = XZHexadecimalCharacterTable[characterCase][((UInt8 *)bytes)[i] & 0x0f];
    }
    
    return [[NSString alloc] initWithCharactersNoCopy:buffer length:count freeWhenDone:YES];
}

+ (NSString *)xz_stringHexadecimalEncodedWithData:(NSData *)data characterCase:(XZCharacterCase)characterCase {
    return [self xz_stringHexadecimalEncodedWithBytes:data.bytes length:data.length characterCase:characterCase];
}

@end


static BOOL UInt8FromUnichar(unichar const hexchar, UInt8 * const number) {
    switch (hexchar) {
        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
            *number = (hexchar - '0');
            return YES;
        case 'a':
        case 'b':
        case 'c':
        case 'd':
        case 'e':
        case 'f':
            *number = (hexchar - 'a' + 10);
            return YES;
        case 'A':
        case 'B':
        case 'C':
        case 'D':
        case 'E':
        case 'F':
            *number = (hexchar - 'A' + 10);
            return YES;
        default:
            return NO;
    }
}
