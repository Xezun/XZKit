//
//  XZJSONCoding.h
//  XZKit
//
//  Created by 徐臻 on 2026/2/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT void XZJSONModelEncodeWithCoder(id model, NSCoder *coder);
FOUNDATION_EXPORT void XZJSONModelDecodeWithCoder(id model, NSCoder *coder);

NS_ASSUME_NONNULL_END
