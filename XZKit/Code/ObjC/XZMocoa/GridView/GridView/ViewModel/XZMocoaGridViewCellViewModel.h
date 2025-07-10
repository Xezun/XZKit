//
//  XZMocoaGridViewCellViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2021/1/13.
//  Copyright © 2021 Xezun. All rights reserved.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaDefines.h>
#import <XZKit/XZMocoaViewModel.h>
#else
#import "XZMocoaDefines.h"
#import "XZMocoaViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol XZMocoaGridViewCell;

/// cell 视图模型基类。
@interface XZMocoaGridViewCellViewModel : XZMocoaViewModel

/// 重用标识符。
///
/// 通过 XZMocoaModule 注册的 cell 使用 XZMocoaReuseIdentifier() 函数构造标识符。
///
/// 通过 Storyboard 定义的 cell 虽然无法在 XZMocoaModule 中注册，
/// 但是仅需将 cell 在 Storyboard 中设置的标识符，赋值给此属性即可正常使用。
@property (nonatomic, copy, XZ_READONLY) NSString *identifier;

/// 视图的 frame 值。
///
/// 修改属性不会发送事件，以避免发送事件太频繁。
///
/// 如果视图的值受数据影响时，此职值将起作用，且不同的视图，可能其中仅部分值有效，比如在 UITableView 中，仅 height 值有效。
@property (nonatomic) CGRect frame;

@end

NS_ASSUME_NONNULL_END
