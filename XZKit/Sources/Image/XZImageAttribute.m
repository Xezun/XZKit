//
//  XZImageAttribute.m
//  XZKit
//
//  Created by Xezun on 2021/2/21.
//

#import "XZImageAttribute.h"
#import "XZImageAttribute+Extension.h"

@implementation XZImageAttribute

- (void)subAttribute:(__kindof XZImageAttribute *)subAttribute didUpdateAttribute:(id)attribute {
    [self didUpdateAttribute:subAttribute];
}

- (void)didUpdateAttribute:(id)attribute {
    [self.superAttribute subAttribute:self didUpdateAttribute:attribute];
}

@end
