//
//  XZNumberInputViewController.m
//  XZKitDemo
//
//  Created by Xezun on 2021/2/22.
//

#import "XZNumberInputViewController.h"



@interface XZNumberInputViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation XZNumberInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textField.placeholder = [NSString stringWithFormat:@"%g", self.value];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(textFieldDidChangeNotification:)
                                               name:UITextFieldTextDidChangeNotification
                                             object:self.textField];
}

- (void)textFieldDidChangeNotification:(NSNotification *)notification {
    NSString *text = self.textField.text;
    if (text.length > 0) {
        self.value = self.textField.text.doubleValue;
    } else {
        self.value = self.textField.placeholder.doubleValue;
    }
}

@end


//@interface XZImageNumberInputNavigationController : UINavigationController
//
//@end
//@implementation XZImageNumberInputNavigationController
//
//- (IBAction)unwindFromSegue:(UIStoryboardSegue *)sender {
//    [self dismissViewControllerAnimated:YES completion:nil];
//}
//
//@end

