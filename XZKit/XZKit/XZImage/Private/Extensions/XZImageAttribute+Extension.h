//
//  XZImageAttribute+Extension.h
//  XZKit
//
//  Created by Xezun on 2021/2/21.
//

#import <XZKit/XZKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XZImageAttribute <NSObject>
- (void)subAttribute:(__kindof XZImageAttribute *)subAttribute didUpdateAttribute:(nullable id)attribute;
@end

@interface XZImageAttribute () <XZImageAttribute>
// NO
@property (nonatomic, readonly) BOOL isEffective;

@property (nonatomic, weak, readonly) id<XZImageAttribute> superAttribute;
- (void)didUpdateAttribute:(nullable id)attribute;
- (instancetype)initWithSuperAttribute:(id<XZImageAttribute>)superAttribute NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
