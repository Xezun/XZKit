//
//  Example14ViewController.m
//  Example
//
//  Created by Xezun on 2025/1/6.
//

#import "Example14ViewController.h"
@import XZURLQuery;
@import XZLocale;

@interface Example14ViewController ()

@end

@implementation Example14ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XZURLQuery *query = [XZURLQuery queryForURLString:@"https://xezun.com/?key1=x&key2=&key3=x&key3=&key3&key4"];
    NSLog(@"key1: %@", query[@"key1"]);
    NSLog(@"key2: %@", query[@"key2"]);
    NSLog(@"key3: %@", query[@"key3"]);
    NSLog(@"key4: %@", query[@"key4"]);
    NSLog(@"url: %p, %@", query.url, query.url);
    NSLog(@"dict: %@", query.allValues);
    
    NSLog(@"=== 修改 ===");
    query[@"name"] = @"John";
    query[@"key1"] = nil;
    query[@"key2"] = self;
    query[@"key3"] = NSNull.null;
    query[@"ages"] = @[@"12", @"14"];
    [query addValue:@"Lily" forName:@"name"];
    
    NSLog(@"key1: %@", query[@"key1"]);
    NSLog(@"key2: %@", query[@"key2"]);
    NSLog(@"key3: %@", query[@"key3"]);
    NSLog(@"key4: %@", query[@"key4"]);
    NSLog(@"name: %@", query[@"name"]);
    NSLog(@"ages: %@", query[@"ages"]);
    NSLog(@"url: %p, %@", query.url, query.url);
    NSLog(@"dict: %@", query.allValues);
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
