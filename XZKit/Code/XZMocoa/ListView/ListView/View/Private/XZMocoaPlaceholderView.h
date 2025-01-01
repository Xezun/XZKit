//
//  XZMocoaPlaceholderView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/28.
//

#import <UIKit/UIKit.h>
#import "XZMocoaView.h"
#import "XZMocoaViewModel.h"

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaPlaceholderViewModel : XZMocoaViewModel
@property (nonatomic, copy) NSString *reason;
@property (nonatomic, copy) NSString *detail;
@end

@interface XZMocoaPlaceholderView : UIView <XZMocoaView>
@end
#endif

NS_ASSUME_NONNULL_END
