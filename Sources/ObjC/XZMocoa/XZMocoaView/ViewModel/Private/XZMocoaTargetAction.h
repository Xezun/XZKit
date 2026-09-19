//
//  XZMocoaTargetAction.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/8.
//

#import <Foundation/Foundation.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaViewModel.h>
#else
#import "XZMocoaViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class XZMocoaViewModel, XZMocoaAction;

@interface XZMocoaTargetAction : NSObject

@property (nonatomic, weak, readonly) id target;
@property (nonatomic, readonly) XZMocoaAction *action;

- (instancetype)init NS_UNAVAILABLE;
+ (nullable instancetype)targetActionWithTarget:(id)target action:(SEL)action;

- (void)sender:(id)sender sendActionForKey:(XZMocoaKey)key value:(id)value;

@end

@interface XZMocoaAction : NSObject

@property (nonatomic, readonly) SEL action;

+ (XZMocoaTargetAction *)actionForClass:(Class)aClass action:(SEL)action;

- (void)sender:(id const)sender sendActionForTarget:(id const)target forKey:(XZMocoaKey)key value:(id const)value;

@end

NS_ASSUME_NONNULL_END
