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
@property (nonatomic, weak) id<XZImageAttribute> superAttribute;
- (void)didUpdateAttribute:(nullable id)attribute;
@end

NS_ASSUME_NONNULL_END
