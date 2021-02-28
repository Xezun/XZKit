//
//  XZAnimatedImage.m
//  XZAnimatedImage
//
//  Created by Xezun on 2019/09/09.
//  Copyright © 2019 Xezun. All rights reserved.
//

#import "XZAnimatedImage.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <objc/runtime.h>

// 最大公约数。
static inline NSInteger GCD(NSInteger a, NSInteger b) {
    return a == 0 ? b : (GCD(b % a, a));
};

typedef struct {
    UIImage * __unsafe_unretained image;
    NSInteger delay;
} _XZAnimatedImageFrameInfo;

@implementation XZAnimatedImage

- (instancetype)initWithImages:(NSArray<UIImage *> *)images duration:(NSTimeInterval)duration repeatCount:(NSInteger)repeatCount {
    self = [super init];
    if (self) {
        _images = images.copy;
        _duration = duration;
        _repeatCount = repeatCount;
    }
    return self;
}

+ (XZAnimatedImage *)animatedImageNamed:(NSString *)name {
    return [XZAnimatedImage animatedImageNamed:name ofType:nil inBundle:nil];
}

+ (XZAnimatedImage *)animatedImageNamed:(NSString *)name ofType:(NSString *)extension {
    return [XZAnimatedImage animatedImageNamed:name ofType:extension inBundle:nil];
}

+ (XZAnimatedImage *)animatedImageNamed:(NSString *)name inBundle:(NSBundle *)bundle {
    return [XZAnimatedImage animatedImageNamed:name ofType:nil inBundle:bundle];
}

+ (XZAnimatedImage *)animatedImageNamed:(NSString *)name ofType:(nullable NSString *)extension inBundle:(nullable NSBundle *)bundle {
    NSString *filePath = [(bundle ?: NSBundle.mainBundle) pathForResource:name ofType:extension];
    if (filePath == nil) {
        return nil;
    }
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    return [XZAnimatedImage animatedImageWithData:data];
}



+ (XZAnimatedImage *)animatedImageWithData:(NSData *)data {
    if (data == nil) {
        return nil;
    }
    CGImageSourceRef const imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, (__bridge CFDictionaryRef)@{(NSString *)kCGImageSourceShouldCache: @(NO)});
    if (imageSource == nil) {
        return nil;
    }
    if (!UTTypeConformsTo(CGImageSourceGetType(imageSource), kUTTypeGIF)) {
        CFRelease(imageSource);
        return nil;
    }
    
    NSDictionary *imageProperties = (__bridge_transfer NSDictionary *)CGImageSourceCopyProperties(imageSource, NULL);
    
    NSInteger const repeatCount = (^(NSDictionary *imageProperties){
        NSNumber *value = [[imageProperties objectForKey:(id)kCGImagePropertyGIFDictionary] objectForKey:(id)kCGImagePropertyGIFLoopCount];
        return (value == nil ? 1 : value.integerValue);
    })(imageProperties);
    
    NSInteger const imageCount = CGImageSourceGetCount(imageSource);
    
    _XZAnimatedImageFrameInfo * const frameInfos = calloc(imageCount, sizeof(_XZAnimatedImageFrameInfo));
    
    // 浏览器（Chrome/Firefox）默认 GIF 帧率为 25帧/秒，即一帧 40 毫秒。
    NSInteger const kMinFrameInterval = 40;
    // 最大公约数：所有帧的时长的公约数，以优化总帧数。
    NSInteger divisor = kMinFrameInterval;
    
    NSTimeInterval duration = 0; // GIF 时长。
    for (NSInteger i = 0; i < imageCount; i++) {
        @autoreleasepool {
            CGImageRef frameImageRef = CGImageSourceCreateImageAtIndex(imageSource, i, NULL);
            if (frameImageRef == nil) {
                continue;
            }
            
            UIImage *frameImage = [UIImage imageWithCGImage:frameImageRef];
            CFRelease(frameImageRef);
            if (frameImage == nil) {
                continue;
            }
            
            NSDictionary *frameProperties = (__bridge_transfer NSDictionary *)CGImageSourceCopyPropertiesAtIndex(imageSource, i, NULL);
            NSDictionary *framePropertiesGIF = [frameProperties objectForKey:(id)kCGImagePropertyGIFDictionary];
            
            NSInteger const frameDelay = (^NSInteger (NSDictionary *framePropertiesGIF) {
                NSNumber *value = [framePropertiesGIF objectForKey:(id)kCGImagePropertyGIFUnclampedDelayTime];
                if (value != nil) {
                    return MAX((NSInteger)(value.doubleValue * 1000), kMinFrameInterval);
                }
                value = [framePropertiesGIF objectForKey:(id)kCGImagePropertyGIFDelayTime];
                if (value == nil) {
                    return kMinFrameInterval;
                }
                NSInteger delay = (NSInteger)(value.doubleValue * 1000);
                return (delay > 50 ? delay : 100);
            })(framePropertiesGIF);
            
            divisor = GCD(frameDelay, divisor);
            duration += frameDelay;
            
            frameInfos[i].image = CFRetain((__bridge CFTypeRef)(frameImage));
            frameInfos[i].delay = frameDelay;
        }
    }
    CFRelease(imageSource);
    
    NSMutableArray<UIImage *> *animatedImages = [NSMutableArray arrayWithCapacity:(NSUInteger)(duration * 40)];
    for (NSInteger i = 0; i < imageCount; i++) {
        NSInteger const count = frameInfos[i].delay / divisor;
        for (NSInteger j = 0; j < count; j++) {
            [animatedImages addObject:frameInfos[i].image];
        }
        CFRelease((__bridge CFTypeRef)(frameInfos[i].image));
    }
    
    free(frameInfos);
    
    return [[XZAnimatedImage alloc] initWithImages:animatedImages duration:duration / 1000.0 repeatCount:repeatCount];
}

@end

static const void * const _image = &_image;

@implementation UIImageView (XZAnimatedImage)

- (XZAnimatedImage *)xz_image {
    return objc_getAssociatedObject(self, _image);
}

- (void)xz_setImage:(XZAnimatedImage *)xz_image {
    objc_setAssociatedObject(self, _image, xz_image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.image = xz_image.images.lastObject;
    self.animationImages = xz_image.images;
    self.animationDuration = xz_image.duration;
    self.animationRepeatCount = xz_image.repeatCount;
}

@end
