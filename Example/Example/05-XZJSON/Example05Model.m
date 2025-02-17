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

- (NSString *)description {
    return [XZJSON modelDescription:self];
}

@end

@implementation Example05Student

+ (NSArray<NSString *> *)allowedJSONCodingKeys {
    return nil;
}

- (NSString *)description {
    return [XZJSON modelDescription:self];
}

@end

