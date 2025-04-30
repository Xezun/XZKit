//
//  XZToast.m
//  XZToast
//
//  Created by 徐臻 on 2025/3/2.
//

#import "XZToast.h"

@implementation XZToast

- (instancetype)initWithContentView:(UIView *)contentView {
    self = [super init];
    if (self) {
        _contentView = contentView;
    }
    return self;
}

//- (instancetype)initWithType:(XZToastType)type text:(NSString *)text image:(UIImage *)image view:(UIView *)view isExclusive:(BOOL)isExclusive {
//    self = [super init];
//    if (self) {
//        _type = type;
//        _text = text.copy;
//        _image = image;
//        _view = view;
//        _isExclusive = isExclusive;
//    }
//    return self;
//}
//
//+ (XZToast *)messageToast:(NSString *)text {
//    return [[self alloc] initWithType:(XZToastTypeMessage) text:text image:nil view:nil isExclusive:NO];
//}
//
//+ (XZToast *)loadingToast:(NSString *)text {
//    return [[self alloc] initWithType:(XZToastTypeLoading) text:text image:nil view:nil isExclusive:NO];
//}

//+ (XZToast *)messageToast:(NSString *)text {
//    return [[self alloc] initWithContentView:[UIView new]];
//}
//
//+ (XZToast *)loadingToast:(NSString *)text {
//    return [[self alloc] initWithContentView:[UIView new]];
//}

@end



