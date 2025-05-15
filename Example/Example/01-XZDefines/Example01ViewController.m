//
//  Example01ViewController.m
//  Example
//
//  Created by 徐臻 on 2025/2/26.
//

#import "Example01ViewController.h"
@import XZDefines;
@import XZToast;

@interface Example01ViewController ()

@end

@implementation Example01ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self keyValueCodingTest];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            break;
        case 1: {
            [self xz_showToast:[XZToast messageToast:@"请查看控制台输出情况"]];
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
            break;
        }
        case 2: {
            break;
        }
        default:
            break;
    }
}

- (void)keyValueCodingTest {
    XZLog(@"测试 Key Value Coding 的相关规则");
    
    NSDictionary *obj = @{
        @"items": @[
            @{ @"user": @{ @"id": @"2" } },
            @{ @"user": @{ @"id": @"3" } },
            @{ @"user": @{ @"id": @"4" } }
        ],
        @"nums": @[
            @(5), @(1), @(2), @(3), @(4)
        ]
    };
    
    NSString *key = @"items.user";
    XZLog(@"%@ = %@", key, [obj valueForKeyPath:key]);
    
    key = @"items.user.id";
    XZLog(@"%@ = %@", key, [obj valueForKeyPath:key]);
    
    key = @"nums.@avg.self";
    XZLog(@"%@ = %@", key, [obj valueForKeyPath:key]);
    
    key = @"nums.@min.self";
    XZLog(@"%@ = %@", key, [obj valueForKeyPath:key]);
    
    key = @"nums.@sum.self";
    XZLog(@"%@ = %@", key, [obj valueForKeyPath:key]);
    
    key = @"@count";
    XZLog(@"%@ = %@", key, [obj valueForKeyPath:key]);
    
    XZLog(@"%@", [[[obj valueForKeyPath:@"items"] objectAtIndex:0] valueForKeyPath:@"user.id"]);
}

- (void)xcodeMacros {
    XZLog(@"__IPHONE_OS_VERSION_MIN_REQUIRED => %d", __IPHONE_OS_VERSION_MIN_REQUIRED);
}

@end
