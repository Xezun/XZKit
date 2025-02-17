//
//  XZRefreshStyle2View.h
//  XZRefresh
//
//  Created by Xezun on 2019/10/12.
//  Copyright © 2019 Xezun. All rights reserved.
//

#import "XZRefreshView.h"

NS_ASSUME_NONNULL_BEGIN

/// 省略号形式的刷新动画。
@interface XZRefreshStyle2View : XZRefreshView
/// 刷新动画圆点的颜色过渡，必须包含三个值。
@property (nonatomic, copy) NSArray<UIColor *> *colors;
@end

NS_ASSUME_NONNULL_END
