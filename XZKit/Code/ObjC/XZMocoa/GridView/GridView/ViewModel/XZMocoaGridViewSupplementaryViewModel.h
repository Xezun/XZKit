//
//  XZMocoaGridViewSupplementaryViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaViewModel.h>
#else
#import "XZMocoaViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaGridViewSupplementaryViewModel : XZMocoaViewModel
/// 重用标识符。
@property (nonatomic, copy, XZ_READONLY) NSString *identifier;
@property (nonatomic) CGRect frame;
@end

NS_ASSUME_NONNULL_END
