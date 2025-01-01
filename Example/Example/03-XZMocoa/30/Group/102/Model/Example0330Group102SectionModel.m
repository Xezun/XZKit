//
//  Example0330Group102SectionModel.m
//  Example
//
//  Created by Xezun on 2023/8/20.
//

#import "Example0330Group102SectionModel.h"

@implementation Example0330Group102SectionModel
+ (void)load {
    XZModule(@"https://mocoa.xezun.com/examples/30/table/102/").modelClass = self;
}

- (XZMocoaName)mocoaName {
    return @"102";
}

- (NSInteger)numberOfCellModels {
    return 1;
}

- (id)modelForCellAtIndex:(NSInteger)index {
    return _model;
}

@end
