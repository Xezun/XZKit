//
//  XZMocoaCollectionSectionViewModel.m
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#import "XZMocoaCollectionSectionViewModel.h"
#import "XZMocoaCollectionPlaceholderCellViewModel.h"
#import "XZMocoaCollectionPlaceholderSectionSupplementaryViewModel.h"

@implementation XZMocoaCollectionSectionViewModel

- (__kindof XZMocoaCollectionSectionSupplementaryViewModel *)viewModelForSupplementaryElementOfKind:(XZMocoaKind)kind atIndex:(NSInteger)index {
    return [super viewModelForSupplementaryElementOfKind:kind atIndex:index];
}

- (Class)placeholderViewModelClassForCellAtIndex:(NSInteger)index {
    return [XZMocoaCollectionPlaceholderCellViewModel class];
}

- (Class)placeholderViewModelClassForSupplementaryKind:(XZMocoaKind)kind atIndex:(NSInteger)index {
    return [XZMocoaCollectionPlaceholderSectionSupplementaryViewModel class];
}

@end
