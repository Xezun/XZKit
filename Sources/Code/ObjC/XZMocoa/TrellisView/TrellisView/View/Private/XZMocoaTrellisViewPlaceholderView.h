//
//  XZMocoaTrellisViewPlaceholderView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/28.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaView.h>
#import <XZKit/XZMocoaTrellisViewPlaceholderViewModel.h>
#else
#import "XZMocoaView.h"
#import "XZMocoaTrellisViewPlaceholderViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaTrellisViewPlaceholderView : UIView <XZMocoaView>
@end
#endif

NS_ASSUME_NONNULL_END
