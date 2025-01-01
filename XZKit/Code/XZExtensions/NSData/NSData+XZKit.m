//
//  NSData+XZKit.m
//  XZExtensions
//
//  Created by 徐臻 on 2024/6/12.
//

#import "NSData+XZKit.h"

/// 十六进制字符表。
static unsigned char const XZHexEncodingTable[2][16] = {
    {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'},
    {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'}
};

@implementation NSData (XZKit)

+ (instancetype)xz_dataWithHexEncodedString:(NSString *)hexEncodedString {
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
    return [self xz_hexEncodedString:XZLowercaseHexEncoding];
}

- (NSString *)xz_hexEncodedString:(XZHexEncoding)hexEncoding {
    NSUInteger const length = self.length * 2;
    UInt8 *    const buffer = malloc(length * sizeof(UInt8));
    
    [self enumerateByteRangesUsingBlock:^(const void * _Nonnull bytes, NSRange range, BOOL * _Nonnull stop) {
        for (NSUInteger i = 0, index = range.location * 2; i < range.length; i++, index += 2) {
            UInt8 const byte = ((UInt8 *)bytes)[i];
            buffer[index]     = XZHexEncodingTable[hexEncoding][byte >> 4];
            buffer[index + 1] = XZHexEncodingTable[hexEncoding][byte & 0x0f];
        }
    }];
    
    return [[NSString alloc] initWithBytesNoCopy:buffer length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
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


@implementation NSData (XZJSON)

+ (instancetype)xz_dataWithJSONObject:(id)object options:(NSJSONWritingOptions)options {
    if (object == nil) {
        return nil;
    }
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:options error:&error];
    if (error.code != noErr) {
        return nil;
    }
    return [self dataWithData:data];
}

+ (instancetype)xz_dataWithJSONObject:(id)object {
    return [self xz_dataWithJSONObject:object options:(NSJSONWritingFragmentsAllowed)];
}

@end
