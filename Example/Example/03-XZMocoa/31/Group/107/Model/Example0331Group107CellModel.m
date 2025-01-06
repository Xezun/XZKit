//
//  Example0331Group107CellModel.m
//  Example
//
//  Created by Xezun on 2023/8/20.
//

#import "Example0331Group107CellModel.h"

@implementation Example0331Group107CellModel
+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/31/collection/107/:/").modelClass = self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, %@>", NSStringFromClass(self.class), self, self.text];
}
@end
