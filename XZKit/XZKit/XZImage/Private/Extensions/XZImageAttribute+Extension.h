//
//  XZImageAttribute+Extension.h
//  XZKit
//
//  Created by Xezun on 2021/2/21.
//

#import <XZKit/XZKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 作为上级属性需遵循的协议。
@protocol XZImageSuperAttribute <NSObject>
- (void)subAttribute:(__kindof XZImageAttribute *)subAttribute didUpdateAttribute:(nullable id)attribute;
@end

@interface XZImageAttribute () <XZImageSuperAttribute>

// 是否生效（是否使用该属性绘图），默认`NO`。
@property (nonatomic, readonly) BOOL isEffective;

/// 上级属性。
@property (nonatomic, weak, readonly) id<XZImageSuperAttribute> superAttribute;

/// 属性发生更新，默认将事件传递给上级。
- (void)didUpdateAttribute:(nullable id)attribute;

/// 初始化。
/// @param superAttribute 上级
- (instancetype)initWithSuperAttribute:(id<XZImageSuperAttribute>)superAttribute NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
