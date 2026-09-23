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

@class XZMocoaViewModel, XZObjcMethod;

@interface XZMocoaTargetAction : NSObject

@property (nonatomic, weak, readonly) id target;
@property (nonatomic, readonly) XZObjcMethod *action;

- (instancetype)init NS_UNAVAILABLE;
+ (nullable instancetype)targetActionWithTarget:(id)target selector:(SEL)selector;
+ (void)viewModel:(const id)viewModel target:(const id)target sendAction:(SEL)selector forKey:(const XZMocoaKey)key value:(const id)value;
- (void)viewModel:(const id)viewModel target:(const id)target sendActionForKey:(const XZMocoaKey)key value:(const id)value;

@end

NS_ASSUME_NONNULL_END
