//
//  XZMocoaTargetAction.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/8.
//

#import <Foundation/Foundation.h>
#import "XZMocoaViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class XZMocoaViewModel;

typedef void (^XZMocoaTargetHandler)(id sender, id target, XZMocoaKey key, id value);

@interface XZMocoaTargetAction : NSObject

@property (nonatomic, weak, readonly) id target;
@property (nonatomic, readonly, nullable) SEL action;
@property (nonatomic, readonly, nullable) XZMocoaTargetHandler handler;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithTarget:(id)target action:(SEL)action NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithTarget:(id)target handler:(XZMocoaTargetHandler)handler NS_DESIGNATED_INITIALIZER;

- (void)sendActionWithValue:(nullable id)value forKey:(XZMocoaKey)key sender:(id)sender;
- (void)sendActionForTarget:(id)target forKey:(XZMocoaKey)key sender:(id)sender value:(nullable id)value;

@end

NS_ASSUME_NONNULL_END
