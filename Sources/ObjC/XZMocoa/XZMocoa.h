//
//  XZMocoa.h
//  XZMocoa
//
//  Created by Xezun on 2021/10/8.
//

#import <UIKit/UIKit.h>

// 命名推荐：
// 1、模型、视图、视图模型的类命名，分别以 Model、View、ViewModel 结尾。
// 2、其中以 Cell、Bar、Button、Slider、Control 结尾的视图，命名不用额外加 View 后缀，但是模型、视图模型须使用 Model、ViewModel 结尾。
// 3、基于上述两条规则，UITableViewCell 适配后命名为 XZMocoaTableCell

#if __has_include(<XZKit/XZKit.h>)

// XZMocoaDefines
#import <XZKit/XZMocoaDefines.h>
#import <XZKit/XZMocoaKey.h>
#import <XZKit/XZMocoaModule.h>
#import <XZKit/XZMocoaModuleDomain.h>

// XZMocoaView
#import <XZKit/XZMocoaModel.h>
#import <XZKit/XZMocoaView.h>
#import <XZKit/XZMocoaViewModel.h>

// XZMocoaGroupView
#import <XZKit/XZMocoaGroupCellModel.h>
#import <XZKit/XZMocoaGroupModel.h>
#import <XZKit/XZMocoaGroupSectionModel.h>
#import <XZKit/XZMocoaGroupCell.h>
#import <XZKit/XZMocoaGroupSectionSupplementaryView.h>
#import <XZKit/XZMocoaGroupView.h>
#import <XZKit/XZMocoaGroupCellViewModel.h>
#import <XZKit/XZMocoaGroupSectionViewModel.h>
#import <XZKit/XZMocoaGroupSectionSupplementaryViewModel.h>
#import <XZKit/XZMocoaGroupViewModel.h>
#import <XZKit/XZMocoaGroupViewModelDefines.h>

// XZMocoaTableView
#import <XZKit/XZMocoaTableCellModel.h>
#import <XZKit/XZMocoaTableModel.h>
#import <XZKit/XZMocoaTableSectionModel.h>
#import <XZKit/XZMocoaTableCell.h>
#import <XZKit/XZMocoaTableSectionHeaderFooterView.h>
#import <XZKit/XZMocoaTableView.h>
#import <XZKit/XZMocoaTableViewController.h>
#import <XZKit/XZMocoaTableCellViewModel.h>
#import <XZKit/XZMocoaTableSectionHeaderFooterViewModel.h>
#import <XZKit/XZMocoaTableSectionViewModel.h>
#import <XZKit/XZMocoaTableViewModel.h>

// XZMocoaCollectionView
#import <XZKit/XZMocoaCollectionCellModel.h>
#import <XZKit/XZMocoaCollectionModel.h>
#import <XZKit/XZMocoaCollectionSectionModel.h>
#import <XZKit/XZMocoaCollectionCell.h>
#import <XZKit/XZMocoaCollectionSectionSupplementaryView.h>
#import <XZKit/XZMocoaCollectionView.h>
#import <XZKit/XZMocoaCollectionViewController.h>
#import <XZKit/XZMocoaCollectionCellViewModel.h>
#import <XZKit/XZMocoaCollectionSectionViewModel.h>
#import <XZKit/XZMocoaCollectionSectionSupplementaryViewModel.h>
#import <XZKit/XZMocoaCollectionViewModel.h>

#else

// XZMocoaDefines
#import "XZMocoaDefines.h"
#import "XZMocoaKey.h"
#import "XZMocoaModule.h"
#import "XZMocoaModuleDomain.h"

// XZMocoaView
#import "XZMocoaModel.h"
#import "XZMocoaView.h"
#import "XZMocoaViewModel.h"

// XZMocoaGroupView
#import "XZMocoaGroupCellModel.h"
#import "XZMocoaGroupModel.h"
#import "XZMocoaGroupSectionModel.h"
#import "XZMocoaGroupCell.h"
#import "XZMocoaGroupSectionSupplementaryView.h"
#import "XZMocoaGroupView.h"
#import "XZMocoaGroupCellViewModel.h"
#import "XZMocoaGroupSectionViewModel.h"
#import "XZMocoaGroupSectionSupplementaryViewModel.h"
#import "XZMocoaGroupViewModel.h"
#import "XZMocoaGroupViewModelDefines.h"

// XZMocoaTableView
#import "XZMocoaTableCellModel.h"
#import "XZMocoaTableModel.h"
#import "XZMocoaTableSectionModel.h"
#import "XZMocoaTableCell.h"
#import "XZMocoaTableSectionHeaderFooterView.h"
#import "XZMocoaTableView.h"
#import "XZMocoaTableViewController.h"
#import "XZMocoaTableCellViewModel.h"
#import "XZMocoaTableSectionHeaderFooterViewModel.h"
#import "XZMocoaTableSectionViewModel.h"
#import "XZMocoaTableViewModel.h"

// XZMocoaCollectionView
#import "XZMocoaCollectionCellModel.h"
#import "XZMocoaCollectionModel.h"
#import "XZMocoaCollectionSectionModel.h"
#import "XZMocoaCollectionCell.h"
#import "XZMocoaCollectionSectionSupplementaryView.h"
#import "XZMocoaCollectionView.h"
#import "XZMocoaCollectionViewController.h"
#import "XZMocoaCollectionCellViewModel.h"
#import "XZMocoaCollectionSectionViewModel.h"
#import "XZMocoaCollectionSectionSupplementaryViewModel.h"
#import "XZMocoaCollectionViewModel.h"

#endif
