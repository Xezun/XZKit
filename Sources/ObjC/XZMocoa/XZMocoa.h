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

#if __has_include("XZKit.h")
// XZMocoaDefines
#import "XZMocoaDefines.h"
#import "XZMocoaKey.h"
#import "XZMocoaModule.h"
#import "XZMocoaDomain.h"
// XZMocoaView
#import "XZMocoaModel.h"
#import "XZMocoaView.h"
#import "XZMocoaViewModel.h"
// XZMocoaGroupView
#import "XZMocoaGroupModel.h"
#import "XZMocoaGroupView.h"
#import "XZMocoaGroupViewModel.h"
#import "XZMocoaGroupReusableViewModel.h"
#import "XZMocoaGroupReusableView.h"
// XZMocoaTableView
#import "XZMocoaTableModel.h"
#import "XZMocoaTableView.h"
#import "XZMocoaTableViewController.h"
#import "XZMocoaTableViewModel.h"
#import "XZMocoaTableCell.h"
#import "XZMocoaTableCellViewModel.h"
#import "XZMocoaTableHeaderFooterView.h"
#import "XZMocoaTableHeaderFooterViewModel.h"
// XZMocoaCollectionView
#import "XZMocoaCollectionModel.h"
#import "XZMocoaCollectionView.h"
#import "XZMocoaCollectionViewController.h"
#import "XZMocoaCollectionViewModel.h"
#import "XZMocoaCollectionCell.h"
#import "XZMocoaCollectionCellViewModel.h"
#import "XZMocoaCollectionSupplementView.h"
#import "XZMocoaCollectionSupplementViewModel.h"
#else
// XZMocoaDefines
#import <XZKit/XZMocoaDefines.h>
#import <XZKit/XZMocoaKey.h>
#import <XZKit/XZMocoaModule.h>
#import <XZKit/XZMocoaDomain.h>

// XZMocoaView
#import <XZKit/XZMocoaModel.h>
#import <XZKit/XZMocoaView.h>
#import <XZKit/XZMocoaViewModel.h>

// XZMocoaGroupView
#import <XZKit/XZMocoaGroupModel.h>
#import <XZKit/XZMocoaGroupView.h>
#import <XZKit/XZMocoaGroupViewModel.h>

#import <XZKit/XZMocoaGroupReusableViewModel.h>
#import <XZKit/XZMocoaGroupReusableView.h>

// XZMocoaTableView
#import <XZKit/XZMocoaTableModel.h>
#import <XZKit/XZMocoaTableView.h>
#import <XZKit/XZMocoaTableViewController.h>
#import <XZKit/XZMocoaTableViewModel.h>

#import <XZKit/XZMocoaTableCell.h>
#import <XZKit/XZMocoaTableCellViewModel.h>

#import <XZKit/XZMocoaTableHeaderFooterView.h>
#import <XZKit/XZMocoaTableHeaderFooterViewModel.h>

// XZMocoaCollectionView
#import <XZKit/XZMocoaCollectionModel.h>
#import <XZKit/XZMocoaCollectionView.h>
#import <XZKit/XZMocoaCollectionViewController.h>
#import <XZKit/XZMocoaCollectionViewModel.h>

#import <XZKit/XZMocoaCollectionCell.h>
#import <XZKit/XZMocoaCollectionCellViewModel.h>

#import <XZKit/XZMocoaCollectionSupplementView.h>
#import <XZKit/XZMocoaCollectionSupplementViewModel.h>
#endif





