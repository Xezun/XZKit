//
//  Example0312CellViewModel.m
//  Example
//
//  Created by Xezun on 2023/8/21.
//

#import "Example0312CellViewModel.h"
#import "Example0312CellModel.h"

@implementation Example0312CellViewModel

+ (void)load {
    XZModule(@"https://mocoa.xezun.com/examples/12/table/").section.cell.viewModelClass = self;
}

- (void)prepare {
    [super prepare];
    
    self.height = 44.0;
    
    Example0312CellModel *data = self.model;
    self.name = [NSString stringWithFormat:@"%@ %@", data.firstName, data.lastName];
}

- (void)tableView:(XZMocoaTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Example0312CellModel *data = self.model;
    NSString *title = @"温馨提示";
    NSString *message = [NSString stringWithFormat:@"打电话给“%@”？", self.name];
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(UIAlertControllerStyleAlert)];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", data.phone]];
        [UIApplication.sharedApplication openURL:url options:@{} completionHandler:nil];
    }]];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil]];
    [tableView.viewController presentViewController:alertVC animated:YES completion:nil];
}

@end
