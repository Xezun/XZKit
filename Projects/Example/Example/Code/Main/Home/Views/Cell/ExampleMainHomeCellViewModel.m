//
//  ExampleMainHomeCellViewModel.m
//  Example
//
//  Created by Xezun on 2026/2/2.
//

#import "ExampleMainHomeCellViewModel.h"
#import "ExampleMainHomeCellModel.h"

@implementation ExampleMainHomeCellViewModel

+ (void)load {
    XZMocoa(@"https://xzkit.xezun.com/examples").cell.viewModelClass = self;
}

- (void)prepare {
    [super prepare];
    
    self.height = 50.0;
    
    ExampleMainHomeCellModel *model = self.model;
    self.title = [NSString stringWithFormat:@"%ld. %@", (self.index + 1), model.name];
}

- (void)tableViewCell:(UITableViewCell *)cell wasSelectedAtIndexPath:(NSIndexPath *)indexPath {
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
