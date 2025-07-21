//
//  Example21ViewController.m
//  Example
//
//  Created by 徐臻 on 2025/1/30.
//

#import "Example21ViewController.h"
#import "Example21TableViewSectionModel.h"
#import "Example05TextViewController.h"
@import XZKit;

@interface Example21ViewController ()

@end

@implementation Example21ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XZObjcClassDescriptor *descriptor = [XZObjcClassDescriptor descriptorForClass:objc_getClass("Example21Model")];
        
    XZMocoaTableViewModel *viewModel = [[XZMocoaTableViewModel alloc] initWithModel:@[
        [Example21TableViewSectionModel modelWithName:@"模型" descriptors:@[descriptor]],
        [Example21TableViewSectionModel modelWithName:@"实例变量" descriptors:descriptor.ivars.allValues],
        [Example21TableViewSectionModel modelWithName:@"属性" descriptors:descriptor.properties.allValues],
        [Example21TableViewSectionModel modelWithName:@"方法" descriptors:descriptor.methods.allValues]
    ]];
    viewModel.module = XZMocoa(@"https://xzkit.xezun.com/examples/21");
    self.viewModel = viewModel;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (![segue.identifier isEqualToString:@"showText"]) {
        return;
    }
    Example05TextViewController * const nextVC = segue.destinationViewController;
    if ([sender isKindOfClass:UITableViewCell.class]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            nextVC.text = [[self.viewModel cellViewModelAtIndexPath:indexPath].model description];
        }
    }
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
