//
//  Example21TableModel.m
//  Example
//
//  Created by Xezun on 2025/1/31.
//

#import "Example21TableModel.h"

@implementation Example21TableModel {
    NSArray<Example21TableSectionModel *> *_sectionModels;
}

- (instancetype)initWithSectionModels:(NSArray *)sectionModels {
    self = [super init];
    if (self) {
        _sectionModels = sectionModels.copy;
    }
    return self;
}

- (NSInteger)mocoa:(id)context numberOfSections:(id)null {
    return _sectionModels.count;
}

- (NSInteger)mocoa:(id)context numberOfCellsInSection:(NSInteger)section {
    return _sectionModels[section].descriptors.count;
}

- (id)mocoa:(id)context modelForCellAtIndexPath:(NSIndexPath *)indexPath {
    return _sectionModels[indexPath.section].descriptors[indexPath.row];
}

- (NSInteger)mocoa:(id)context kind:(XZMocoaKind)kind numberOfSupplementsInSection:(NSInteger)section {
    return [kind isEqualToString:XZMocoaKindHeader] ? 1 : 0;
}

- (id)mocoa:(id)context kind:(XZMocoaKind)kind modelForSupplementAtIndexPath:(NSIndexPath *)indexPath {
    return _sectionModels[indexPath.section].name;
}

@end

@implementation Example21TableSectionModel

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

@end
