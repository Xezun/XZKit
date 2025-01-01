//
//  XZMocoaCollectionView.m
//  XZMocoa
//
//  Created by Xezun on 2023/7/24.
//

#import "XZMocoaCollectionView.h"
#import "XZMocoaCollectionViewCell.h"
#import "XZMocoaCollectionViewSupplementaryView.h"
#import "XZMocoaCollectionViewPlaceholderCell.h"
#import "XZMocoaCollectionViewPlaceholderSupplementaryView.h"

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

@implementation XZMocoaCollectionView

@dynamic viewModel, contentView;

- (instancetype)initWithCoder:(NSCoder *)coder {
    return [super initWithCoder:coder];
}

- (instancetype)initWithCollectionViewClass:(Class)collectionViewClass layout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:UIScreen.mainScreen.bounds];
    if (self) {
        UICollectionView *contentView = [[collectionViewClass alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        [super setContentView:contentView];
    }
    return self;
}

- (instancetype)initWithLayout:(UICollectionViewLayout *)layout {
    return [self initWithFrame:UIScreen.mainScreen.bounds layout:layout];
}

- (instancetype)initWithFrame:(CGRect)frame layout:(UICollectionViewLayout *)layout {
    self = [self initWithCollectionViewClass:UICollectionView.class layout:layout];
    if (self) {
        self.frame = frame;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    return [self initWithCollectionViewClass:UICollectionView.class layout:layout];
}

- (void)contentViewWillChange {
    [super contentViewWillChange];
    
    UICollectionView *contentView = self.contentView;
    contentView.delegate = nil;
    contentView.dataSource = nil;
}

- (void)contentViewDidChange {
    [super contentViewDidChange];
    
    UICollectionView *contentView = self.contentView;
    contentView.delegate   = self;
    contentView.dataSource = self;
}

- (void)viewModelDidChange {
    [super viewModelDidChange];
    
    // 刷新视图。
    UICollectionView * const collectionView = self.contentView;
    if (@available(iOS 11.0, *)) {
        if (collectionView && !collectionView.hasUncommittedUpdates) {
            [collectionView reloadData];
        }
    } else {
        [collectionView reloadData];
    }
}

- (void)registerModule:(XZMocoaModule *)module {
    UICollectionView * const collectionView = self.contentView;
    
    { // 注册一个默认的视图
        NSString * const identifier = XZMocoaReuseIdentifier(XZMocoaNamePlaceholder, XZMocoaKindCell, XZMocoaNamePlaceholder);
        [collectionView registerClass:[XZMocoaCollectionViewPlaceholderCell class] forCellWithReuseIdentifier:identifier];
        
        for (XZMocoaKind kind in self.viewModel.supportedSupplementaryKinds) {
            NSString * const elementKind = UIElementKindFromMocoaKind(kind);
            Class      const aClass      = [XZMocoaCollectionViewPlaceholderSupplementaryView class];
            NSString * const identifier  = XZMocoaReuseIdentifier(XZMocoaNamePlaceholder, kind, XZMocoaNamePlaceholder);
            [collectionView registerClass:aClass forSupplementaryViewOfKind:elementKind withReuseIdentifier:identifier];
        }
    }
    
    [module enumerateSubmodulesUsingBlock:^(XZMocoaModule *submodule, XZMocoaKind kind, XZMocoaName section, BOOL *stop) {
        if (![kind isEqualToString:XZMocoaKindSection]) {
            return; // 不是 section 的 module 不需要处理
        }
        
        [submodule enumerateSubmodulesUsingBlock:^(XZMocoaModule *submodule, XZMocoaKind kind, XZMocoaName name, BOOL *stop) {
            if ([kind isEqualToString:XZMocoaKindCell]) {
                NSString * const identifier = XZMocoaReuseIdentifier(section, kind, name);
                if (submodule.viewNibName != nil) {
                    UINib *viewNib = [UINib nibWithNibName:submodule.viewNibName bundle:submodule.viewNibBundle];
                    [collectionView registerNib:viewNib forCellWithReuseIdentifier:identifier];
                } else if (submodule.viewClass != Nil) {
                    [collectionView registerClass:submodule.viewClass forCellWithReuseIdentifier:identifier];
                } else {
                    Class const aClass = [XZMocoaCollectionViewPlaceholderCell class];
                    [collectionView registerClass:aClass forCellWithReuseIdentifier:identifier];
                }
            } else {
                NSString * const identifier = XZMocoaReuseIdentifier(section, kind, name);
                NSString * const elementKind = UIElementKindFromMocoaKind(kind);
                if (submodule.viewNibName != Nil) {
                    UINib *viewNib = [UINib nibWithNibName:submodule.viewNibName bundle:submodule.viewNibBundle];
                    [collectionView registerNib:viewNib forSupplementaryViewOfKind:elementKind withReuseIdentifier:identifier];
                } else if (submodule.viewClass != Nil) {
                    [collectionView registerClass:submodule.viewClass forSupplementaryViewOfKind:elementKind withReuseIdentifier:identifier];
                } else {
                    Class const aClass = [XZMocoaCollectionViewPlaceholderSupplementaryView class];
                    [collectionView registerClass:aClass forSupplementaryViewOfKind:elementKind withReuseIdentifier:identifier];
                }
            }
        }];
    }];
}

- (void)unregisterModule:(XZMocoaModule *)module {
    
}

@end

@implementation XZMocoaCollectionView (UIScrollViewDelegate)
@end

@implementation XZMocoaCollectionView (UICollectionViewDelegate)

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell<XZMocoaCollectionViewCell> *cell = (id)[collectionView cellForItemAtIndexPath:indexPath];
    [cell collectionView:self didSelectItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell<XZMocoaCollectionViewCell> *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [cell collectionView:self willDisplayItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell<XZMocoaCollectionViewCell> *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [cell collectionView:self didEndDisplayingItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView<XZMocoaCollectionViewSupplementaryView> *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    [view collectionView:self willDisplaySupplementaryViewAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView<XZMocoaCollectionViewSupplementaryView> *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    [view collectionView:self didEndDisplayingSupplementaryViewAtIndexPath:indexPath];
}

@end


@implementation XZMocoaCollectionView (UICollectionViewDataSource)

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.viewModel numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.viewModel numberOfCellsInSection:section];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XZMocoaCollectionViewCellViewModel *viewModel = [self.viewModel cellViewModelAtIndexPath:indexPath];
    UICollectionViewCell<XZMocoaCollectionViewCell> *cell = [collectionView dequeueReusableCellWithReuseIdentifier:viewModel.identifier forIndexPath:indexPath];
    cell.viewModel = viewModel;
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    XZMocoaKind const mocoaKind = XZMocoaKindFromElementKind(kind);
    
    XZMocoaCollectionViewSupplementaryViewModel *viewModel = [[self.viewModel sectionViewModelAtIndex:indexPath.section] viewModelForSupplementaryKind:mocoaKind atIndex:indexPath.item];
    if (viewModel == nil) {
        return nil;
    }
    UICollectionReusableView<XZMocoaCollectionViewSupplementaryView> *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:viewModel.identifier forIndexPath:indexPath];
    view.viewModel = viewModel;
    return view;
}

@end

@implementation XZMocoaCollectionView (UICollectionViewDelegateFlowLayout)

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    XZMocoaCollectionViewCellViewModel *viewModel = [self.viewModel cellViewModelAtIndexPath:indexPath];
    return viewModel.size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    XZMocoaCollectionViewSectionViewModel *viewModel = [self.viewModel sectionViewModelAtIndex:section];
    return viewModel.insets;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    XZMocoaCollectionViewSectionViewModel *viewModel = [self.viewModel sectionViewModelAtIndex:section];
    return viewModel.minimumLineSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    XZMocoaCollectionViewSectionViewModel *viewModel = [self.viewModel sectionViewModelAtIndex:section];
    return viewModel.minimumInteritemSpacing;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    XZMocoaCollectionViewSupplementaryViewModel *viewModel = [[self.viewModel sectionViewModelAtIndex:section] viewModelForSupplementaryKind:XZMocoaKindHeader atIndex:0];
    return viewModel.size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    XZMocoaCollectionViewSupplementaryViewModel *viewModel = [[self.viewModel sectionViewModelAtIndex:section] viewModelForSupplementaryKind:XZMocoaKindFooter atIndex:0];
    return viewModel.size;
}

@end


@implementation XZMocoaCollectionView (XZMocoaCollectionViewModelDelegate)

- (void)collectionViewModel:(XZMocoaCollectionViewModel *)collectionViewModel didReloadData:(void *)null {
    [self.contentView reloadData];
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
