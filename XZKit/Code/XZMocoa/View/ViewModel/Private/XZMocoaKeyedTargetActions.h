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
@property (nonatomic, unsafe_unretained, readonly) XZMocoaViewModel *sender;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithSender:(XZMocoaViewModel *)sender;
- (void)addTarget:(id)target action:(SEL)action forKey:(NSString *)key;
- (void)removeTarget:(nullable id)target action:(nullable SEL)action forKey:(nullable NSString *)key;
- (void)sendActionsForKey:(NSString *)key value:(nullable)value;
@end

NS_ASSUME_NONNULL_END
