//
//  Example07Test03ViewController.m
//  Example
//
//  Created by 徐臻 on 2025/6/25.
//

#import "Example07Test03ViewController.h"
@import XZKit;
@import SDWebImage;

@interface Example07Test03ViewController () <XZImageViewerDataSource, XZImageViewerDelegate>

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray<UIImageView *> *imageViews;

@property (nonatomic, copy) NSArray<NSDictionary<NSString *, NSURL *> *> *imageURLs;
@property (weak, nonatomic) IBOutlet UISwitch *sourceViewSwitch;

@end

@implementation Example07Test03ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _imageURLs = @[
        @{
            @"cover": [UIImage imageNamed:@"icon_07_00"],
            @"image": [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/thumbnail/2023/8/710802_240.jpg?r=1691389332627"]
        },
        
        @{
            @"cover": [UIImage imageNamed:@"icon_07_01"],
            @"image": [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/2025/7/fefed262-fb66-4dbe-a6d7-15dad215fb5d.png"]
        },
        
        @{
            @"cover": [UIImage imageNamed:@"icon_07_02"],
            @"image": [NSURL URLWithString:@"https://b0.bdstatic.com/232753f3d58ff3295847f649e5b03fa5.jpg"],
        },
        
        @{
            @"cover": [UIImage imageNamed:@"icon_07_03"],
            @"image": [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/2025/7/934f770f-e692-4b99-b4eb-c1c4db702d34.jpg"]
        },
        
        
        @{
            @"cover": [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/thumbnail/2023/8/710853_240.jpg?r=1691398369990"],
            @"image": [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/thumbnail/2023/8/710853_240.jpg?r=1691398369990"]
        },
        @{
            @"cover": [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/thumbnail/2023/8/710802_240.jpg?r=1691389332627"],
            @"image": [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/thumbnail/2023/8/710802_240.jpg?r=1691389332627"]
        },
        
        @{
            @"cover": [UIImage imageNamed:@"icon_07_06"],
            @"image": [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/2025/7/68e8c3de-0e6c-43ae-9945-3ec4b5510586.jpg"]
        },
        @{
            @"cover": [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/thumbnail/2023/8/710748_240.jpg?r=1691376229133"],
            @"image": [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/thumbnail/2023/8/710748_240.jpg?r=1691376229133"]
        },
        @{
            @"cover": [UIImage imageNamed:@"icon_07_08"],
            @"image": [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/2025/7/2fd7a3c4-db99-4f8c-8d2f-f10a6f404d35.jpg"]
        }
    ];
    
    [self.imageViews enumerateObjectsUsingBlock:^(UIImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary * const dict = self.imageURLs[idx];
        id const cover = dict[@"cover"];
        if ([cover isKindOfClass:UIImage.class]) {
            obj.image = cover;
        } else {
            [obj sd_setImageWithURL:cover];
        }
    }];
}

- (IBAction)tapGestureRecognizerAction:(UITapGestureRecognizer *)sender {
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
    imageViewer.sourceView = self.sourceViewSwitch.isOn ? sourceView : nil;
    [self presentViewController:imageViewer animated:YES completion:nil];
}

- (IBAction)refreshStatusBarButtonAction:(UIButton *)sender {
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - XZImageViewerDataSource

- (NSInteger)numberOfItemsInImageViewer:(XZImageViewer *)imageViewer {
    return _imageViews.count;
}

- (UIImage *)imageViewer:(XZImageViewer *)imageViewer loadImageForItemAtIndex:(NSInteger)index completion:(void (^)(UIImage * _Nonnull))completion {
    switch (index) {
        case 0: {
            // 只有小图
            break;
        }
        case 1: {
            // 小图 => 大图，宽图
            [SDWebImageManager.sharedManager loadImageWithURL:_imageURLs[index][@"image"] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                completion(image);
            }];
            break;
        }
        case 2: {
            // 小图 => 大图，长图
            [SDWebImageManager.sharedManager loadImageWithURL:_imageURLs[index][@"image"] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                completion(image);
            }];
            break;
        }
        default:
            [SDWebImageManager.sharedManager loadImageWithURL:_imageURLs[index][@"image"] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                completion(image);
            }];
            break;
    }
    return _imageViews[index].image;
}

#pragma mark - XZImageViewerDelegate

- (void)imageViewer:(XZImageViewer *)imageViewer didShowImageAtIndex:(NSInteger)index {
    imageViewer.sourceView = self.sourceViewSwitch.isOn ? self.imageViews[index] : nil;
}


@end
