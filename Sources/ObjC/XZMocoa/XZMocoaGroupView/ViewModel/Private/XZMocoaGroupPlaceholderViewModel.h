//
//  XZMocoaGroupPlaceholderViewModel.h
//  XZKit
//
//  Created by Xezun on 2025/1/20.
//

#import "XZMocoaViewModel.h"

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@class XZMocoaGroupReusableViewModel;
@interface XZMocoaGroupPlaceholderViewModel : XZMocoaViewModel
@property (nonatomic, copy) NSString *kind;
@property (nonatomic, copy) NSString *moduleURLString;
@property (nonatomic, copy) NSString *detail;
- (instancetype)initWithModel:(nullable XZMocoaViewModel *)model;
@end
#endif

NS_ASSUME_NONNULL_END
