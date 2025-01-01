//
//  Example0320Group102CellModel.m
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import "Example0320Group102CellModel.h"

@implementation Example0320Group102CellModel

+ (void)load {
    XZModule(@"https://mocoa.xezun.com/examples/20/table/102/:/").modelClass = self;
}

- (BOOL)isEqual:(Example0320Group102CellModel *)object {
    if (object == self) return YES;
    if (![object isKindOfClass:[Example0320Group102CellModel class]]) return NO;
    return [self.nid isEqualToString:object.nid];
}

@end
