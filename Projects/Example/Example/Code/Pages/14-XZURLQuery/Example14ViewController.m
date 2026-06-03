//
//  Example14ViewController.m
//  Example
//
//  Created by Xezun on 2025/1/6.
//

#import "Example14ViewController.h"
@import XZKit;

@interface Example14ViewController ()

@end

@implementation Example14ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XZURLQuery *query = [XZURLQuery queryForURLString:@"https://xezun.com/?key1=x&key2=&key3=x&key3=&key3&key4"];
    XZLog(@"key1: %@", query[@"key1"]);
    XZLog(@"key2: %@", query[@"key2"]);
    XZLog(@"key3: %@", query[@"key3"]);
    XZLog(@"key4: %@", query[@"key4"]);
    XZLog(@"url: %p, %@", query.url, query.url);
    XZLog(@"dict: %@", query.allValues);
    
    XZLog(@"=== 修改 ===");
    query[@"name"] = @"John";
    query[@"key1"] = nil;
    query[@"key2"] = self;
    query[@"key3"] = NSNull.null;
    query[@"ages"] = @[@"12", @"14"];
    [query addValue:@"Lily" forName:@"name"];
    
    XZLog(@"key1: %@", query[@"key1"]);
    XZLog(@"key2: %@", query[@"key2"]);
    XZLog(@"key3: %@", query[@"key3"]);
    XZLog(@"key4: %@", query[@"key4"]);
    XZLog(@"name: %@", query[@"name"]);
    XZLog(@"ages: %@", query[@"ages"]);
    XZLog(@"url: %p, %@", query.url, query.url);
    XZLog(@"dict: %@", query.allValues);
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
