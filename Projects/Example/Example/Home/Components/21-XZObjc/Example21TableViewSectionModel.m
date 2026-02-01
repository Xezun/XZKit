//
//  Example21TableViewSectionModel.m
//  Example
//
//  Created by 徐臻 on 2025/1/31.
//

#import "Example21TableViewSectionModel.h"

@implementation Example21TableViewSectionModel {
    NSString *_name;
    NSArray *_descriptors;
}

+ (instancetype)modelWithName:(NSString *)name descriptors:(NSArray *)descriptors {
    return [[self alloc] initWithName:name descriptors:descriptors];
}

- (instancetype)initWithName:(NSString *)name descriptors:(NSArray *)descriptors {
    self = [super init];
    if (self) {
        _name = name;
        _descriptors = descriptors;
    }
    return self;
}

- (id)headerModel {
    return _name;
}

- (NSInteger)numberOfCellModels {
    return _descriptors.count;
}

- (id)modelForCellAtIndex:(NSInteger)index {
    return _descriptors[index];
}

@end
