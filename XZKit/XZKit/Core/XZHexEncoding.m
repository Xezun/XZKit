//
//  XZHexEncoding.m
//  XZKit
//
//  Created by Xezun on 2019/3/30.
//  Copyright © 2019 XEZUN INC. All rights reserved.
//

#import "XZHexEncoding.h"

/// 十六进制字符表。
static unsigned char const XZHexEncodingTable[2][16] = {
    {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'},
    {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'}
};

@implementation NSData (XZHexEncoding)

+ (NSData *)xz_dataWithHexEncodedString:(NSString *)hexEncodedString {
    NSUInteger const stringLength = hexEncodedString.length;
    NSMutableData *data = [NSMutableData dataWithCapacity:stringLength * 0.5];
    
    NSRange range;
    UInt8 bit = 0, bit1 = 0, bit2 = 0;
    for (NSInteger i = 0; i < stringLength - 1;) {
        range = [hexEncodedString rangeOfComposedCharacterSequenceAtIndex:i];
        if (range.length > 1) {
            break; // 单个字符超过2字节，肯定不是十六进制字符
        }
        if (!XZHexDecoder([hexEncodedString characterAtIndex:i++], &bit1)) {
            break;
        }
        range = [hexEncodedString rangeOfComposedCharacterSequenceAtIndex:i];
        if (range.length > 1) {
            break;
        }
        if (!XZHexDecoder([hexEncodedString characterAtIndex:i++], &bit2)) {
            break;
        }
        bit = bit1 * 16 + bit2;
        [data appendBytes:&bit length:1];
    }
    
    return data;
}

- (NSString *)xz_hexEncodedString {
    return [self xz_hexEncodedStringWithCharacterCase:XZCharacterLowercase];
}

- (NSString *)xz_hexEncodedStringWithCharacterCase:(XZCharacterCase)characterCase {
    return [[NSString alloc] xz_initWithData:self hexEncodingWithCharacterCase:characterCase];
}

@end


@implementation NSString (XZHexEncoding)

- (instancetype)xz_initWithBytes:(const void *)bytes length:(NSUInteger)length hexEncodingWithCharacterCase:(XZCharacterCase)characterCase {
    NSUInteger const count  = length * 2;
    UInt8 *    const buffer = malloc(length * sizeof(UInt8));
    
    for (NSUInteger i = 0, index = 0; i < length; i++, index += 2) {
        UInt8 const byte = ((UInt8 *)bytes)[i];
        buffer[index]     = XZHexEncodingTable[characterCase][byte >> 4];
        buffer[index + 1] = XZHexEncodingTable[characterCase][byte & 0x0f];
    }
    
    return [self initWithBytesNoCopy:buffer length:count encoding:NSASCIIStringEncoding freeWhenDone:YES];
}

- (instancetype)xz_initWithData:(NSData *)data hexEncodingWithCharacterCase:(XZCharacterCase)characterCase {
    NSUInteger const count  = data.length * 2;
    UInt8 *    const buffer = malloc(count * sizeof(UInt8));
    
    [data enumerateByteRangesUsingBlock:^(const void * _Nonnull bytes, NSRange byteRange, BOOL * _Nonnull stop) {
        for (NSUInteger i = 0, index = byteRange.location * 2; i < byteRange.length; i++, index += 2) {
            UInt8 const byte = ((UInt8 *)bytes)[i];
            buffer[index]     = XZHexEncodingTable[characterCase][byte >> 4];
            buffer[index + 1] = XZHexEncodingTable[characterCase][byte & 0x0f];
        }
    }];
    
    return [self initWithBytesNoCopy:buffer length:count encoding:NSASCIIStringEncoding freeWhenDone:YES];
}


- (NSString *)xz_stringByAddingHexEncodingWithCharacterCase:(XZCharacterCase)characterCase usingEncoding:(NSStringEncoding)stringEncoding {
    NSData * const data = [self dataUsingEncoding:stringEncoding];
    return [data xz_hexEncodedStringWithCharacterCase:characterCase];
}

- (NSString *)xz_stringByAddingHexEncodingUsingEncoding:(NSStringEncoding)stringEncoding {
    return [self xz_stringByAddingHexEncodingWithCharacterCase:(XZCharacterLowercase) usingEncoding:stringEncoding];
}

- (NSString *)xz_stringByAddingHexEncodingWithCharacterCase:(XZCharacterCase)characterCase {
    return [self xz_stringByAddingHexEncodingWithCharacterCase:characterCase usingEncoding:NSUTF8StringEncoding];
}

- (NSString *)xz_stringByAddingHexEncoding {
    return [self xz_stringByAddingHexEncodingWithCharacterCase:(XZCharacterLowercase)];
}

- (NSString *)xz_stringByRemovingHexEncodingUsingEncoding:(NSStringEncoding)dataEncoding {
    NSData *data = [NSData xz_dataWithHexEncodedString:self];
    return [[NSString alloc] initWithData:data encoding:dataEncoding];
}

- (NSString *)xz_stringByRemovingHexEncoding {
    return [self xz_stringByRemovingHexEncodingUsingEncoding:NSUTF8StringEncoding];
}

@end


unsigned char XZHexEncoder(UInt8 byte, XZCharacterCase characterCase) {
    return XZHexEncodingTable[characterCase][byte];
}

BOOL XZHexDecoder(unichar character, UInt8 * const byte) {
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
