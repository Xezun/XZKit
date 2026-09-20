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

@interface XZMocoaTarget : NSObject

@property (nonatomic, weak, readonly) id target;
@property (nonatomic, readonly) XZMocoaAction *action;

- (instancetype)init NS_UNAVAILABLE;
+ (nullable instancetype)targetActionWithTarget:(id)target selector:(SEL)selector;

@end

@interface XZMocoaAction : NSObject

@property (nonatomic, readonly) SEL selector;

+ (nullable XZMocoaAction *)actionForClass:(Class)aClass selector:(SEL)selector;

- (void)sender:(id const)sender target:(id const)target sendActionForKey:(XZMocoaKey const)key value:(id const)value;
+ (void)sender:(id const)sender target:(id const)target sendAction:(SEL)selector forKey:(XZMocoaKey const)key value:(id const)value;

@end

NS_ASSUME_NONNULL_END
