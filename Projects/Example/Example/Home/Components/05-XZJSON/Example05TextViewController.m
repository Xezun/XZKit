//
//  Example05TextViewController.m
//  Example
//
//  Created by 徐臻 on 2025/2/20.
//

#import "Example05TextViewController.h"

@interface Example05TextViewController ()
@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@end

@implementation Example05TextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _textLabel.font = [UIFont monospacedSystemFontOfSize:13.0 weight:(UIFontWeightRegular)];
    _textLabel.text = _text;
}

@end
