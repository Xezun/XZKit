//
//  XZMocoaKeyedTargetActions.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class XZMocoaViewModel;

@interface XZMocoaKeyedTargetActions : NSObject
@property (nonatomic, unsafe_unretained, readonly) XZMocoaViewModel *owner;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithOwner:(XZMocoaViewModel *)owner;
- (void)addTarget:(id)target action:(SEL)action forKeyEvents:(NSString *)keyEvents;
- (void)removeTarget:(nullable id)target action:(nullable SEL)action forKeyEvents:(nullable NSString *)keyEvents;
- (void)sendActionsForKeyEvents:(NSString *)keyEvents;
@end

NS_ASSUME_NONNULL_END
