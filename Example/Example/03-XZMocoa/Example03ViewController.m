//
//  Example03ViewController.m
//  Example
//
//  Created by Xezun on 2023/7/23.
//

#import "Example03ViewController.h"
@import XZMocoaCore;
@import ObjectiveC;
@import XZML;

@interface Example03ViewController ()

@property (nonatomic, copy) NSArray<NSArray<NSDictionary *> *> *dataArray;

@end

@implementation Example03ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataArray = @[
        @[
            @{
                @"title": @"10. 普通模块",
                @"url": [NSURL URLWithString:@"https://mocoa.xezun.com/examples/10/"]
            }, @{
                @"title": @"11. 控制器模块",
                @"url": [NSURL URLWithString:@"https://mocoa.xezun.com/examples/11/"]
            }, @{
                @"title": @"12. 简单列表",
                @"url": [NSURL URLWithString:@"https://mocoa.xezun.com/examples/12/"]
            }
        ], @[
            @{
                @"title": @"20. UITableView 展示",
                @"url": [NSURL URLWithString:@"https://mocoa.xezun.com/examples/20/"],
            }, @{
                @"title": @"21. UITableView 差异分析与局部刷新",
                @"url": [NSURL URLWithString:@"https://mocoa.xezun.com/examples/21/"],
                
            }, @{
                @"title": @"22. UICollectionView 差异分析与局部刷新",
                @"url": [NSURL URLWithString:@"https://mocoa.xezun.com/examples/22/"]
            }
        ], @[
            @{
                @"title": @"30. UITableView 防崩溃测试",
                @"url": [NSURL URLWithString:@"https://mocoa.xezun.com/examples/30/"],
            }, @{
                @"title": @"31. UICollectionView 防崩溃测试",
                @"url": [NSURL URLWithString:@"https://mocoa.xezun.com/examples/31/"],
            }
        ]
    ];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = _dataArray[indexPath.section][indexPath.row][@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSURL *url = _dataArray[indexPath.section][indexPath.row][@"url"];
    [self.navigationController pushMocoaURL:url animated:YES];
}

@end
