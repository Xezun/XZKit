//
//  Example001Models.m
//  Example
//
//  Created by Xezun on 2024/10/12.
//

#import "Example05Model.h"

@implementation Example05Model

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
        @"school": @"school\\.name"
    };
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)JSON {
    // 调用指定初始化方法。
    self = [self init];
    if (self != nil) {
        // 使用 XZJSON 进行初始化。
        [XZJSON model:self decodeFromDictionary:JSON];
        
        // 处理自定义逻辑：关联学生和老师
        [self.students enumerateObjectsUsingBlock:^(Example05Student * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.teacher = self;
        }];
    }
    return self;
}

- (void)dealloc {
    if (_foo) {
        free(_foo);
        _foo = NULL;
    }
}

- (NSString *)description {
    return [XZJSON modelDescription:self];
}

- (void)JSONDecodeValue:(id)JSONValue forKey:(NSString *)key {
    if ([key isEqualToString:@"foo"]) {
        if ([JSONValue isKindOfClass:NSString.class]) {
            NSString *value = JSONValue;
            NSUInteger length = [value lengthOfBytesUsingEncoding:NSASCIIStringEncoding];
            _foo = calloc(length, sizeof(char));
            memcpy(_foo, [value cStringUsingEncoding:NSASCIIStringEncoding], length);
        }
    }
}

- (id)JSONEncodeValueForKey:(NSString *)key {
    if ([key isEqualToString:@"foo"]) {
        return [NSString stringWithCString:_foo encoding:NSASCIIStringEncoding];
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

- (NSString *)description {
    return [XZJSON modelDescription:self];
}

- (void)JSONDecodeValue:(id)JSONValue forKey:(NSString *)key {
    if ([key isEqualToString:@"bar"]) {
        NSString *value = JSONValue;
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
    }
}

- (id)JSONEncodeValueForKey:(NSString *)key {
    if ([key isEqualToString:@"bar"]) {
        return [NSString stringWithFormat:@"{%d, %G, %G}", _bar.a, _bar.b, _bar.c];
    }
    return nil;
}

@end

