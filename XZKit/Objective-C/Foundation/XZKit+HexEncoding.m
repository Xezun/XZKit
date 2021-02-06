//
//  XZKit+HexEncoding.m
//  XZKit
//
//  Created by 徐臻 on 2019/3/30.
//  Copyright © 2019 XEZUN INC. All rights reserved.
//

#import "XZKit+HexEncoding.h"

/// 十六进制字符表。
static unichar const XZHexEncodingTable[2][16] = {
    {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'},
    {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'}
};

@implementation NSData (XZHexEncoding)

+ (NSData *)xz_dataWithHexEncodedString:(NSString *)hexEncodedString {
    NSUInteger const stringLength = hexEncodedString.length;
    NSMutableData *data = [NSMutableData dataWithCapacity:stringLength * 0.5];
    if (stringLength > 2) {
        UInt8 bit = 0, bit1 = 0, bit2 = 0;
        [hexEncodedString cStringUsingEncoding:(NSNEXTSTEPStringEncoding)];
        for (NSInteger i = 0; i <= stringLength - 2;) {
            if (!XZHexDecoder([hexEncodedString characterAtIndex:i++], &bit1)) {
                return data;
            }
            if (!XZHexDecoder([hexEncodedString characterAtIndex:i++], &bit2)) {
                return data;
            }
            bit = bit1 * 16 + bit2;
            [data appendBytes:&bit length:1];
        }
    }
    return data;
}

- (NSString *)xz_hexEncodedString {
    return [self xz_hexEncodedStringWithCharacterCase:XZCharacterLowercase];
}

- (NSString *)xz_hexEncodedStringWithCharacterCase:(XZCharacterCase)characterCase {
    return [[NSString alloc] xz_initWithData:self hexEncoding:characterCase];
}

@end


@implementation NSString (XZHexEncoding)

- (instancetype)xz_initWithBytes:(const void *)bytes length:(NSUInteger)numberOfBytes hexEncoding:(XZCharacterCase)characterCase {
    NSUInteger const count  = numberOfBytes * 2; // unichar 为 unsigned short 在 64 位平台占两个字符。
    unichar *  const buffer = malloc(count * sizeof(unichar));
    
    for (NSUInteger i = 0, index = 0; i < numberOfBytes; i++, index += 2) {
        buffer[index]     = XZHexEncodingTable[characterCase][((UInt8 *)bytes)[i] >> 4];
        buffer[index + 1] = XZHexEncodingTable[characterCase][((UInt8 *)bytes)[i] & 0x0f];
    }
    
    return [self initWithCharactersNoCopy:buffer length:count freeWhenDone:YES];
}

- (instancetype)xz_initWithData:(NSData *)data hexEncoding:(XZCharacterCase)characterCase {
    NSUInteger const count  = data.length * 2;
    unichar *  const buffer = malloc(count * sizeof(unichar));
    
    [data enumerateByteRangesUsingBlock:^(const void * _Nonnull bytes, NSRange byteRange, BOOL * _Nonnull stop) {
        for (NSUInteger i = 0, index = byteRange.location * 2; i < byteRange.length; i++, index += 2) {
            buffer[index]     = XZHexEncodingTable[characterCase][((UInt8 *)bytes)[i] >> 4];
            buffer[index + 1] = XZHexEncodingTable[characterCase][((UInt8 *)bytes)[i] & 0x0f];
        }
    }];
    
    return [self initWithCharactersNoCopy:buffer length:count freeWhenDone:YES];
}


- (NSString *)xz_stringByAddingHexEncoding:(XZCharacterCase)characterCase usingEncoding:(NSStringEncoding)stringEncoding {
    NSData * const data = [self dataUsingEncoding:stringEncoding];
    return [data xz_hexEncodedStringWithCharacterCase:characterCase];
}

- (NSString *)xz_stringByAddingHexEncodingUsingEncoding:(NSStringEncoding)stringEncoding {
    return [self xz_stringByAddingHexEncoding:(XZCharacterLowercase) usingEncoding:stringEncoding];
}

- (NSString *)xz_stringByAddingHexEncoding:(XZCharacterCase)characterCase {
    return [self xz_stringByAddingHexEncoding:characterCase usingEncoding:NSUTF8StringEncoding];
}

- (NSString *)xz_stringByAddingHexEncoding {
    return [self xz_stringByAddingHexEncoding:(XZCharacterLowercase)];
}

- (NSString *)xz_stringByRemovingHexEncodingUsingEncoding:(NSStringEncoding)dataEncoding {
    NSData *data = [NSData xz_dataWithHexEncodedString:self];
    return [[NSString alloc] initWithData:data encoding:dataEncoding];
}

- (NSString *)xz_stringByRemovingHexEncoding {
    return [self xz_stringByRemovingHexEncodingUsingEncoding:NSUTF8StringEncoding];
}

@end


unichar XZHexEncoder(UInt8 byte, XZCharacterCase characterCase) {
    return XZHexEncodingTable[characterCase][byte];
}

BOOL XZHexDecoder(unichar character, UInt8 * const byte) {
    assert(byte);
    switch (character) {
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
            *byte = (character - '0');
            return YES;
        case 'a':
        case 'b':
        case 'c':
        case 'd':
        case 'e':
        case 'f':
            *byte = (character - 'a' + 10);
            return YES;
        case 'A':
        case 'B':
        case 'C':
        case 'D':
        case 'E':
        case 'F':
            *byte = (character - 'A' + 10);
            return YES;
        default:
            return NO;
    }
}
