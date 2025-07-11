//
//  XZMocoaGridViewPlaceholderView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/28.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaView.h>
#import <XZKit/XZMocoaGridViewPlaceholderViewModel.h>
#else
#import "XZMocoaView.h"
#import "XZMocoaGridViewPlaceholderViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaGridViewPlaceholderView : UIView <XZMocoaView>
@end
#endif

NS_ASSUME_NONNULL_END
