//
//  XZMocoaTableSectionViewModel.m
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#import "XZMocoaTableSectionViewModel.h"
#import "XZMocoaTablePlaceholderCellViewModel.h"
#import "XZMocoaTablePlaceholderSectionHeaderFooterViewModel.h"

@implementation XZMocoaTableSectionViewModel

- (XZMocoaTableSectionHeaderFooterViewModel *)headerViewModel {
    return [self viewModelForSupplementaryElementOfKind:XZMocoaKindHeader atIndex:0];
}

- (XZMocoaTableSectionHeaderFooterViewModel *)footerViewModel {
    return [self viewModelForSupplementaryElementOfKind:XZMocoaKindFooter atIndex:0];
}

- (CGFloat)height {
    CGFloat height = self.headerViewModel.height;
    for (XZMocoaTableCellViewModel *cellViewModel in self.cellViewModels) {
        height += cellViewModel.height;
    }
    height += self.footerViewModel.height;
    return height;
}

- (Class)placeholderViewModelClassForCellAtIndex:(NSInteger)index {
    return [XZMocoaTablePlaceholderCellViewModel class];
}

- (Class)placeholderViewModelClassForSupplementaryKind:(XZMocoaKind)kind atIndex:(NSInteger)index {
    NSAssert(index == 0, @"UITableView 仅支持一个 %@ 类型的附加视图", kind);
    return [XZMocoaTablePlaceholderSectionHeaderFooterViewModel class];
}

@end
