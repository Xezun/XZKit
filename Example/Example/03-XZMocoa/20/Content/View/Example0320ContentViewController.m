//
//  Example0320ContentViewController.m
//  Example
//
//  Created by Xezun on 2023/7/29.
//

#import "Example0320ContentViewController.h"
@import XZMocoa;
@import WebKit;

@interface Example0320ContentViewController ()

@property (nonatomic, copy) NSURL *url;
@property (weak, nonatomic) IBOutlet WKWebView *webView;
@end

@implementation Example0320ContentViewController

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/20/content/").viewNibClass = self;
}

- (instancetype)initWithMocoaOptions:(XZMocoaOptions *)options nibName:(NSString *)nibName bundle:(NSBundle *)bundle {
    self = [super initWithMocoaOptions:options nibName:nibName bundle:bundle];
    if (self) {
        self.title = @"WebView";
        _url = [NSURL URLWithString:options[@"url"]];
        NSLog(@"url: %@", _url);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:request];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
