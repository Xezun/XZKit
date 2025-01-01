//
//  XZAnimatedImage.h
//  XZAnimatedImage
//
//  Created by Xezun on 2019/09/09.
//  Copyright © 2019 Xezun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZAnimatedImage : NSObject

@property (nonatomic, copy, readonly) NSArray<UIImage *> *images;
@property (nonatomic, readonly) NSInteger repeatCount;
@property (nonatomic, readonly) NSTimeInterval duration;

- (instancetype)init NS_UNAVAILABLE;

+ (nullable XZAnimatedImage *)animatedImageWithData:(nullable NSData *)data;
+ (nullable XZAnimatedImage *)animatedImageNamed:(NSString *)name;
+ (nullable XZAnimatedImage *)animatedImageNamed:(NSString *)name ofType:(nullable NSString *)extension;
+ (nullable XZAnimatedImage *)animatedImageNamed:(NSString *)name inBundle:(nullable NSBundle *)bundle;
+ (nullable XZAnimatedImage *)animatedImageNamed:(NSString *)name ofType:(nullable NSString *)extension inBundle:(nullable NSBundle *)bundle;

@end

@interface UIImageView (XZAnimatedImage)

@property (nonatomic, strong, setter=xz_setImage:) XZAnimatedImage *xz_image;

@end

NS_ASSUME_NONNULL_END
