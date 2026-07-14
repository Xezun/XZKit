//
//  Example14ViewController.m
//  Example
//
//  Created by Xezun on 2025/1/6.
//

#import "Example14ViewController.h"
#import "ExampleMainHomeHeaderView.h"
@import XZKit;

typedef NSString * Example14Key;

static Example14Key kName  = @"name";
static Example14Key kValue = @"value";

@interface Example14ViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation Example14ViewController {
    NSArray<NSArray<NSString *> *> *_dataArray;
    NSArray<NSString *> *_titles;
    XZURL *_url;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[ExampleMainHomeHeaderView class] forHeaderFooterViewReuseIdentifier:@"header"];
    
    _url = [XZURL URLWithURLString:@"https://xezun.com/path?key=value#fragment"];
    _titles = @[@"URL 部件", @"URL 参数", @"URL 预览", @"URL 处理"];
    
    NSArray *components = @[ @"scheme", @"host", @"path", @"fragment" ];
    NSArray *fieldnames = _url.allQueryFields.allKeys;
    NSArray *preview = @[ _url.URL.absoluteString ];
    NSArray *actions = @[ @"增加参数" ];
    _dataArray = @[components, fieldnames, preview, actions];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSString *text = _dataArray[indexPath.section][indexPath.row];
    
    switch (indexPath.section) {
        case 0: {
            cell.textLabel.text = text;
            cell.detailTextLabel.text = [_url valueForKey:text];
            return cell;
            break;
        }
        case 1: {
            cell.textLabel.text = text;
            
            id value = [_url valueForQueryField:text];
            if ([value isKindOfClass:NSString.class]) {
                cell.detailTextLabel.text = value;
            } else if ([value isKindOfClass:NSArray.class]) {
                value = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingFragmentsAllowed error:nil];
                cell.detailTextLabel.text = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
            } else {
                value = @"nil";
            }
            break;
        }
        case 2: {
            cell.textLabel.text = text;
            break;
        }
        case 3: {
            cell.textLabel.text = text;
            break;
        }
        default: {
            @throw [NSException exceptionWithName:NSGenericException reason:@"未实现" userInfo:@{}];
            break;
        }
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ExampleMainHomeHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    
    headerView.titleLabel.text = _titles[section];
    
    return headerView;
}

@end




