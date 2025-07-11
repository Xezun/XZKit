//
//  Example0312ViewController.m
//  Example
//
//  Created by Xezun on 2023/8/21.
//

#import "Example0312ViewController.h"
@import XZKit;

@interface Example0312ViewController ()

@end

@implementation Example0312ViewController

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/12/").viewClass = self;
}

- (instancetype)didInitWithMocoaOptions:(XZMocoaOptions *)options {
    self.title = @"Example 11";
    self.hidesBottomBarWhenPushed = YES;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *data = @[
        @{ @"firstName": @"张", @"lastName": @"三", @"phone": @"138-8888-1111" },
        @{ @"firstName": @"李", @"lastName": @"四", @"phone": @"138-8888-2222" },
        @{ @"firstName": @"王", @"lastName": @"五", @"phone": @"138-8888-3333" }
    ];
    
    // 在这个示例中，我们将 tableView 视为一个 mvvm 视图模块，这与示例 10 中，将 ContactView 作为一个视图模块是一样的。
    // 但是由于 tableView 是一个管理了 cell 子模块的超级模块，而且这里我们直接使用的是基类，而不是自定义的视图，
    // 即它是一个普通视图模块，不属于任何模块，所以我们需要通过 URL 获取这个模块的 XZMocoaModule 对象，即下面的 module 对象，
    // 然后将这个一般模块，设置为 module 模块。
    
    XZMocoaModule *module = XZMocoa(@"https://mocoa.xezun.com/examples/12/table/");
    
    // Model
    NSArray *dataArray = [data xz_map:^id _Nonnull(id  _Nonnull obj, NSInteger idx, BOOL * _Nonnull stop) {
        return [XZJSON decode:obj options:0 class:module.section.cell.modelClass];
    }];
    
    // viewModel
    XZMocoaTableViewModel *tableViewModel = [[XZMocoaTableViewModel alloc] initWithModel:dataArray];
    tableViewModel.module = module;
    [tableViewModel ready];
    
    // view
    XZMocoaTableView *tableView = [[XZMocoaTableView alloc] initWithFrame:self.view.bounds style:(UITableViewStyleGrouped)];
    tableView.contentView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.viewModel = tableViewModel;
    [self.view addSubview:tableView];
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
