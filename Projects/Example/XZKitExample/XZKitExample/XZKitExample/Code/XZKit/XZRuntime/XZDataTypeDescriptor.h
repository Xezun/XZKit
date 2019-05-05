//
//  XZDataTypeDescriptor.h
//  XZKit
//
//  Created by mlibai on 2016/12/1.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XZKit/XZRuntime.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZDataTypeDescriptor : NSObject

@property (nonatomic, copy, readonly) NSString *typeEncoding;

@property (nonatomic, readonly) XZDataType type;
@property (nonatomic, unsafe_unretained, readonly, nullable) Class classType;
@property (nonatomic, copy, readonly, nullable) NSArray<Protocol *> *conformedProtocols;

- (instancetype)initWithTypeEncoding:(const char *)typeEncoding;

@end


NS_ASSUME_NONNULL_END
