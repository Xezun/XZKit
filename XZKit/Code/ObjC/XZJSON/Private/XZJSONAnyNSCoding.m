//
//  XZJSONAnyNSCoding.m
//  XZJSON
//
//  Created by 徐臻 on 2025/2/18.
//

#import "XZJSONAnyNSCoding.h"
#import "XZJSON.h"

@implementation XZJSONAnyNSCoding

- (instancetype)initWithBase:(id)base {
    self = [super init];
    if (self) {
        _base = base;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    if (_base == nil) {
        return;
    }
    
    NSError *error = nil;
    
    Class    const type = [_base class];
    NSData * const base = [XZJSON encode:_base options:kNilOptions error:&error];
    
    [coder encodeObject:NSStringFromClass(type) forKey:@"type"];
    if (base == nil || error.code != noErr) {
        return;
    }
    [coder encodeObject:base forKey:@"base"];
}

- (id)initWithCoder:(NSCoder *)coder {
    NSString * const name = [coder decodeObjectOfClass:NSString.class forKey:@"type"];
    if (name) {
        Class const type = NSClassFromString(name);
        if (type) {
            NSData * const base = [coder decodeObjectOfClass:NSData.class forKey:@"base"];
            if (base) {
                return [XZJSON decode:base options:kNilOptions class:type];
            }
        }
    }
    return nil;
}

- (NSUInteger)hash {
    return _base ? [_base hash] : [super hash];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end
