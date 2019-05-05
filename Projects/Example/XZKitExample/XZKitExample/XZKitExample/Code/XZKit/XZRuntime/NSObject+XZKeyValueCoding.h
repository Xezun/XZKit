//
//  NSObject+XZKeyValueCoding.h
//  XZKit
//
//  Created by mlibai on 2016/12/5.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (XZKeyValueCoding)

- (void)xz_setValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues;
- (void)xz_setValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues keyMap:(NSDictionary<NSString *, NSString *> *)keyMap;

@end


@interface NSDictionary (XZKeyValueCoding)

@end

NS_ASSUME_NONNULL_END
