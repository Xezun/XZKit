//
//  ExampleHomeViewController.m
//  Example
//
//  Created by Xezun on 2024/9/10.
//

#import "ExampleHomeViewController.h"
@import XZKit;

@interface ExampleHomeViewController () {
    NSArray<NSString *> *_dataArray;
}

@property (nonatomic, readonly) XZMocoaTableView *tableView;

@end

@implementation ExampleHomeViewController

- (XZMocoaTableView *)tableView {
    return (id)self.view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *data = @[
        @[
            @{
                @"id": @"01",
                @"name": @"XZDefines"
            },
            @{
                @"id": @"02",
                @"name": @"XZExtensions"
            },
            @{
                @"id": @"21",
                @"name": @"XZObjc"
            },
        ],
        @[
            @{
                @"id": @"03",
                @"name": @"XZMocoa"
            },
            @{
                @"id": @"04",
                @"name": @"XZML"
            },
            @{
                @"id": @"05",
                @"name": @"XZJSON"
            },
            @{
                @"id": @"06",
                @"name": @"XZRefresh"
            },
            @{
                @"id": @"07",
                @"name": @"XZPageView"
            },
            @{
                @"id": @"13",
                @"name": @"XZToast"
            },
        ],
        @[
            @{
                @"id": @"08",
                @"name": @"XZPageControl"
            },
            @{
                @"id": @"09",
                @"name": @"XZSegmentedControl"
            },
            @{
                @"id": @"10",
                @"name": @"XZGeometry"
            },
            @{
                @"id": @"11",
                @"name": @"XZTextImageView"
            },
            @{
                @"id": @"12",
                @"name": @"XZContentStatus"
            },
            @{
                @"id": @"14",
                @"name": @"XZURLQuery"
            },
            @{
                @"id": @"15",
                @"name": @"XZLocale"
            },
            @{
                @"id": @"16",
                @"name": @"XZCollectionViewFlowLayout"
            },
            @{
                @"id": @"17",
                @"name": @"XZNavigationController"
            },
            @{
                @"id": @"18",
                @"name": @"XZDataDigester"
            },
            @{
                @"id": @"19",
                @"name": @"XZDataCryptor"
            },
            @{
                @"id": @"20",
                @"name": @"XZKeychain"
            },
        ]
    ];
    XZMocoaTableViewModel *viewModel = [[XZMocoaTableViewModel alloc] initWithModel:data];
    viewModel.module = XZMocoa(@"https://xzkit.xezun.com/examples");
    self.tableView.viewModel = viewModel;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (IBAction)unwindToMainPage:(UIStoryboardSegue *)unwindSegue {
    
}

@end


@interface ExampleHomeTableViewCell : UITableViewCell <XZMocoaTableCell>
@end
@implementation ExampleHomeTableViewCell
+ (void)load {
    XZMocoa(@"https://xzkit.xezun.com/examples").section.cell.viewReuseIdentifier = @"cell";
}

- (void)viewModelDidChange:(nullable XZMocoaViewModel *)newValue {
    [super viewModelDidChange:newValue];
    
    NSDictionary *dict = self.viewModel.model;
    self.textLabel.text = [NSString stringWithFormat:@"%02ld. %@", (self.viewModel.index + 1), dict[@"name"]];
}

- (void)tableView:(id<XZMocoaTableView>)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = self.viewModel.model;
    NSString *name = [NSString stringWithFormat:@"Example%@", dict[@"id"]];
    UIViewController *viewController = [UIStoryboard storyboardWithName:name bundle:nil].instantiateInitialViewController;
    viewController.modalPresentationStyle = UIModalPresentationFullScreen;
    viewController.modalTransitionStyle = 0;
    [self.xz_viewController presentViewController:viewController animated:YES completion:nil];
}
@end



@interface ExampleHomeTableViewCellViewModel : XZMocoaTableCellViewModel
@end
@implementation ExampleHomeTableViewCellViewModel
+ (void)load {
    XZMocoa(@"https://xzkit.xezun.com/examples").section.cell.viewModelClass = self;
}
- (CGFloat)height {
    return 44.0;
}
@end

@interface ExampleHomeTableViewSectionHeader : XZMocoaTableHeaderViewModel

@end

@interface ExampleHomeTableViewSectionViewModel : XZMocoaTableSectionViewModel


@end

@implementation ExampleHomeTableViewSectionViewModel

+ (void)load {
    XZMocoa(@"https://xzkit.xezun.com/examples").section.viewModelClass = self;
}

- (NSInteger)model:(id)model numberOfModelsForSupplementaryElementOfKind:(XZMocoaKind)kind {
    if ([kind isEqualToString:XZMocoaKindHeader]) {
        return 1;
    }
    return 0;
}

@end

@interface ExampleHomeTableHeaderViewModel : XZMocoaTableHeaderViewModel

@end

@implementation ExampleHomeTableHeaderViewModel

+ (void)load {
    XZMocoa(@"https://xzkit.xezun.com/examples").section.header.viewModelClass = self;
}

- (void)prepare {
    [super prepare];
    self.height = 20;
}

@end

@interface ExampleHomeTableHeaderView : XZMocoaTableHeaderView

@end

@implementation ExampleHomeTableHeaderView

+ (void)load {
    XZMocoa(@"https://xzkit.xezun.com/examples").section.header.viewClass = self;
}

@end
