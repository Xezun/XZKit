//
//  Example04SettingsViewController.m
//  Example
//
//  Created by 徐臻 on 2024/10/17.
//

#import "Example04SettingsViewController.h"
#import "Example04FontSizeViewController.h"
@import XZML;

@interface Example04SettingsViewController ()

@end

@implementation Example04SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)unwindToSettingsViewController:(UIStoryboardSegue *)unwindSegue {
    __kindof UIViewController * sourceViewController = unwindSegue.sourceViewController;
    if ([sourceViewController isKindOfClass:[Example04FontSizeViewController class]]) {
        Example04FontSizeViewController *selector = sourceViewController;
        NSString *fontName = selector.fontName;
        CGFloat fontSize = selector.fontSize;
        _attributes[XZMLFontAttributeName] = [UIFont fontWithName:fontName size:fontSize];
    }
}

@end
