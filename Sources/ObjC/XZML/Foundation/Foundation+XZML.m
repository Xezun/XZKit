//
//  Foundation+XZML.m
//  XZKit
//
//  Created by Xezun on 2021/10/19.
//

#import "Foundation+XZML.h"
#import "XZMLDSL.h"
#import "XZMLDefines.h"

@implementation NSAttributedString (XZMLSupporting)

- (instancetype)initWithXZMLString:(NSString *)XZMLString attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes {
    NSMutableAttributedString * const attributedString = [[NSMutableAttributedString alloc] initWithXZMLString:XZMLString attributes:attributes];
    return [self initWithAttributedString:attributedString];
}

- (instancetype)initWithXZMLString:(NSString *)XZMLString {
    return [self initWithXZMLString:XZMLString attributes:nil];
}

@end

@implementation NSMutableAttributedString (XZMLSupporting)

- (instancetype)initWithXZMLString:(NSString *)XZMLString attributes:(NSDictionary<NSAttributedStringKey, id> *)attributes {
    self = [self init];
    if (self) {
        XZMLDSLWithAttributedString(XZMLString, self, attributes);
    }
    return self;
}

- (void)appendXZMLString:(NSString *)XZMLString attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)defaultAttributes {
    NSMutableAttributedString * const attributedString = [[NSMutableAttributedString alloc] initWithXZMLString:XZMLString attributes:defaultAttributes];
    [self appendAttributedString:attributedString];
}

@end


@implementation NSString (XZMLSupporting)

- (instancetype)initWithXZMLString:(NSString *)XZMLString attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes {
    NSMutableString *string = [[NSMutableString alloc] initWithXZMLString:XZMLString attributes:attributes];
    return [self initWithString:string];
}

- (instancetype)initWithXZMLString:(NSString *)XZMLString {
    return [self initWithXZMLString:XZMLString attributes:nil];
}

- (NSMutableString *)stringByEscapingXZMLReservedCharacters {
    NSUInteger        const length  = self.length;
    NSCharacterSet  * const XZMLSet = NSCharacterSet.XZMLReservedCharacterSet;
    NSMutableString * const stringM = [NSMutableString stringWithCapacity:length + 20];
    
    for (NSInteger i = 0; i < length; ) {
        NSRange    const range     = [self rangeOfComposedCharacterSequenceAtIndex:i];
        i += range.length;
        
        NSString * const substring = [self substringWithRange:range];
        if (range.length == 1) {
            unichar const character = [self characterAtIndex:range.location];
            if ([XZMLSet characterIsMember:character]) {
                [stringM appendString:@"\\"];
            }
        }
        [stringM appendString:substring];
    }
    
    return stringM;
}

@end

@implementation NSMutableString (XZMLSupporting)

- (instancetype)initWithXZMLString:(NSString *)XZMLString attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes {
    self = [self init];
    if (self) {
        XZMLDSLWithString(XZMLString, self, attributes);
    }
    return self;
}

@end


@implementation NSCharacterSet (XZMLSupporting)

+ (NSCharacterSet *)XZMLReservedCharacterSet {
    static NSCharacterSet *_characterSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableCharacterSet *characterSet = [NSMutableCharacterSet characterSetWithCharactersInString:@"<\\>"];
        const NSInteger kAttributesCount = 6;
        char kAttributes[] = {
            XZMLAttributeColor,
            XZMLAttributeFont,
            XZMLAttributeDecoration,
            XZMLAttributeLink,
            XZMLAttributeSecurity,
            XZMLAttributeParagraph
        };
        for (NSInteger i = 0; i < kAttributesCount; i++) {
            char const attribute = kAttributes[i];
            switch (attribute) {
                case XZMLAttributeColor:
                case XZMLAttributeFont:
                case XZMLAttributeDecoration:
                case XZMLAttributeLink:
                case XZMLAttributeSecurity:
                case XZMLAttributeParagraph:
                    [characterSet addCharactersInRange:NSMakeRange(attribute, 1)];
                    continue;
            }
            break;
        }
        _characterSet = characterSet.copy;
    });
    return _characterSet;
}

@end
