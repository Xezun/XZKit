//
//  Example0331Group103SectionModel.m
//  Example
//
//  Created by Xezun on 2023/8/20.
//

#import "Example0331Group103SectionModel.h"

@implementation Example0331Group103SectionModel
+ (void)load {
    XZModule(@"https://mocoa.xezun.com/examples/31/collection/103/").modelClass = self;
}

- (XZMocoaName)mocoaName {
    return @"103";
}

- (NSInteger)numberOfCellModels {
    return 1;
}

- (id)modelForCellAtIndex:(NSInteger)index {
    return _model;
}
@end
