//
//  ExampleViewController.m
//  Example
//
//  Created by Xezun on 2024/9/10.
//

#import "ExampleViewController.h"
@import XZExtensions;
@import XZMocoa;
@import XZToast;

@interface ExampleViewController () {
    NSArray<NSString *> *_dataArray;
}

@property (nonatomic, readonly) XZMocoaTableView *tableView;

@end

@implementation ExampleViewController

- (XZMocoaTableView *)tableView {
    return (id)self.view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *data = @[
        @"01. XZDefines",
        @"02. XZExtensions",
        @"03. XZMocoa",
        @"04. XZML",
        @"05. XZJSON",
        @"06. XZRefresh",
        @"07. XZPageView",
        @"08. XZPageControl",
        @"09. XZSegmentedControl",
        @"10. XZGeometry",
        @"11. XZTextImageView",
        @"12. XZContentStatus",
        @"13. XZToast",
        @"14. XZURLQuery",
        @"15. XZLocale",
        @"16. XZCollectionViewFlowLayout",
        @"17. XZNavigationController",
        @"18. XZDataDigester",
        @"19. XZDataCryptor",
        @"20. XZKeychain",
        @"21. XZObjcDescriptor",
    ];
    XZMocoaTableViewModel *viewModel = [[XZMocoaTableViewModel alloc] initWithModel:@[data]];
    viewModel.module = XZMocoa(@"https://xzkit.xezun.com/examples");
    self.tableView.viewModel = viewModel;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIButton * button;
    [button titleEdgeInsets];
    
    // NSLog(@"%@", self.view.xz_description);
}

- (IBAction)unwindToMainPage:(UIStoryboardSegue *)unwindSegue {
   
}

@end


@interface ExampleTableViewCell : UITableViewCell <XZMocoaTableViewCell>
@end
@implementation ExampleTableViewCell
+ (void)load {
    XZMocoa(@"https://xzkit.xezun.com/examples").section.cell.viewReuseIdentifier = @"cell";
}

- (void)viewModelDidChange:(nullable XZMocoaViewModel *)newValue {
    [super viewModelDidChange:newValue];
    
    NSString *name = self.viewModel.model;
    self.textLabel.text = name;
}

- (void)tableView:(XZMocoaTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *name = [NSString stringWithFormat:@"Example%02ld", (long)(indexPath.row + 1)];
    UIViewController *viewController = [UIStoryboard storyboardWithName:name bundle:nil].instantiateInitialViewController;
    viewController.modalPresentationStyle = UIModalPresentationFullScreen;
    viewController.modalTransitionStyle = 0;
    [self.xz_viewController presentViewController:viewController animated:YES completion:nil];
}
@end



@interface ExampleTableViewCellViewModel : XZMocoaTableViewCellViewModel
@end
@implementation ExampleTableViewCellViewModel
+ (void)load {
    XZMocoa(@"https://xzkit.xezun.com/examples").section.cell.viewModelClass = self;
}
- (CGFloat)height {
    return 44.0;
}
@end

