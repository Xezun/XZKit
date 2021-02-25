//
//  UIImage+XZImage.m
//  XZKit
//
//  Created by Xezun on 2021/2/23.
//

#import "UIImage+XZImage.h"
#import "XZImageLevels.h"

@implementation UIImage (XZImage)

+ (UIImage *)xz_imageWithXZImage:(XZImage *)image {
    return image.image;
}

- (UIImage *)xz_imageByFilteringImageLevels:(XZImageLevels)levels {
    return XZImageLevelsFilteringImage(levels, self);
}

@end
