//
//  XZMocoaListViewCellViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2021/1/13.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import "XZMocoaDefines.h"
#import "XZMocoaViewModel.h"

NS_ASSUME_NONNULL_BEGIN

/// cell 视图模型基类。
@interface XZMocoaListViewCellViewModel : XZMocoaViewModel
/// 重用标识符。
@property (nonatomic, copy, XZ_READONLY) NSString *identifier;
/// 修改属性不会发送事件，以避免发送事件太频繁。
@property (nonatomic) CGRect frame;
@end

NS_ASSUME_NONNULL_END
