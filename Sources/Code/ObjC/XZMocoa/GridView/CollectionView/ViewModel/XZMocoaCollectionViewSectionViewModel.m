//
//  XZMocoaCollectionViewSectionViewModel.m
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#import "XZMocoaCollectionViewSectionViewModel.h"
#import "XZMocoaCollectionViewPlaceholderCellViewModel.h"
#import "XZMocoaCollectionViewPlaceholderSupplementaryViewModel.h"

@implementation XZMocoaCollectionViewSectionViewModel

- (__kindof XZMocoaCollectionViewSupplementaryViewModel *)viewModelForSupplementaryElementOfKind:(XZMocoaKind)kind atIndex:(NSInteger)index {
    return [super viewModelForSupplementaryElementOfKind:kind atIndex:index];
}

- (Class)placeholderViewModelClassForCellAtIndex:(NSInteger)index {
    return [XZMocoaCollectionViewPlaceholderCellViewModel class];
}

- (Class)placeholderViewModelClassForSupplementaryKind:(XZMocoaKind)kind atIndex:(NSInteger)index {
    return [XZMocoaCollectionViewPlaceholderSupplementaryViewModel class];
}

@end
