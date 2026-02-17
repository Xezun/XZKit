//
//  ExampleMainHomeCellViewModel.m
//  Example
//
//  Created by 徐臻 on 2026/2/2.
//

#import "ExampleMainHomeCellViewModel.h"
#import "ExampleMainHomeCellModel.h"

@implementation ExampleMainHomeCellViewModel

+ (void)load {
    XZMocoa(@"https://xzkit.xezun.com/examples").section.cell.viewModelClass = self;
}

- (CGFloat)height {
    return 44.0;
}

- (void)prepare {
    [super prepare];
    
    ExampleMainHomeCellModel *model = self.model;
    self.title = [NSString stringWithFormat:@"%ld. %@", (self.index + 1), model.name];
}

- (void)tableView:(id<XZMocoaTableView>)tableView didSelectCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    ExampleMainHomeCellModel *model = self.model;
    NSString *name = [NSString stringWithFormat:@"Example%@", model.identifier];
    UIViewController *viewController = [UIStoryboard storyboardWithName:name bundle:nil].instantiateInitialViewController;
    if (![NSUserDefaults.standardUserDefaults boolForKey:@"modalPresentationStyle"]) {
        viewController.modalPresentationStyle = UIModalPresentationFullScreen;
        viewController.modalTransitionStyle = 0;
    }
    [self.viewController presentViewController:viewController animated:YES completion:nil];
}

@end
