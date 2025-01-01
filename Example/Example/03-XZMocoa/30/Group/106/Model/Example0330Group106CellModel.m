//
//  Example0330Group106CellModel.m
//  Example
//
//  Created by Xezun on 2023/8/20.
//

#import "Example0330Group106CellModel.h"

@implementation Example0330Group106CellModel

+ (void)load {
    XZModule(@"https://mocoa.xezun.com/examples/30/table/106/:/").modelClass = self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, %@>", NSStringFromClass(self.class), self, self.text];
}

@end
