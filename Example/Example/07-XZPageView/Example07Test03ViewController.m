//
//  Example07Test03ViewController.m
//  Example
//
//  Created by 徐臻 on 2025/6/25.
//

#import "Example07Test03ViewController.h"
@import XZPageView;
@import SDWebImage;

@interface Example07Test03ViewController () <XZImageViewerDataSource, XZImageViewerDelegate>

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray<UIImageView *> *imageViews;

@property (nonatomic, copy) NSArray<NSDictionary<NSString *, NSURL *> *> *imageURLs;

@end

@implementation Example07Test03ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _imageURLs = @[
        @{
            @"cover": [NSURL URLWithString:@"https://img2.baidu.com/it/u=822205830,2647734930&fm=253&fmt=auto&app=138&f=JPEG?w=750&h=500"],
            @"image": [NSURL URLWithString:@"https://q7.itc.cn/q_70/images03/20250112/fc5705a8d8894a67a9fd579502e7024d.jpeg"]
        },
        @{
            @"cover": [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/thumbnail/2023/8/710853_240.jpg?r=1691398369990"],
            @"image": [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/thumbnail/2023/8/710853_240.jpg?r=1691398369990"]
        },
        @{
            @"cover": [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/thumbnail/2023/8/710845_240.jpg?r=1691400153800"],
            @"image": [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/thumbnail/2023/8/710845_240.jpg?r=1691400153800"]
        },
        
        @{
            @"cover": [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/thumbnail/2023/8/710826_240.jpg?r=1691393973783"],
            @"image": [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/thumbnail/2023/8/710826_240.jpg?r=1691393973783"]
        },
        @{
            @"cover": [NSURL URLWithString:@"https://img0.baidu.com/it/u=1327435806,2633434759&fm=253&fmt=auto&app=120&f=JPEG?w=667&h=500"],
            @"image": [NSURL URLWithString:@"https://i0.hdslb.com/bfs/archive/f04cdf2dacd16a5c72fc4b8575480c5309d84247.jpg"]
        },
        @{
            @"cover": [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/thumbnail/2023/8/710802_240.jpg?r=1691389332627"],
            @"image": [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/thumbnail/2023/8/710802_240.jpg?r=1691389332627"]
        },
        
        @{
            @"cover": [NSURL URLWithString:@"https://img0.baidu.com/it/u=1921545104,2825374292&fm=253&fmt=auto&app=120&f=JPEG?w=500&h=889"],
            @"image": [NSURL URLWithString:@"https://pic.rmb.bdstatic.com/bjh/bb9195431ff5/250530/f0c0d02853bcc6ae34a2d84ae22f3621.jpeg"]
        },
        @{
            @"cover": [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/thumbnail/2023/8/710748_240.jpg?r=1691376229133"],
            @"image": [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/thumbnail/2023/8/710748_240.jpg?r=1691376229133"]
        },
        @{
            @"cover": [NSURL URLWithString:@"https://img1.baidu.com/it/u=3654298861,3467786631&fm=253&fmt=auto&app=120&f=JPEG?w=889&h=500"],
            @"image": [NSURL URLWithString:@"https://i0.hdslb.com/bfs/archive/71dbafaf58269f890560de7a1cb773b6477281be.jpg"]
        }
    ];
    
    [self.imageViews enumerateObjectsUsingBlock:^(UIImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj sd_setImageWithURL:self.imageURLs[idx][@"cover"]];
    }];
}

- (IBAction)tapAction:(UITapGestureRecognizer *)sender {
    UIImageView *sourceView = nil;
    
    UIView * const view  = sender.view;
    CGPoint  const point = [sender locationInView:sender.view];
    for (UIImageView *imageView in self.imageViews) {
        if (CGRectContainsPoint([imageView convertRect:imageView.bounds toView:view], point)) {
            sourceView = imageView;
            break;
        }
    }
    
    if (sourceView == nil) {
        return;
    }
    
    XZImageViewer *imageViewer = [[XZImageViewer alloc] init];
    [imageViewer setMinimumZoomScale:0.1 maximumZoomScale:10.0];
    imageViewer.delegate = self;
    imageViewer.dataSource = self;
    imageViewer.currentIndex = [self.imageViews indexOfObject:sourceView];
    imageViewer.sourceView = sourceView;
    [self presentViewController:imageViewer animated:YES completion:nil];
}

#pragma mark - XZImageViewerDataSource

- (NSInteger)numberOfItemsInImageViewer:(XZImageViewer *)imageViewer {
    return _imageViews.count;
}

- (UIImage *)imageViewer:(XZImageViewer *)imageViewer loadImageForItemAtIndex:(NSInteger)index completion:(void (^)(UIImage * _Nonnull))completion {
    [SDWebImageManager.sharedManager loadImageWithURL:_imageURLs[index][@"image"] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        completion(image);
    }];
    return _imageViews[index].image;
}

#pragma mark - XZImageViewerDelegate

- (void)imageViewer:(XZImageViewer *)imageViewer didShowImageAtIndex:(NSInteger)index {
    imageViewer.sourceView = self.imageViews[index];
}


@end
