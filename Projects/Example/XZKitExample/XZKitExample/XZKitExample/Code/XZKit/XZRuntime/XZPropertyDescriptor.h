//
//  XZPropertyDescriptor.h
//  XZKit
//
//  Created by mlibai on 2016/11/30.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import <XZKit/XZKit.h>

NS_ASSUME_NONNULL_BEGIN

@class XZDataTypeDescriptor;

@interface XZPropertyDescriptor : NSObject

@property (nonatomic, copy, readonly, nonnull) NSString *name;
@property (nonatomic, copy, readonly, nullable) NSString *variableName;

@property (nonatomic, readonly, nonnull) XZDataTypeDescriptor *dataTypeDescriptor;

@property (nonatomic, readonly) BOOL isReadonly;
@property (nonatomic, readonly) BOOL isCopy;
@property (nonatomic, readonly) BOOL isRetain;
@property (nonatomic, readonly) BOOL isNonatomic;
@property (nonatomic, readonly) BOOL isDynamic;
@property (nonatomic, readonly) BOOL isWeak;

@property (nonatomic, readonly, unsafe_unretained, nullable) SEL getter;
@property (nonatomic, readonly, unsafe_unretained, nullable) SEL setter;

+ (instancetype)descriptorWithProperty:(objc_property_t)property_t;
- (instancetype)initWithProperty:(objc_property_t)property_t;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

@end

@interface NSObject (XZPropertyDescriptor)

@property (nonatomic, class, readonly) NSArray<XZPropertyDescriptor *> *xz_propertyDescriptors;

@end

NS_ASSUME_NONNULL_END
