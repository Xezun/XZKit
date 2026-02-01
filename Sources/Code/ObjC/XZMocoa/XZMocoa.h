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

// Core
#import <XZKit/XZMocoaDefines.h>
#import <XZKit/XZMocoaModule.h>
#import <XZKit/XZMocoaModuleDomain.h>

// View
#import <XZKit/XZMocoaModel.h>
#import <XZKit/XZMocoaView.h>
#import <XZKit/XZMocoaViewModel.h>

// GridView
#import <XZKit/XZMocoaGridCellModel.h>
#import <XZKit/XZMocoaGridModel.h>
#import <XZKit/XZMocoaGridSectionModel.h>
#import <XZKit/XZMocoaGridCell.h>
#import <XZKit/XZMocoaGridSupplementaryView.h>
#import <XZKit/XZMocoaGridView.h>
#import <XZKit/XZMocoaGridCellViewModel.h>
#import <XZKit/XZMocoaGridSectionViewModel.h>
#import <XZKit/XZMocoaGridSupplementaryViewModel.h>
#import <XZKit/XZMocoaGridViewModel.h>
#import <XZKit/XZMocoaGridViewModelDefines.h>

// TableView
#import <XZKit/XZMocoaTableCellModel.h>
#import <XZKit/XZMocoaTableModel.h>
#import <XZKit/XZMocoaTableSectionModel.h>
#import <XZKit/XZMocoaTableCell.h>
#import <XZKit/XZMocoaTableHeaderFooterView.h>
#import <XZKit/XZMocoaTableView.h>
#import <XZKit/XZMocoaTableViewController.h>
#import <XZKit/XZMocoaTableCellViewModel.h>
#import <XZKit/XZMocoaTableHeaderFooterViewModel.h>
#import <XZKit/XZMocoaTableSectionViewModel.h>
#import <XZKit/XZMocoaTableViewModel.h>

// CollectionView
#import <XZKit/XZMocoaCollectionCellModel.h>
#import <XZKit/XZMocoaCollectionModel.h>
#import <XZKit/XZMocoaCollectionSectionModel.h>
#import <XZKit/XZMocoaCollectionCell.h>
#import <XZKit/XZMocoaCollectionSupplementaryView.h>
#import <XZKit/XZMocoaCollectionView.h>
#import <XZKit/XZMocoaCollectionViewController.h>
#import <XZKit/XZMocoaCollectionCellViewModel.h>
#import <XZKit/XZMocoaCollectionSectionViewModel.h>
#import <XZKit/XZMocoaCollectionSupplementaryViewModel.h>
#import <XZKit/XZMocoaCollectionViewModel.h>

#else

#import "XZMocoaDefines.h"
#import "XZMocoaModule.h"
#import "XZMocoaModuleDomain.h"

// View
#import "XZMocoaModel.h"
#import "XZMocoaView.h"
#import "XZMocoaViewModel.h"

// GridView
#import "XZMocoaGridCellModel.h"
#import "XZMocoaGridModel.h"
#import "XZMocoaGridSectionModel.h"
#import "XZMocoaGridCell.h"
#import "XZMocoaGridSupplementaryView.h"
#import "XZMocoaGridView.h"
#import "XZMocoaGridCellViewModel.h"
#import "XZMocoaGridSectionViewModel.h"
#import "XZMocoaGridSupplementaryViewModel.h"
#import "XZMocoaGridViewModel.h"
#import "XZMocoaGridViewModelDefines.h"

// TableView
#import "XZMocoaTableCellModel.h"
#import "XZMocoaTableModel.h"
#import "XZMocoaTableSectionModel.h"
#import "XZMocoaTableCell.h"
#import "XZMocoaTableHeaderFooterView.h"
#import "XZMocoaTableView.h"
#import "XZMocoaTableViewController.h"
#import "XZMocoaTableCellViewModel.h"
#import "XZMocoaTableHeaderFooterViewModel.h"
#import "XZMocoaTableSectionViewModel.h"
#import "XZMocoaTableViewModel.h"

// CollectionView
#import "XZMocoaCollectionCellModel.h"
#import "XZMocoaCollectionModel.h"
#import "XZMocoaCollectionSectionModel.h"
#import "XZMocoaCollectionCell.h"
#import "XZMocoaCollectionSupplementaryView.h"
#import "XZMocoaCollectionView.h"
#import "XZMocoaCollectionViewController.h"
#import "XZMocoaCollectionCellViewModel.h"
#import "XZMocoaCollectionSectionViewModel.h"
#import "XZMocoaCollectionSupplementaryViewModel.h"
#import "XZMocoaCollectionViewModel.h"

#endif
