//
//  XZToast.h
//  XZToast
//
//  Created by 徐臻 on 2025/3/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, XZToastType) {
    XZToastTypeMessage,
    XZToastTypeLoading,
} NS_REFINED_FOR_SWIFT;

@class XZToast;

typedef XZToast * _Nonnull (*XZTextToast)(NSString * _Nonnull message);

NS_REFINED_FOR_SWIFT @interface XZToast : NSObject

@property (nonatomic, readonly) XZToastType type;
@property (nonatomic, readonly) NSString *text;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithType:(XZToastType)type text:(NSString *)text NS_DESIGNATED_INITIALIZER;

@property (class, readonly) XZTextToast message;
@property (class, readonly) XZTextToast loading;

@end

NS_ASSUME_NONNULL_END
