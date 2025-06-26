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

@property (nonatomic, copy) NSArray<NSURL *> *imageURLs;

@end

@implementation Example07Test03ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _imageURLs = @[
        [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/thumbnail/2023/8/710869_240.jpg?r=1691399630700"],
        [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/thumbnail/2023/8/710853_240.jpg?r=1691398369990"],
        [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/thumbnail/2023/8/710845_240.jpg?r=1691400153800"],
        [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/thumbnail/2023/8/710826_240.jpg?r=1691393973783"],
        [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/thumbnail/2023/8/710817_240.jpg?r=1691391503670"],
        [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/thumbnail/2023/8/710802_240.jpg?r=1691389332627"],
        [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/thumbnail/2023/8/710778_240.jpg?r=1691380407190"],
        [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/thumbnail/2023/8/710748_240.jpg?r=1691376229133"],
        [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/thumbnail/2023/8/710715_240.jpg?r=1691336123867"],
    ];
    
    [self.imageViews enumerateObjectsUsingBlock:^(UIImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj sd_setImageWithURL:self.imageURLs[idx]];
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
    imageViewer.delegate = self;
    imageViewer.dataSource = self;
    imageViewer.sourceView = sourceView;
    imageViewer.currentIndex = [self.imageViews indexOfObject:sourceView];
    [self presentViewController:imageViewer animated:YES completion:nil];
}

#pragma mark - XZImageViewerDataSource

- (NSInteger)numberOfItemsInImageViewer:(XZImageViewer *)imageViewer {
    return _imageViews.count;
}

- (UIImage *)imageViewer:(XZImageViewer *)imageViewer loadImageForItemAtIndex:(NSInteger)index completion:(void (^)(UIImage * _Nonnull))completion {
    [SDWebImageManager.sharedManager loadImageWithURL:_imageURLs[index] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        completion(image);
    }];
    return _imageViews[index].image;
}

#pragma mark - XZImageViewerDelegate

- (void)imageViewer:(XZImageViewer *)imageViewer didShowImageAtIndex:(NSInteger)index {
    imageViewer.sourceView = self.imageViews[index];
}


@end
