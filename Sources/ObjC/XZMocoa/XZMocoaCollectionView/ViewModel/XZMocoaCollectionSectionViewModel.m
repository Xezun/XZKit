//
//  XZMocoaCollectionSectionViewModel.m
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#import "XZMocoaCollectionSectionViewModel.h"
#import "XZMocoaCollectionPlaceholderCellViewModel.h"
#import "XZMocoaCollectionPlaceholderSupplementaryViewModel.h"

@implementation XZMocoaCollectionSectionViewModel

- (__kindof XZMocoaCollectionSupplementaryViewModel *)viewModelForSupplementaryElementOfKind:(XZMocoaKind)kind atIndex:(NSInteger)index {
    return [super viewModelForSupplementaryElementOfKind:kind atIndex:index];
}

- (Class)placeholderViewModelClassForCellAtIndex:(NSInteger)index {
    return [XZMocoaCollectionPlaceholderCellViewModel class];
}

- (Class)placeholderViewModelClassForSupplementaryKind:(XZMocoaKind)kind atIndex:(NSInteger)index {
    return [XZMocoaCollectionPlaceholderSupplementaryViewModel class];
}

@end
