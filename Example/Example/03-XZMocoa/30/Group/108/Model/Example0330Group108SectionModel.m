//
//  Example0330Group108SectionModel.m
//  Example
//
//  Created by Xezun on 2023/8/20.
//

#import "Example0330Group108SectionModel.h"

@implementation Example0330Group108SectionModel

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/30/table/108/").modelClass = self;
}

- (XZMocoaName)mocoaName {
    return @"108";
}

- (NSInteger)numberOfCellModels {
    return 1;
}

- (id)modelForCellAtIndex:(NSInteger)index {
    return _model;
}

- (id)headerModel {
    return _title;
}

- (id)footerModel {
    return _notes;
}

@end
