//
//  XZMocoaTableViewProxy.m
//  XZKit
//
//  Created by 徐臻 on 2025/1/20.
//

#import "XZMocoaTableViewProxy.h"
#import "XZMocoaTableViewPlaceholderHeaderFooterView.h"
#import "XZMocoaTableViewPlaceholderCell.h"
@import ObjectiveC;

@implementation XZMocoaTableViewProxy

@dynamic viewModel, contentView;

- (void)registerModule:(XZMocoaModule *)module {
    UITableView * const tableView = self.contentView;
    
    { // 注册默认视图
        NSString *identifier = XZMocoaReuseIdentifier(XZMocoaNamePlaceholder, XZMocoaKindCell, XZMocoaNamePlaceholder);
        [tableView registerClass:[XZMocoaTableViewPlaceholderCell class] forCellReuseIdentifier:identifier];
        
        identifier = XZMocoaReuseIdentifier(XZMocoaNamePlaceholder, XZMocoaKindHeader, XZMocoaNamePlaceholder);
        [tableView registerClass:[XZMocoaTableViewPlaceholderHeaderFooterView class] forHeaderFooterViewReuseIdentifier:identifier];
        
        identifier = XZMocoaReuseIdentifier(XZMocoaNamePlaceholder, XZMocoaKindFooter, XZMocoaNamePlaceholder);
        [tableView registerClass:[XZMocoaTableViewPlaceholderHeaderFooterView class] forHeaderFooterViewReuseIdentifier:identifier];
    }
    
    [module enumerateSubmodulesUsingBlock:^(XZMocoaModule *submodule, XZMocoaKind kind, XZMocoaName section, BOOL *stop) {
        if (![kind isEqualToString:XZMocoaKindSection]) {
            return; // 不是 section 的 module 不需要处理
        }

        [submodule enumerateSubmodulesUsingBlock:^(XZMocoaModule *submodule, XZMocoaKind kind, XZMocoaName name, BOOL *stop) {
            if ([kind isEqualToString:XZMocoaKindCell]) {
                switch (submodule.viewForm) {
                    case XZMocoaModuleViewFormClass: {
                        NSString * const identifier = XZMocoaReuseIdentifier(section, XZMocoaKindCell, name);
                        [tableView registerClass:submodule.viewClass forCellReuseIdentifier:identifier];
                        break;
                    }
                    case XZMocoaModuleViewFormNib: {
                        NSString * const identifier = XZMocoaReuseIdentifier(section, XZMocoaKindCell, name);
                        UINib *viewNib = [UINib nibWithNibName:submodule.viewNibName bundle:submodule.viewNibBundle];
                        [tableView registerNib:viewNib forCellReuseIdentifier:identifier];
                        break;
                    }
                    case XZMocoaModuleViewFormStoryboardReusableView: {
                        // 在 Storyboard 中 cell 已经注册
                        break;
                    }
                    default: {
                        NSString * const identifier = XZMocoaReuseIdentifier(section, XZMocoaKindCell, name);
                        // 未注册 View 的模块，获得一个占位视图
                        Class const aClass = [XZMocoaTableViewPlaceholderCell class];
                        [tableView registerClass:aClass forCellReuseIdentifier:identifier];
                        break;
                    }
                }
            } else if ([kind isEqualToString:XZMocoaKindHeader] || [kind isEqualToString:XZMocoaKindFooter]) {
                switch (submodule.viewForm) {
                    case XZMocoaModuleViewFormClass: {
                        NSString * const identifier = XZMocoaReuseIdentifier(section, kind, name);
                        [tableView registerClass:submodule.viewClass forHeaderFooterViewReuseIdentifier:identifier];
                        break;
                    }
                    case XZMocoaModuleViewFormNib: {
                        NSString * const identifier = XZMocoaReuseIdentifier(section, kind, name);
                        UINib *viewNib = [UINib nibWithNibName:submodule.viewNibName bundle:submodule.viewNibBundle];
                        [tableView registerNib:viewNib forHeaderFooterViewReuseIdentifier:identifier];
                        break;
                    }
                    case XZMocoaModuleViewFormStoryboardReusableView: {
                        break;
                    }
                    default: {
                        NSString * const identifier = XZMocoaReuseIdentifier(section, kind, name);
                        Class const aClass = [XZMocoaTableViewPlaceholderHeaderFooterView class];
                        [tableView registerClass:aClass forHeaderFooterViewReuseIdentifier:identifier];
                        break;
                    }
                }
            }
        }];
    }];
}

@end

@implementation XZMocoaTableViewProxy (UITableViewDataSource)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel numberOfCellsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XZMocoaTableViewCellViewModel * const viewModel = [self.viewModel cellViewModelAtIndexPath:indexPath];
    
    UITableViewCell<XZMocoaTableViewCell> *cell = [tableView dequeueReusableCellWithIdentifier:viewModel.identifier forIndexPath:indexPath];
    cell.viewModel = viewModel;
    
    return cell;
}

@end


@implementation XZMocoaTableViewProxy (UITableViewDelegate)

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    XZMocoaTableViewCellViewModel * const viewModel = [self.viewModel cellViewModelAtIndexPath:indexPath];
    return viewModel.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    XZMocoaTableViewSectionViewModel * const sectionViewModel = [self.viewModel sectionViewModelAtIndex:section];
    XZMocoaTableViewHeaderFooterViewModel * const viewModel = sectionViewModel.headerViewModel;
    if (viewModel == nil) {
        return nil;
    }
    UITableViewHeaderFooterView<XZMocoaTableViewHeaderFooterView> *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:viewModel.identifier];
    view.viewModel = viewModel;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    XZMocoaTableViewSectionViewModel * const sectionViewModel = [self.viewModel sectionViewModelAtIndex:section];
    XZMocoaTableViewHeaderFooterViewModel * const viewModel = sectionViewModel.headerViewModel;
    if (viewModel == nil) {
        return XZMocoaMinimumViewDimension;
    }
    return viewModel.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    XZMocoaTableViewSectionViewModel * const sectionViewModel = [self.viewModel sectionViewModelAtIndex:section];
    XZMocoaTableViewHeaderFooterViewModel * const viewModel = sectionViewModel.footerViewModel;
    if (viewModel == nil) {
        return nil;
    }
    UITableViewHeaderFooterView<XZMocoaTableViewHeaderFooterView> *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:viewModel.identifier];
    view.viewModel = viewModel;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    XZMocoaTableViewSectionViewModel * const sectionViewModel = [self.viewModel sectionViewModelAtIndex:section];
    XZMocoaTableViewHeaderFooterViewModel * const viewModel = sectionViewModel.footerViewModel;
    if (viewModel == nil) {
        return XZMocoaMinimumViewDimension;
    }
    return viewModel.height;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell<XZMocoaTableViewCell> *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell tableView:self willDisplayRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell<XZMocoaTableViewCell> *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    [cell tableView:self didEndDisplayingRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell<XZMocoaTableViewCell> *cell = (id)[tableView cellForRowAtIndexPath:indexPath];
    [cell tableView:self didSelectRowAtIndexPath:indexPath];
}

@end


@implementation XZMocoaTableViewProxy (XZMocoaTableViewModelDelegate)

- (void)tableViewModel:(XZMocoaTableViewModel *)tableViewModel didReloadData:(void *)null {
    [self.contentView reloadData];
}

- (void)tableViewModel:(XZMocoaTableViewModel *)tableViewModel didSelectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition {
    [self.contentView selectRowAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
}

- (void)tableViewModel:(XZMocoaTableViewModel *)tableViewModel didDeselectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    [self.contentView deselectRowAtIndexPath:indexPath animated:animated];
}

- (void)tableViewModel:(XZMocoaTableViewModel *)tableViewModel didReloadCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    UITableViewRowAnimation const rowAnimation = tableViewModel.rowAnimation;
    [self.contentView reloadRowsAtIndexPaths:indexPaths withRowAnimation:rowAnimation];
}

- (void)tableViewModel:(XZMocoaTableViewModel *)tableViewModel didInsertCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    UITableViewRowAnimation const rowAnimation = tableViewModel.rowAnimation;
    [self.contentView insertRowsAtIndexPaths:indexPaths withRowAnimation:rowAnimation];
}

- (void)tableViewModel:(XZMocoaTableViewModel *)tableViewModel didDeleteCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    UITableViewRowAnimation const rowAnimation = tableViewModel.rowAnimation;
    [self.contentView deleteRowsAtIndexPaths:indexPaths withRowAnimation:rowAnimation];
}

- (void)tableViewModel:(XZMocoaTableViewModel *)tableViewModel didMoveCellAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    [self.contentView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
}

- (void)tableViewModel:(XZMocoaTableViewModel *)tableViewModel didReloadSectionsAtIndexes:(NSIndexSet *)sections {
    UITableViewRowAnimation const rowAnimation = tableViewModel.rowAnimation;
    [self.contentView reloadSections:sections withRowAnimation:rowAnimation];
}

- (void)tableViewModel:(XZMocoaTableViewModel *)tableViewModel didDeleteSectionsAtIndexes:(NSIndexSet *)sections {
    UITableViewRowAnimation const rowAnimation = tableViewModel.rowAnimation;
    [self.contentView deleteSections:sections withRowAnimation:rowAnimation];
}

- (void)tableViewModel:(XZMocoaTableViewModel *)tableViewModel didInsertSectionsAtIndexes:(NSIndexSet *)sections {
    UITableViewRowAnimation const rowAnimation = tableViewModel.rowAnimation;
    [self.contentView insertSections:sections withRowAnimation:rowAnimation];
}

- (void)tableViewModel:(XZMocoaTableViewModel *)tableViewModel didMoveSectionAtIndex:(NSInteger)section toIndex:(NSInteger)newSection {
    [self.contentView moveSection:section toSection:newSection];
}

- (void)tableViewModel:(XZMocoaTableViewModel *)tableViewModel didPerformBatchUpdates:(void (^NS_NOESCAPE)(void))batchUpdates completion:(void (^ _Nullable)(BOOL))completion {
    if (@available(iOS 11.0, *)) {
        [self.contentView performBatchUpdates:batchUpdates completion:completion];
    } else {
        [self.contentView beginUpdates];
        batchUpdates();
        [self.contentView endUpdates];
        if (completion) dispatch_async(dispatch_get_main_queue(), ^{ completion(YES); });
    }
}

@end

