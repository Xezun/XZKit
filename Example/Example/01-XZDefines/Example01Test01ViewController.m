//
//  Example01Test01ViewController.m
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import "Example01Test01ViewController.h"
@import XZDefines;
@import ObjectiveC;

@interface Example01TestView : UIView
@end

@interface Example01Test01ViewController ()

@property (nonatomic, copy) void (^block)(const char *methodName);

@end

@implementation Example01Test01ViewController

- (void)dealloc {
    self.block(__PRETTY_FUNCTION__);
    NSLog(@"控制台看到此信息，表明 enweak、deweak 测试成功。");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    enweak(self)
    self.block = ^(const char *methodName) {
        deweak(self);
        NSLog(@"在方法 %s 中，捕获的变量 self 值的为：%@", methodName, self);
    };
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.block(__PRETTY_FUNCTION__);
    
    XZLog(@"测试 setFrame/setBounds 是否会互相调用");
    Example01TestView *view = [[Example01TestView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    XZLog(@"setFrame");
    view.frame = CGRectMake(0, 0, 200, 200);
    XZLog(@"setBounds");
    view.bounds = CGRectMake(0, 0, 300, 300);
    XZLog(@"view: %@", view);
}

@end

@implementation Example01TestView
- (void)setFrame:(CGRect)frame {
    XZLog(@"%@", NSStringFromCGRect(frame));
    [super setFrame:frame];
}
- (void)setBounds:(CGRect)bounds {
    XZLog(@"%@", NSStringFromCGRect(bounds));
    [super setBounds:bounds];
}
@end
