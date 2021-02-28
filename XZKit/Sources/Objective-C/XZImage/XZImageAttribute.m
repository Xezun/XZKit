//
//  XZImageAttribute.m
//  XZKit
//
//  Created by Xezun on 2021/2/21.
//

#import "XZImageAttribute.h"
#import "XZImageAttribute+Extension.h"

@implementation XZImageAttribute

- (instancetype)init {
    @throw [NSException exceptionWithName:NSGenericException reason:@"必须使用指定初始化方法" userInfo:nil];
}

- (instancetype)initWithSuperAttribute:(id<XZImageAttribute>)superAttribute {
    self = [super init];
    if (self) {
        _superAttribute = superAttribute;
    }
    return self;
}

- (BOOL)isEffective {
    return NO;
}

- (void)subAttribute:(__kindof XZImageAttribute *)subAttribute didUpdateAttribute:(id)attribute {
    [self didUpdateAttribute:subAttribute];
}

- (void)didUpdateAttribute:(id)attribute {
    [self.superAttribute subAttribute:self didUpdateAttribute:attribute];
}

@end
