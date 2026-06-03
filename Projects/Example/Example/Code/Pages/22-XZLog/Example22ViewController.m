//
//  Example22ViewController.m
//  Example
//
//  Created by Xezun on 2026/5/1.
//

#import "Example22ViewController.h"
@import XZKit;

@interface Example22ViewController ()

@end

@implementation Example22ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



- (void)exampleXZLog {
    NSString *string = nil;
    
    string = [@"" stringByPaddingToLength:500 withString:@"1234567890" startingAtIndex:0];
    XZLog(@"单行字符数：%lu", string.length);
    XZLog(@"%@", string);
    
    string = [@"" stringByPaddingToLength:999 withString:@"1234567890" startingAtIndex:0];
    XZLog(@"单行字符数：%lu", string.length);
    XZLog(@"%@", string);
    
    string = [@"" stringByPaddingToLength:1000 withString:@"1234567890" startingAtIndex:0];
    XZLog(@"单行字符数：%lu", string.length);
    XZLog(@"%@", string);
    
    string = [@"" stringByPaddingToLength:1001 withString:@"1234567890" startingAtIndex:0];
    XZLog(@"单行字符数：%lu", string.length);
    XZLog(@"%@", string);
    
    string = [@"" stringByPaddingToLength:1016 withString:@"1234567890" startingAtIndex:0];
    XZLog(@"单行字符数：%lu", string.length);
    XZLog(@"%@", string);
    
    string = [@"" stringByPaddingToLength:1017 withString:@"1234567890" startingAtIndex:0];
    XZLog(@"单行字符数：%lu", string.length);
    XZLog(@"%@", string);
    
    string = [@"" stringByPaddingToLength:1018 withString:@"1234567890" startingAtIndex:0];
    XZLog(@"单行字符数：%lu", string.length);
    XZLog(@"%@", string);
    
    string = [NSString stringWithFormat:@"%@\n%@",
              [@"" stringByPaddingToLength:998 withString:@"1234567890" startingAtIndex:0],
              [@"" stringByPaddingToLength:1000 withString:@"1234567890" startingAtIndex:0]
    ];
    XZLog(@"多行字符数：%lu", string.length);
    XZLog(@"%@", string);
    
    string = [NSString stringWithFormat:@"%@\n%@",
              [@"" stringByPaddingToLength:999 withString:@"1234567890" startingAtIndex:0],
              [@"" stringByPaddingToLength:1000 withString:@"1234567890" startingAtIndex:0]
    ];
    XZLog(@"多行字符数：%lu", string.length);
    XZLog(@"%@", string);
    
    string = [NSString stringWithFormat:@"%@\n%@",
              [@"" stringByPaddingToLength:1000 withString:@"1234567890" startingAtIndex:0],
              [@"" stringByPaddingToLength:1000 withString:@"1234567890" startingAtIndex:0]
    ];
    XZLog(@"多行字符数：%lu", string.length);
    XZLog(@"%@", string);
    
    string = [NSString stringWithFormat:@"%@\n%@",
              [@"" stringByPaddingToLength:1001 withString:@"1234567890" startingAtIndex:0],
              [@"" stringByPaddingToLength:1000 withString:@"1234567890" startingAtIndex:0]
    ];
    XZLog(@"多行字符数：%lu", string.length);
    XZLog(@"%@", string);
    
    string = [NSString stringWithFormat:@"%@\n%@",
              [@"" stringByPaddingToLength:1002 withString:@"1234567890" startingAtIndex:0],
              [@"" stringByPaddingToLength:1000 withString:@"1234567890" startingAtIndex:0]
    ];
    XZLog(@"多行字符数：%lu", string.length);
    XZLog(@"%@", string);
}

@end
