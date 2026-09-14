//
//  XZMocoaTargetActionTable.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/8.
//

#import <Foundation/Foundation.h>
#if __has_include("XZKit.h")
#import "XZMocoaTargetAction.h"
#else
#import <XZKit/XZMocoaTargetAction.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class XZMocoaViewModel;

@interface XZMocoaTargetActionTable : NSObject

@property (nonatomic, unsafe_unretained, readonly) XZMocoaViewModel *viewModel;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithViewModel:(XZMocoaViewModel *)viewModel;
- (void)addTarget:(id)target action:(SEL)action forKey:(NSString *)key;
- (void)removeTarget:(nullable id)target action:(nullable SEL)action forKey:(nullable NSString *)key;
- (void)sendActionsForKey:(NSString *)key value:(nullable)value;

@end

NS_ASSUME_NONNULL_END
