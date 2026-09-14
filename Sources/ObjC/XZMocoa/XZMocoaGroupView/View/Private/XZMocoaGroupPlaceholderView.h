//
//  XZMocoaGroupPlaceholderView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/28.
//

#import <UIKit/UIKit.h>
#if __has_include("XZKit.h")
#import "XZMocoaView.h"
#import "XZMocoaGroupPlaceholderViewModel.h"
#else
#import <XZKit/XZMocoaView.h>
#import <XZKit/XZMocoaGroupPlaceholderViewModel.h>
#endif

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaGroupPlaceholderView : UIView <XZMocoaView>
@end
#endif

NS_ASSUME_NONNULL_END
