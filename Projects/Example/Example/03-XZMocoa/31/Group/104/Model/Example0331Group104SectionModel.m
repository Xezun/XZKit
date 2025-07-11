//
//  Example0331Group104SectionModel.m
//  Example
//
//  Created by Xezun on 2023/8/20.
//

#import "Example0331Group104SectionModel.h"

@implementation Example0331Group104SectionModel
+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/31/collection/104/").modelClass = self;
}

- (XZMocoaName)mocoaName {
    return @"104";
}

- (NSInteger)numberOfCellModels {
    return 1;
}

- (id)modelForCellAtIndex:(NSInteger)index {
    return _model;
}
@end
