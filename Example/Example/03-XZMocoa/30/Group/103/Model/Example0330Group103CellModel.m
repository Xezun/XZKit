//
//  Example0330Group103CellModel.m
//  Example
//
//  Created by Xezun on 2023/8/20.
//

#import "Example0330Group103CellModel.h"

@implementation Example0330Group103CellModel

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, %@>", NSStringFromClass(self.class), self, self.text];
}

@end