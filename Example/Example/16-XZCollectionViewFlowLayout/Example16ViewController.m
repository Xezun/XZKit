//
//  Example16ViewController.m
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import "Example16ViewController.h"
#import "Example16CollectonViewCellModel.h"
#import "Example16CollectonViewSectionModel.h"
#import "Example16CollectonViewSectionHeaderFooterView.h"
#import "Example16SettingsEditSectionViewController.h"
#import "Example16SettingsViewController.h"
#import "Example16SettingsEditCellViewController.h"
@import XZCollectionViewFlowLayout;


@interface Example16ViewController () <XZCollectionViewDelegateFlowLayout, Example16CollectonViewSectionHeaderFooterViewDelegate> {
    NSArray<Example16CollectonViewSectionModel *> *_dataArray;
}

@end

@implementation Example16ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadData];
    
    UICollectionView * const collectionView = self.collectionView;
    [collectionView registerClass:[Example16CollectonViewSectionHeaderFooterView class]
       forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header"];
    [collectionView registerClass:[Example16CollectonViewSectionHeaderFooterView class]
       forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Footer"];
}

- (void)loadData {
    XZCollectionViewFlowLayout *layout = (id)self.collectionView.collectionViewLayout;
    UICollectionViewScrollDirection scrollDirection = layout.scrollDirection;
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:10];
    for (NSInteger section = 0; section < 10; section++) {
        Example16CollectonViewSectionModel *model = [[Example16CollectonViewSectionModel alloc] initWithScrollDirection:scrollDirection];
        [sections addObject:model];
    }
    _dataArray = sections.copy;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _dataArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArray[section].cells.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.contentView.backgroundColor = _dataArray[indexPath.section].cells[indexPath.item].color;
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    NSString *identifer = [kind isEqualToString:UICollectionElementKindSectionHeader] ? @"Header" : @"Footer";
    Example16CollectonViewSectionHeaderFooterView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:identifer forIndexPath:indexPath];
    view.index = indexPath.section;
    view.delegate = self;
    return view;
}

- (enum XZCollectionViewLineAlignment)collectionView:(UICollectionView *)collectionView layout:(XZCollectionViewFlowLayout *)layout lineAlignmentForLineAtIndexPath:(NSIndexPath *)indexPath {
    return [_dataArray[indexPath.section] lineAlignmentForItemsInLine:indexPath.xz_line];
}

- (enum XZCollectionViewInteritemAlignment)collectionView:(UICollectionView *)collectionView layout:(XZCollectionViewFlowLayout *)layout interitemAlignmentForItemAtIndexPath:(NSIndexPath *)indexPath {
    Example16CollectonViewSectionModel * const section = _dataArray[indexPath.section];
    Example16CollectonViewCellModel    * const cell    = section.cells[indexPath.item];
    return cell.isCustomized ? cell.interitemAlignment : section.interitemAlignment;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _dataArray[indexPath.section].cells[indexPath.item].size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return _dataArray[section].lineSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return _dataArray[section].interitemSpacing;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return _dataArray[section].edgeInsets;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return _dataArray[section].headerSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return _dataArray[section].footerSize;
}

- (void)didSelectHeaderFooterView:(Example16CollectonViewSectionHeaderFooterView *)headerFooterView {
    [self performSegueWithIdentifier:@"SectionSettings" sender:headerFooterView];
}

- (IBAction)navBackButtonAction:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"点击 Header/Footer 可调整 Section 配置；\n点击 Cell 可调整 Cell 的配置。" preferredStyle:(UIAlertControllerStyleAlert)];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)unwindToChangeScrollDirection:(UIStoryboardSegue *)unwindSegue {
    if ([unwindSegue.identifier isEqualToString:@"Horizontal"]) {
        XZCollectionViewFlowLayout *layout = (id)self.collectionView.collectionViewLayout;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    } else {
        XZCollectionViewFlowLayout *layout = (id)self.collectionView.collectionViewLayout;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    [self loadData];
    [self.collectionView reloadData];
}

- (IBAction)unwindToReloadData:(UIStoryboardSegue *)unwindSegue {
    [self loadData];
    [self.collectionView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *identifier = segue.identifier;
    if ([identifier isEqualToString:@"SectionSettings"]) {
        Example16CollectonViewSectionHeaderFooterView *view = sender;
        NSInteger const index = view.index;
        Example16CollectonViewSectionModel *model = _dataArray[index];
        Example16SettingsEditSectionViewController *vc = segue.destinationViewController;
        [vc setDataForSection:model atIndex:index];
    } else if ([identifier isEqualToString:@"Settings"]) {
        Example16SettingsViewController *vc = segue.destinationViewController;
        vc.sections = _dataArray;
    } else if ([identifier isEqualToString:@"CellSettings"]) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        Example16SettingsEditCellViewController *vc = segue.destinationViewController;
        [vc setDataWithModel:_dataArray[indexPath.section] indexPath:indexPath];
    }
}

- (IBAction)unwindToNavigateBack:(UIStoryboardSegue *)unwindSegue {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)unwindToConfirmSectionSettings:(UIStoryboardSegue *)unwindSegue {
    Example16SettingsEditSectionViewController *vc = unwindSegue.sourceViewController;
    Example16CollectonViewSectionModel *model = _dataArray[vc.index];
    model.lineSpacing        = vc.lineSpacing;
    model.interitemSpacing   = vc.interitemSpacing;
    model.edgeInsets         = vc.edgeInsets;
    model.lineAlignmentStyle = vc.lineAlignmentStyle;
    model.interitemAlignment = vc.interitemAlignment;
    model.headerSize = vc.headerSize;
    model.footerSize = vc.footerSize;
    [self.collectionView reloadData];
}

- (IBAction)unwindToConfirmCellSettings:(UIStoryboardSegue *)unwindSegue {
    Example16SettingsEditCellViewController *vc = unwindSegue.sourceViewController;
    NSIndexPath *indexPath = vc.indexPath;
    Example16CollectonViewCellModel *model = _dataArray[indexPath.section].cells[indexPath.item];
    model.size = vc.size;
    model.isCustomized = vc.isCustomized;
    model.interitemAlignment = vc.interitemAlignment;
    [self.collectionView reloadData];
}

@end

