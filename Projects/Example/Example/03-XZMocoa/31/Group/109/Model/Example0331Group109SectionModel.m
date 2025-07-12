//
//  Example0331Group109SectionModel.m
//  Example
//
//  Created by Xezun on 2023/8/20.
//

#import "Example0331Group109SectionModel.h"

@implementation Example0331Group109SectionModel

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/31/collection/109/").modelClass = self;
}

- (XZMocoaName)mocoaName {
    return @"109";
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
