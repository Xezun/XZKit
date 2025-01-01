//
//  XZMocoaTargetAction.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/8.
//

#import <Foundation/Foundation.h>
#import "XZMocoaViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaTargetAction : NSObject
@property (nonatomic, weak, readonly) id target;
@property (nonatomic, readonly) SEL action;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithTarget:(id)target action:(SEL)action;
- (void)sendActionWithObject:(id)object forKeyEvents:(XZMocoaKeyEvents)keyEvents;
@end

NS_ASSUME_NONNULL_END
