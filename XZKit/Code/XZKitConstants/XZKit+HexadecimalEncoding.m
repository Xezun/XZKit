//
//  XZKit+NSString.m
//  XZKit
//
//  Created by 徐臻 on 2019/3/30.
//  Copyright © 2019 mlibai. All rights reserved.
//

#import "XZKit+HexadecimalEncoding.h"

static unichar const XZHexadecimalCharacterUppercaseTable[16] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
static unichar const XZHexadecimalCharacterLowercaseTable[16] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};

static BOOL XZTransformHexadecimalCharacterToNumber(unichar const hexchar, UInt8 * const number) {
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
        case '9': *number = (hexchar - '0'); return YES;
        case 'a':
        case 'b':
        case 'c':
        case 'd':
        case 'e':
        case 'f': *number = (hexchar - 'a' + 10); return YES;
        case 'A':
        case 'B':
        case 'C':
        case 'D':
        case 'E':
        case 'F': *number = (hexchar - 'A' + 10); return YES;
        default: return NO;
    }
}

@implementation NSString (HexadecimalEncoding)

+ (NSString *)xz_hexadecimalEncodedStringWithBytes:(const void *)bytes length:(NSUInteger)length {
    return [self xz_hexadecimalEncodedStringWithBytes:bytes length:length characterCase:(XZCharacterUppercase)];
}

+ (NSString *)xz_hexadecimalEncodedStringWithBytes:(const void *)bytes length:(NSUInteger)length characterCase:(XZCharacterCase)characterCase {
    const unichar * const kTable = characterCase ? XZHexadecimalCharacterUppercaseTable : XZHexadecimalCharacterLowercaseTable;
    
    // unichar 为 unsigned short 在 64 位平台占两个字符。
    NSUInteger const count = length * 2;
    unichar *buffer = malloc(count * sizeof(unichar));
    
    NSUInteger index = 0;
    for (NSUInteger i = 0; i < length; i++) {
        index = i * 2;
        buffer[index]     = kTable[((UInt8 *)bytes)[i] >> 4];
        buffer[index + 1] = kTable[((UInt8 *)bytes)[i] & 0x0f];
    }
    
    return [[NSString alloc] initWithCharactersNoCopy:buffer length:count freeWhenDone:YES];
}

@end

@implementation NSData (HexadecimalEncoding)

+ (NSData *)xz_dataWithHexadecimalEncodedString:(NSString *)hexadecimalEncodedString {
    NSMutableData *data = [NSMutableData dataWithCapacity:hexadecimalEncodedString.length];
    NSUInteger const stringLength = hexadecimalEncodedString.length;
    if (stringLength < 2) {
        return data;
    }
    UInt8 bit = 0, bit1 = 0, bit2 = 0;
    [hexadecimalEncodedString cStringUsingEncoding:(NSNEXTSTEPStringEncoding)];
    for (NSInteger i = 0; i <= stringLength - 2;) {
        if (XZTransformHexadecimalCharacterToNumber([hexadecimalEncodedString characterAtIndex:i++], &bit1)) {
            return data;
        }
        if (XZTransformHexadecimalCharacterToNumber([hexadecimalEncodedString characterAtIndex:i++], &bit2)) {
            return data;
        }
        bit = bit1 * 16 + bit2;
        [data appendBytes:&bit length:1];
    }
    return data;
}

- (NSString *)xz_hexadecimalEncodedString {
    return [self xz_hexadecimalEncodedStringWithCharacterCase:XZCharacterUppercase];
}

- (NSString *)xz_hexadecimalEncodedStringWithCharacterCase:(XZCharacterCase)characterCase {
    return [NSString xz_hexadecimalEncodedStringWithBytes:self.bytes length:self.length characterCase:characterCase];
}

@end
