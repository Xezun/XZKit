//
//  XZMocoaTableSectionModel.h
//  Pods
//
//  Created by Xezun on 2023/7/23.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGridSectionModel.h>
#else
#import "XZMocoaGridSectionModel.h"
#endif

/// UITableView 的 section 层（抽象层）的数据模型。
@protocol XZMocoaTableSectionModel <XZMocoaGridSectionModel>
@end

