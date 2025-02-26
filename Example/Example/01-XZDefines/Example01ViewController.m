//
//  Example01ViewController.m
//  Example
//
//  Created by 徐臻 on 2025/2/26.
//

#import "Example01ViewController.h"
@import XZDefines;

@interface Example01ViewController ()

@end

@implementation Example01ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [super tableView:tableView didSelectRowAtIndexPath:indexPath];
            break;
        case 1: {
            NSString *string1 = [@"" stringByPaddingToLength:500 withString:@"0123456789" startingAtIndex:0];
            XZLog(@"单行字符数：%lu", string1.length);
            XZLog(@"%@", string1);
            
            NSString *string2 = [@"" stringByPaddingToLength:999 withString:@"0123456789" startingAtIndex:0];
            XZLog(@"单行字符数：%lu", string2.length);
            XZLog(@"%@", string2);
            
            NSString *string3 = [@"" stringByPaddingToLength:1000 withString:@"0123456789" startingAtIndex:0];
            XZLog(@"单行字符数：%lu", string3.length);
            XZLog(@"%@", string3);
            
            NSString *string4 = [@"" stringByPaddingToLength:3000 withString:@"0123456789" startingAtIndex:0];
            XZLog(@"单行字符数：%lu", string4.length);
            XZLog(@"%@", string4);
            
            NSString *string5 = [NSString stringWithFormat:@"%@\n%@\n%@\n%@", string1, string2, string3, string4];
            XZLog(@"多行字符数：%lu", string5.length);
            XZLog(@"%@", string5);
            break;
        }
        case 2: {
            break;
        }
        default:
            break;
    }
}

@end
