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
    NSUInteger const length = hexEncodedString.length * 0.5;
    UInt8 *    const buffer = calloc(length, sizeof(UInt8));
    
    NSRange range;
    UInt8 bit1 = 0, bit2 = 0;
    for (NSInteger i = 0, index = 0; index < length; i += 2, index += 1) {
        range = [hexEncodedString rangeOfComposedCharacterSequenceAtIndex:i];
        if (range.length > 1) {
            break; // 单个字符超过2字节，肯定不是十六进制字符
        }
        if (!XZHexDecoder([hexEncodedString characterAtIndex:i], &bit1)) {
            break;
        }
        range = [hexEncodedString rangeOfComposedCharacterSequenceAtIndex:i + 1];
        if (range.length > 1) {
            break;
        }
        if (!XZHexDecoder([hexEncodedString characterAtIndex:i + 1], &bit2)) {
            break;
        }
        buffer[index] = (bit1 << 4) + bit2;
    }
    
    return [[self alloc] initWithBytesNoCopy:buffer length:length];
}

- (NSString *)xz_hexEncodedString {
    return [self xz_hexEncodedString:XZHexEncodingLowercase];
}

- (NSString *)xz_hexEncodedString:(XZHexEncoding)hexEncoding {
    NSParameterAssert(hexEncoding == XZHexEncodingLowercase || hexEncoding == XZHexEncodingUppercase);
    return [NSString xz_stringWithData:self hexEncoding:hexEncoding];
}

@end


@implementation NSString (XZHexEncoding)

+ (instancetype)xz_stringWithBytes:(const void *)bytes length:(NSUInteger)length hexEncoding:(XZHexEncoding)hexEncoding {
    NSParameterAssert(hexEncoding == XZHexEncodingLowercase || hexEncoding == XZHexEncodingUppercase);
    
    NSUInteger const count = length * 2;
    UInt8 *    const buffer = malloc(count * sizeof(UInt8));
    
    for (NSUInteger i = 0; i < length; i++) {
        UInt8 const byte = ((UInt8 *)bytes)[i];
        buffer[i * 2]     = XZHexEncodingTable[hexEncoding][byte >> 4];
        buffer[i * 2 + 1] = XZHexEncodingTable[hexEncoding][byte & 0x0f];
    }
    
    return [[self alloc] initWithBytesNoCopy:buffer length:count encoding:NSASCIIStringEncoding freeWhenDone:YES];
}

+ (instancetype)xz_stringWithData:(NSData *)data hexEncoding:(XZHexEncoding)hexEncoding {
    NSParameterAssert(hexEncoding == XZHexEncodingLowercase || hexEncoding == XZHexEncodingUppercase);
    
    NSUInteger const length = data.length * 2;
    UInt8 *    const buffer = malloc(length * sizeof(UInt8));
    
    [data enumerateByteRangesUsingBlock:^(const void * _Nonnull bytes, NSRange range, BOOL * _Nonnull stop) {
        for (NSUInteger i = 0, index = range.location * 2; i < range.length; i++, index += 2) {
            UInt8 const byte = ((UInt8 *)bytes)[i];
            buffer[index]     = XZHexEncodingTable[hexEncoding][byte >> 4];
            buffer[index + 1] = XZHexEncodingTable[hexEncoding][byte & 0x0f];
        }
    }];
    
    return [[self alloc] initWithBytesNoCopy:buffer length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
}


- (NSString *)xz_stringByAddingHexEncoding:(XZHexEncoding)hexEncoding usingEncoding:(NSStringEncoding)stringEncoding {
    NSData * const data = [self dataUsingEncoding:stringEncoding];
    return [data xz_hexEncodedString:hexEncoding];
}

- (NSString *)xz_stringByAddingHexEncodingUsingEncoding:(NSStringEncoding)stringEncoding {
    return [self xz_stringByAddingHexEncoding:(XZHexEncodingLowercase) usingEncoding:stringEncoding];
}

- (NSString *)xz_stringByAddingHexEncoding:(XZHexEncoding)hexEncoding {
    return [self xz_stringByAddingHexEncoding:hexEncoding usingEncoding:NSUTF8StringEncoding];
}

- (NSString *)xz_stringByAddingHexEncoding {
    return [self xz_stringByAddingHexEncoding:(XZHexEncodingLowercase)];
}

- (NSString *)xz_stringByRemovingHexEncodingUsingEncoding:(NSStringEncoding)dataEncoding {
    NSData *data = [NSData xz_dataWithHexEncodedString:self];
    return [[NSString alloc] initWithData:data encoding:dataEncoding];
}

- (NSString *)xz_stringByRemovingHexEncoding {
    return [self xz_stringByRemovingHexEncodingUsingEncoding:NSUTF8StringEncoding];
}

@end


unsigned char XZHexEncoder(UInt8 byte, XZHexEncoding hexEncoding) {
    return XZHexEncodingTable[hexEncoding][byte];
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
