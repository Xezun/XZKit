//
//  XZMocoaCollectionViewProxy.m
//  XZKit
//
//  Created by Xezun on 2025/1/20.
//

#import "XZMocoaCollectionViewProxy.h"
#import "XZMocoaCollectionSupplementView.h"
#import "XZMocoaCollectionPlaceholderCell.h"
#import "XZMocoaCollectionPlaceholderSupplementView.h"
#import "XZGeometry.h"

static XZMocoaKind XZMocoaKindFromElementKind(NSString *kind) {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) return XZMocoaKindHeader;
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) return XZMocoaKindFooter;
    return kind;
}

static NSString *UIElementKindFromMocoaKind(XZMocoaKind kind) {
    if ([kind isEqualToString:XZMocoaKindHeader]) return UICollectionElementKindSectionHeader;
    if ([kind isEqualToString:XZMocoaKindFooter]) return UICollectionElementKindSectionFooter;
    return kind;
}

@implementation XZMocoaCollectionViewProxy

- (void)prepareForModule:(XZMocoaModule *)module {
    UICollectionView * const collectionView = self.contentView;
    
    { // 注册一个默认的视图
        NSString * const identifier = XZMocoaReuseIdentifier(XZMocoaKindDefault, XZMocoaNamePlaceholder);
        [collectionView registerClass:[XZMocoaCollectionPlaceholderCell class] forCellWithReuseIdentifier:identifier];
        
        for (XZMocoaKind kind in self.viewModel.supportedSupplementKinds) {
            NSString * const elementKind = UIElementKindFromMocoaKind(kind);
            Class      const aClass      = [XZMocoaCollectionPlaceholderSupplementView class];
            NSString * const identifier  = XZMocoaReuseIdentifier(kind, XZMocoaNamePlaceholder);
            [collectionView registerClass:aClass forSupplementaryViewOfKind:elementKind withReuseIdentifier:identifier];
        }
    }
    
    [module enumerateSubmodulesUsingBlock:^(XZMocoaModule * const submodule, XZMocoaKind const kind, XZMocoaName const name, BOOL *stop) {
        if ([kind isEqualToString:XZMocoaKindDefault]) {
            switch (submodule.viewForm) {
                case XZMocoaModuleViewFormClass: {
                    NSString * const identifier = XZMocoaReuseIdentifier(kind, name);
                    [collectionView registerClass:submodule.viewClass forCellWithReuseIdentifier:identifier];
                    break;
                }
                case XZMocoaModuleViewFormNib: {
                    NSString * const identifier = XZMocoaReuseIdentifier(kind, name);
                    UINib *viewNib = [UINib nibWithNibName:submodule.viewNibName bundle:submodule.viewNibBundle];
                    [collectionView registerNib:viewNib forCellWithReuseIdentifier:identifier];
                    break;
                }
                case XZMocoaModuleViewFormStoryboardReusableView: {
                    // 已通过 Storyboard 注册
                    break;
                }
                default: {
                    NSString * const identifier = XZMocoaReuseIdentifier(kind, name);
                    Class const aClass = [XZMocoaCollectionPlaceholderCell class];
                    [collectionView registerClass:aClass forCellWithReuseIdentifier:identifier];
                    break;
                }
            }
        } else {
            switch (submodule.viewForm) {
                case XZMocoaModuleViewFormClass: {
                    NSString * const identifier = XZMocoaReuseIdentifier(kind, name);
                    NSString * const elementKind = UIElementKindFromMocoaKind(kind);
                    [collectionView registerClass:submodule.viewClass forSupplementaryViewOfKind:elementKind withReuseIdentifier:identifier];
                    break;
                }
                case XZMocoaModuleViewFormNib: {
                    NSString * const identifier = XZMocoaReuseIdentifier(kind, name);
                    NSString * const elementKind = UIElementKindFromMocoaKind(kind);
                    UINib *viewNib = [UINib nibWithNibName:submodule.viewNibName bundle:submodule.viewNibBundle];
                    [collectionView registerNib:viewNib forSupplementaryViewOfKind:elementKind withReuseIdentifier:identifier];
                    break;
                }
                case XZMocoaModuleViewFormStoryboardReusableView: {
                    // 已通过 Storyboard 注册
                    break;
                }
                default: {
                    NSString * const identifier = XZMocoaReuseIdentifier(kind, name);
                    NSString * const elementKind = UIElementKindFromMocoaKind(kind);
                    Class const aClass = [XZMocoaCollectionPlaceholderSupplementView class];
                    [collectionView registerClass:aClass forSupplementaryViewOfKind:elementKind withReuseIdentifier:identifier];
                    break;
                }
            }
        }
    }];
}

@end

@implementation XZMocoaCollectionViewProxy (UICollectionViewDelegate)

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell<XZMocoaCollectionCell> *cell = (id)[collectionView cellForItemAtIndexPath:indexPath];
    [cell collectionView:(id)self didSelectItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [cell collectionView:(id)self willDisplayItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [cell collectionView:(id)self didEndDisplayingItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    [view collectionView:(id)self willDisplaySupplementaryViewAtIndexPath:indexPath forElementOfKind:elementKind];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    [view collectionView:(id)self didEndDisplayingSupplementaryViewAtIndexPath:indexPath forElementOfKind:elementKind];
}

@end


@implementation XZMocoaCollectionViewProxy (UICollectionViewDataSource)

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.viewModel numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.viewModel numberOfCellsInSection:section];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XZMocoaCollectionCellViewModel *viewModel = [self.viewModel viewModelForCellAtIndexPath:indexPath];
    UICollectionViewCell<XZMocoaCollectionCell> *cell = [collectionView dequeueReusableCellWithReuseIdentifier:viewModel.reuseIdentifier forIndexPath:indexPath];
    cell.viewModel = viewModel;
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    XZMocoaKind const mocoaKind = XZMocoaKindFromElementKind(kind);
    
    XZMocoaCollectionSupplementViewModel *viewModel = [self.viewModel viewModelForSupplementOfKind:mocoaKind atIndexPath:indexPath];
    if (viewModel == nil) {
        return nil;
    }
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:viewModel.reuseIdentifier forIndexPath:indexPath];
    view.viewModel = viewModel;
    return view;
}

@end

@implementation XZMocoaCollectionViewProxy (UICollectionViewDelegateFlowLayout)

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    id<UICollectionViewDelegateFlowLayout> const delegate = self.delegate;
    if (delegate) {
        return [delegate collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
    }
    
    XZMocoaCollectionCellViewModel * const viewModel = [self.viewModel viewModelForCellAtIndexPath:indexPath];
    CGSize const itemSize = viewModel.size;
    return CGSizeIsNull(itemSize) ? collectionViewLayout.itemSize : itemSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    id<UICollectionViewDelegateFlowLayout> const delegate = self.delegate;
    if (delegate) {
        return [delegate collectionView:collectionView layout:collectionViewLayout insetForSectionAtIndex:section];
    }
    
    UIEdgeInsets const sectionInsets = self.viewModel.sectionInsets;
    return UIEdgeInsetsIsNull(sectionInsets) ? collectionViewLayout.sectionInset : sectionInsets;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    id<UICollectionViewDelegateFlowLayout> const delegate = self.delegate;
    if (delegate) {
        return [delegate collectionView:collectionView layout:collectionViewLayout minimumLineSpacingForSectionAtIndex:section];
    }
    
    CGFloat const minimumLineSpacing = self.viewModel.minimumLineSpacing;
    return CGFloatIsNull(minimumLineSpacing) ? collectionViewLayout.minimumLineSpacing : minimumLineSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    id<UICollectionViewDelegateFlowLayout> const delegate = self.delegate;
    if (delegate) {
        return [delegate collectionView:collectionView layout:collectionViewLayout minimumInteritemSpacingForSectionAtIndex:section];
    }
    
    CGFloat const minimumInteritemSpacing = self.viewModel.minimumInteritemSpacing;
    return CGFloatIsNull(minimumInteritemSpacing) ? collectionViewLayout.minimumInteritemSpacing : minimumInteritemSpacing;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    id<UICollectionViewDelegateFlowLayout> const delegate = self.delegate;
    if (delegate) {
        return [delegate collectionView:collectionView layout:collectionViewLayout referenceSizeForHeaderInSection:section];
    }
    
    CGSize const headerReferenceSize = self.viewModel.headerReferenceSize;
    return CGSizeIsNull(headerReferenceSize) ? collectionViewLayout.headerReferenceSize : headerReferenceSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    id<UICollectionViewDelegateFlowLayout> const delegate = self.delegate;
    if (delegate) {
        return [delegate collectionView:collectionView layout:collectionViewLayout referenceSizeForFooterInSection:section];
    }
    
    CGSize const footerReferenceSize = self.viewModel.footerReferenceSize;
    return CGSizeIsNull(footerReferenceSize) ? collectionViewLayout.footerReferenceSize : footerReferenceSize;
}

@end


@implementation XZMocoaCollectionViewProxy (XZMocoaCollectionViewModelDelegate)

@dynamic viewModel;
@dynamic contentView;
@dynamic delegate;

- (void)collectionViewModel:(XZMocoaCollectionViewModel *)collectionViewModel didReloadData:(void *)null {
    [self.contentView reloadData];
}

- (void)collectionViewModel:(XZMocoaCollectionViewModel *)collectionViewModel didSelectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition {
    [self.contentView selectItemAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
}

- (void)collectionViewModel:(XZMocoaCollectionViewModel *)collectionViewModel didDeselectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    [self.contentView deselectItemAtIndexPath:indexPath animated:animated];
}

- (void)collectionViewModel:(XZMocoaCollectionViewModel *)collectionViewModel didReloadCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self.contentView reloadItemsAtIndexPaths:indexPaths];
}

- (void)collectionViewModel:(XZMocoaCollectionViewModel *)collectionViewModel didInsertCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self.contentView insertItemsAtIndexPaths:indexPaths];
}

- (void)collectionViewModel:(XZMocoaCollectionViewModel *)collectionViewModel didDeleteCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self.contentView deleteItemsAtIndexPaths:indexPaths];
}

- (void)collectionViewModel:(XZMocoaCollectionViewModel *)collectionViewModel didMoveCellAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    [self.contentView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
}

- (void)collectionViewModel:(XZMocoaCollectionViewModel *)collectionViewModel didReloadSectionsAtIndexes:(NSIndexSet *)sections {
    [self.contentView reloadSections:sections];
}

- (void)collectionViewModel:(XZMocoaCollectionViewModel *)collectionViewModel didInsertSectionsAtIndexes:(NSIndexSet *)sections {
    [self.contentView insertSections:sections];
}

- (void)collectionViewModel:(XZMocoaCollectionViewModel *)collectionViewModel didDeleteSectionsAtIndexes:(NSIndexSet *)sections {
    [self.contentView deleteSections:sections];
}

- (void)collectionViewModel:(XZMocoaCollectionViewModel *)collectionViewModel didMoveSectionAtIndex:(NSInteger)section toIndex:(NSInteger)newSection {
    [self.contentView moveSection:section toSection:newSection];
}

- (void)collectionViewModel:(XZMocoaCollectionViewModel *)collectionViewModel didPerformBatchUpdates:(void (^NS_NOESCAPE)(void))batchUpdates completion:(void (^ _Nullable)(BOOL))completion {
    [self.contentView performBatchUpdates:batchUpdates completion:completion];
}

@end
