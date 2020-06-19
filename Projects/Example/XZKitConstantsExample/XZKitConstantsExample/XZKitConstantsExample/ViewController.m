//
//  ViewController.m
//  XZKitConstantsExample
//
//  Created by Xezun on 2019/4/18.
//  Copyright © 2019 mlibai. All rights reserved.
//

#import "ViewController.h"
#import <XZKit/XZKit.h>

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    defer(^{
        XZLog(@"在作用域结束执行的代码块1。");
    });
    
    defer(^{
        XZLog(@"在作用域结束执行的代码块2。");
    });
    
    defer(^{
        XZLog(@"在作用域结束执行的代码块3。");
    });
    
    XZLog(@"业务逻辑执行的代码1。");
    XZLog(@"业务逻辑执行的代码2。");
    XZLog(@"业务逻辑执行的代码3。");
}

@end



