//
//  Example21ObjectViewController.m
//  Example
//
//  Created by Xezun on 2025/1/30.
//

#import "Example21ObjectViewController.h"
#import "Example21TableViewSectionModel.h"
#import "Example05TextViewController.h"
@import XZKit;

@interface Example21ObjectViewController ()

@end

@implementation Example21ObjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XZLog(@"%@", class_getSuperclass(NSObject.class));
    
    XZLog(@"double => %s", @encode(double));
    XZLog(@"long double => %s", @encode(long double));
    XZLog(@"long => %s", @encode(long));
    XZLog(@"long long => %s", @encode(long long));
    XZLog(@"BOOL => %s", @encode(BOOL));
    XZLog(@"bool => %s", @encode(bool));
    XZLog(@"void => %s", @encode(void));
    XZLog(@"char * => %s", @encode(char *));
    XZLog(@"SEL => %s", @encode(SEL));
    XZLog(@"void * => %s", @encode(void *));
    XZLog(@"int[0] => %s", @encode(int[0]));
    XZLog(@"Class => %s", @encode(Class));
    XZLog(@"NSObject => %s", @encode(NSObject));
    XZLog(@"ExampleAppDelegate => %s", @encode(Example21ObjectViewController));
    XZLog(@"NSObject * => %s", @encode(NSObject *));
    XZLog(@"ExampleAppDelegate * => %s", @encode(Example21ObjectViewController *));
    XZLog(@"id => %s", @encode(id));
    
    XZLog(@"char[1] => %s", @encode(char[1]));
    
    struct Foobar {
        int a: 0x20;
        int c: 16;
        int b: 16;
    };
    
    XZLog(@"struct Foobar => %s", @encode(struct Foobar));
    
    for (int i = 0; i < CHAR_MAX; i++) {
        @try {
            XZObjcType *type = [XZObjcType typeForType:(XZStdcType)i];
            NSLog(@"<%c> => %@", i, type);
        } @catch (NSException *exception) {
            NSLog(@"<%c> is not a type", i);
        } @finally {
            
        }
    }
    
    XZObjcClass *descriptor = [XZObjcClass classWithClass:objc_getClass("Example21Object")];
    
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
