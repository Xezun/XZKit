//
//  Example0330Group104CellModel.m
//  Example
//
//  Created by Xezun on 2023/8/20.
//

#import "Example0330Group104CellModel.h"

@implementation Example0330Group104CellModel

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/30/table/104/:/").modelClass = self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, %@>", NSStringFromClass(self.class), self, self.text];
}
@end
