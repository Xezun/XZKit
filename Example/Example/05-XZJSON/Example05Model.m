//
//  Example001Models.m
//  Example
//
//  Created by Xezun on 2024/10/12.
//

#import "Example05Model.h"
@import XZExtensions;

@implementation Example05Response
@end

@implementation Example05Model

+ (NSDictionary<NSString *,id> *)mappingJSONCodingKeys {
    return @{
        @"keyPathValue": @"key.path.value",
        @"keyArrayValue": @[@"key.array.value", @"keyArrayValue"]
    };
}

- (void)dealloc {
    if (_cStringValue) {
        free((void *)_cStringValue);
        _cStringValue = NULL;
    }
    if (_cArrayValue) {
        free((void *)_cArrayValue);
        _cArrayValue = NULL;
    }
}

- (id<NSCoding>)JSONEncodeValueForKey:(NSString *)key {
    if ([key isEqualToString:@"cArrayValue"]) {
        if (!_cArrayValue) {
            return (id)kCFNull;
        }
        NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:3];
        for (NSUInteger i = 0; i < 3; i++) {
            [arrayM addObject:@(_cArrayValue[i])];
        }
        return arrayM;
    }
    
    if ([key isEqualToString:@"cStringValue"]) {
        if (_cStringValue == NULL) {
            return NSNull.null;
        }
        return [NSString stringWithCString:_cStringValue encoding:NSASCIIStringEncoding];
    }
    
    if ([key isEqualToString:@"pointerValue"]) {
        if (!_pointerValue) {
            return (id)kCFNull;
        }
        return (_pointerValue == (__bridge void *)self) ? @"self" : @"";
    }
    
    if ([key isEqualToString:@"structValue"]) {
        return [NSString stringWithFormat:@"{%d, %f, %lf}", _structValue.a, _structValue.b, _structValue.c];
    }
    
    if ([key isEqualToString:@"unionValue"]) {
        if (_unionValue.intValue <= 0) {
            return @{ @"type": @"floatValue", @"value": @(_unionValue.floatValue) };
        }
        return @{ @"type": @"intValue", @"value": @(_unionValue.intValue) };
    }
    
    if ([key isEqualToString:@"date1Value"]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd";
        return [formatter stringFromDate:_date1Value];
    }
    
    if ([key isEqualToString:@"date2Value"]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"hh:mm:ss";
        return [formatter stringFromDate:_date2Value];
    }
    
    if ([key isEqualToString:@"date3Value"]) {
        return [XZJSON.dateFormatter stringFromDate:_date3Value];
    }
    
    if ([key isEqualToString:@"hexDataValue"]) {
        return self.hexDataValue.xz_hexEncodedString ?: (id)kCFNull;
    }
    
    if ([key isEqualToString:@"hexMutableDataValue"]) {
        return self.hexMutableDataValue.xz_hexEncodedString ?: (id)kCFNull;
    }
    
    return nil;
}

- (BOOL)JSONDecodeValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"cStringValue"]) {
        if ([value isKindOfClass:NSString.class]) {
            [self setCStringValue:(const char *)[(NSString *)value cStringUsingEncoding:NSASCIIStringEncoding]];
        }
        return YES;
    }
    
    if ([key isEqualToString:@"structValue"]) {
        if ([value isKindOfClass:NSString.class]) {
            NSString *string = value;
            if ([string hasPrefix:@"{"] && [string hasSuffix:@"}"]) {
                string = [string substringWithRange:NSMakeRange(1, string.length - 1)];
                NSArray<NSString *> *components = [string componentsSeparatedByString:@","];
                if (components.count == 3) {
                    _structValue.a = components[0].intValue;
                    _structValue.b = components[1].floatValue;
                    _structValue.c = components[2].doubleValue;
                }
            }
        }
        return YES;
    }
    
    if ([key isEqualToString:@"pointerValue"]) {
        _pointerValue = (__bridge void *)self;
        return YES;
    }
    
    if ([key isEqualToString:@"unionValue"]) {
        if ([value isKindOfClass:NSDictionary.class]) {
            NSDictionary *dict = value;
            NSString *type = dict[@"type"];
            NSNumber *value = dict[@"value"];
            if ([type isKindOfClass:NSString.class] && [value isKindOfClass:NSNumber.class]) {
                if ([type isEqualToString:@"intValue"]) {
                    _unionValue.intValue = value.intValue;
                } else if ([type isEqualToString:@"floatValue"]) {
                    _unionValue.floatValue = value.floatValue;
                }
            }
        }
        return YES;
    }
    
    if ([key isEqualToString:@"cArrayValue"]) {
        if ([value isKindOfClass:NSArray.class]) {
            NSArray * array = value;
            if (array.count == 3) {
                if (_cArrayValue == NULL) {
                    _cArrayValue = calloc(3, sizeof(int));
                }
                for (NSUInteger i = 0; i < 3; i++) {
                    NSNumber *number = array[i];
                    if (![number isKindOfClass:NSNumber.class]) {
                        return YES;
                    }
                    _cArrayValue[i] = number.intValue;
                }
            }
        }
        return YES;
    }
    
    if ([key isEqualToString:@"date1Value"]) {
        if ([value isKindOfClass:NSString.class]) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd";
            self.date1Value = [formatter dateFromString:value];
        }
        return YES;
    }
    
    if ([key isEqualToString:@"date2Value"]) {
        if ([value isKindOfClass:NSString.class]) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"hh:mm:ss";
            self.date2Value = [formatter dateFromString:value];
        }
        return YES;
    }
    
    if ([key isEqualToString:@"hexDataValue"]) {
        if ([value isKindOfClass:NSString.class]) {
            self.hexDataValue = [NSData xz_dataWithHexEncodedString:value];
        }
        return YES;
    }
    
    if ([key isEqualToString:@"hexMutableDataValue"]) {
        if ([value isKindOfClass:NSString.class]) {
            self.hexMutableDataValue = [NSMutableData xz_dataWithHexEncodedString:value];
        }
        return YES;
    }
    
    return NO;
}

- (void)setCStringValue:(const char *)cStringValue {
    if (_cStringValue != cStringValue) {
        if (cStringValue == NULL) {
            if (_cStringValue == NULL) {
                return;
            }
            free((void *)_cStringValue);
            _cStringValue = NULL;
            return;
        }
        
        size_t const length = strlen(cStringValue);
        
        if (_cStringValue) {
            _cStringValue = realloc((void *)_cStringValue, length * sizeof(char));
        } else {
            _cStringValue = calloc(length, sizeof(char));
        }
        strcpy((void *)_cStringValue, cStringValue);
    }
}

- (NSString *)description {
    return [XZJSON model:self description:0];
}

@end

@implementation Example05Human

+ (NSDictionary<NSString *,id> *)mappingJSONCodingKeys {
    return @{
        @"identifier": @[@"id", @"identifier", @"_id"]
    };
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        [XZJSON model:self decodeWithCoder:coder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [XZJSON model:self encodeWithCoder:coder];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (NSString *)description {
    return [XZJSON model:self description:0];
}

@end

@implementation Example05Teacher

+ (NSDictionary<NSString *,id> *)mappingJSONCodingClasses {
    return @{
        @"students": [Example05Student class]
    };
}

+ (NSDictionary<NSString *,id> *)mappingJSONCodingKeys {
    return @{
        @"identifier": @"id",
        @"school": @[@"school\\.name", @"school.name"]
    };
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)JSON {
    // 调用指定初始化方法。
    self = [self init];
    if (self != nil) {
        // 使用 XZJSON 进行初始化。
        [XZJSON model:self decodeFromDictionary:JSON];
        
        // 处理自定义逻辑：关联学生和老师
        for (Example05Student *student in self.students) {
            student.teacher = self;
        }
    }
    return self;
}

- (void)dealloc {
    if (_foo) {
        free(_foo);
        _foo = NULL;
    }
}

- (BOOL)JSONDecodeValue:(id)valueOrCoder forKey:(NSString *)key {
    if ([key isEqualToString:@"foo"]) {
        if ([valueOrCoder isKindOfClass:NSCoder.class]) {
            valueOrCoder = [(NSCoder *)valueOrCoder decodeObjectOfClass:NSString.class forKey:key];
        }
        NSString *value = valueOrCoder;
        if ([value isKindOfClass:NSString.class]) {
            NSUInteger length = [value lengthOfBytesUsingEncoding:NSASCIIStringEncoding];
            if (_foo) {
                _foo = realloc(_foo, length * sizeof(char));
            } else {
                _foo = calloc(length, sizeof(char));
            }
            memcpy(_foo, [value cStringUsingEncoding:NSASCIIStringEncoding], length);
        }
        return YES;
    }
    return NO;
}

- (id)JSONEncodeValueForKey:(NSString *)key {
    if ([key isEqualToString:@"foo"]) {
        return _foo ? [NSString stringWithCString:_foo encoding:NSASCIIStringEncoding] : (id)kCFNull;
    }
    return nil;
}

@end

@import XZObjcDescriptor;

@implementation Example05Student

+ (void)load {
    XZObjcTypeRegister(Example05Struct);
}

+ (NSArray<NSString *> *)allowedJSONCodingKeys {
    return nil;
}

- (BOOL)JSONDecodeValue:(id)valueOrCoder forKey:(NSString *)key {
    if ([key isEqualToString:@"bar"]) {
        if ([valueOrCoder isKindOfClass:NSCoder.class]) {
            valueOrCoder = [(NSCoder *)valueOrCoder decodeObjectOfClass:NSString.class forKey:key];
        }
        NSString *value = valueOrCoder;
        if ([value isKindOfClass:NSString.class]) {
            value = [value stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"{}"]];
            NSArray *parts = [value componentsSeparatedByString:@", "];
            if (parts.count == 3) {
                int a = [parts[0] intValue];
                float b = [parts[1] floatValue];
                double c = [parts[2] doubleValue];
                _bar = (Example05Struct){a, b, c};
            }
        }
        return YES;
    }
    if ([key isEqualToString:@"teacher"]) {
        return YES;
    }
    return NO;
}

- (id)JSONEncodeValueForKey:(NSString *)key {
    if ([key isEqualToString:@"bar"]) {
        return [NSString stringWithFormat:@"{%d, %f, %lf}", _bar.a, _bar.b, _bar.c];
    }
    if ([key isEqualToString:@"teacher"]) {
        return _teacher.identifier;
    }
    return nil;
}

@end








