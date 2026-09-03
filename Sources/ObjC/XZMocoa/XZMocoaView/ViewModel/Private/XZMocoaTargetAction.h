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

@interface XZMocoaTargetAction : NSObject

@property (nonatomic, weak, readonly) id target;
@property (nonatomic, readonly, nullable) SEL action;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithTarget:(id)target action:(SEL)action NS_DESIGNATED_INITIALIZER;

- (void)sender:(id)sender sendActionForKey:(XZMocoaKey)key value:(id)value;

@end

NS_ASSUME_NONNULL_END
