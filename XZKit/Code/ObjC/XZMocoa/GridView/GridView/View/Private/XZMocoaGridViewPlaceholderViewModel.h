//
//  XZMocoaGridViewPlaceholderViewModel.h
//  XZKit
//
//  Created by 徐臻 on 2025/1/20.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaViewModel.h>
#else
#import "XZMocoaViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@class XZMocoaGridViewCellViewModel;
@interface XZMocoaGridViewPlaceholderViewModel : XZMocoaViewModel
@property (nonatomic, copy) NSString *reason;
@property (nonatomic, copy) NSString *detail;
- (instancetype)initWithModel:(nullable XZMocoaViewModel *)model;
@end
#endif

NS_ASSUME_NONNULL_END
