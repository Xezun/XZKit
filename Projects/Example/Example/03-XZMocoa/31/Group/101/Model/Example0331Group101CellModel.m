//
//  Example0331Group101CellModel.m
//  Example
//
//  Created by Xezun on 2023/8/20.
//

#import "Example0331Group101CellModel.h"

@implementation Example0331Group101CellModel
+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/31/collection/101/:/").modelClass = self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, %@>", NSStringFromClass(self.class), self, self.text];
}
@end
