//
//  XZMocoaTableCellModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/27.
//

#import <Foundation/Foundation.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGridCellModel.h>
#else
#import "XZMocoaGridCellViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/// UITableView 的 cell 的数据模型。
@protocol XZMocoaTableCellModel <XZMocoaGridCellModel>
@end

NS_ASSUME_NONNULL_END
