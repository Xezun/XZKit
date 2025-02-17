//
//  Example21ViewController.m
//  Example
//
//  Created by 徐臻 on 2025/1/30.
//

#import "Example21ViewController.h"
#import "Example21TableViewSectionModel.h"
@import XZObjcDescriptor;

@interface Example21ViewController ()

@end

@implementation Example21ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XZObjcClassDescriptor *descriptor = [XZObjcClassDescriptor descriptorForClass:objc_getClass("Example21Model")];
    NSLog(@"%@", descriptor);
    
    XZMocoaTableViewModel *viewModel = [[XZMocoaTableViewModel alloc] initWithModel:@[
        [Example21TableViewSectionModel modelWithName:@"实例变量" descriptors:descriptor.ivars.allValues],
        [Example21TableViewSectionModel modelWithName:@"属性" descriptors:descriptor.properties.allValues],
        [Example21TableViewSectionModel modelWithName:@"方法" descriptors:descriptor.methods.allValues]
    ]];
    viewModel.module = XZMocoa(@"https://xzkit.xezun.com/examples/21");
    self.viewModel = viewModel;
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
