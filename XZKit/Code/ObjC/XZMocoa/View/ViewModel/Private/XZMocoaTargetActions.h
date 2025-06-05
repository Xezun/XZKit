//
//  XZMocoaTargetActions.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/8.
//

#import <Foundation/Foundation.h>
#import "XZMocoaTargetAction.h"

NS_ASSUME_NONNULL_BEGIN

@class XZMocoaViewModel;

@interface XZMocoaTargetActions : NSObject

@property (nonatomic, unsafe_unretained, readonly) XZMocoaViewModel *viewModel;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithViewModel:(XZMocoaViewModel *)viewModel;
- (void)addTarget:(id)target action:(SEL)action forKey:(NSString *)key;
- (void)removeTarget:(nullable id)target action:(nullable SEL)action forKey:(nullable NSString *)key;
- (void)sendActionsForKey:(NSString *)key value:(nullable)value;

- (void)addTarget:(id)target handler:(XZMocoaTargetHandler)handler forKey:(NSString *)key;

- (void)setAction:(SEL)action forModel:(id)model forKey:(nonnull NSString *)key;
- (void)sendActionForModel:(id)model forKey:(NSString *)key value:(id)value;

@end

NS_ASSUME_NONNULL_END
