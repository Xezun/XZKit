//
//  XZMocoaGroupPlaceholderView.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/28.
//

#import "XZMocoaGroupPlaceholderView.h"

#if DEBUG
@implementation XZMocoaGroupPlaceholderView {
    UILabel *_kindLabel;
    UILabel *_moduleLabel;
    UILabel *_detailLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 1.0)];
        separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        separatorView.backgroundColor = UIColor.systemBackgroundColor;
        [self addSubview:separatorView];
        
        UIView *debugView = [[UIView alloc] init];
        debugView.translatesAutoresizingMaskIntoConstraints = NO;
        debugView.backgroundColor = UIColor.redColor;
        {
            UILabel *_debugLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 25.0, 15.0)];
            _debugLabel.font = [UIFont boldSystemFontOfSize:10.0];
            _debugLabel.textColor = UIColor.whiteColor;
            _debugLabel.textAlignment = NSTextAlignmentCenter;
            _debugLabel.text = @"占位";
            _debugLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [debugView addSubview:_debugLabel];
            
            [NSLayoutConstraint activateConstraints:@[
                [_debugLabel.leadingAnchor constraintEqualToAnchor:debugView.leadingAnchor constant:+5.0],
                [_debugLabel.trailingAnchor constraintEqualToAnchor:debugView.trailingAnchor constant:-5.0],
                [_debugLabel.topAnchor constraintEqualToAnchor:debugView.topAnchor],
                [_debugLabel.bottomAnchor constraintEqualToAnchor:debugView.bottomAnchor]
            ]];
        }
        [self addSubview:debugView];
        
        UIView *kindView = [[UIView alloc] init];
        kindView.translatesAutoresizingMaskIntoConstraints = NO;
        kindView.backgroundColor = UIColor.orangeColor;
        {
            _kindLabel = [[UILabel alloc] initWithFrame:CGRectMake(35.0, 10.0, 45.0, 15.0)];
            _kindLabel.translatesAutoresizingMaskIntoConstraints = NO;
            _kindLabel.font = [UIFont boldSystemFontOfSize:10.0];
            _kindLabel.textColor = UIColor.whiteColor;
            _kindLabel.textAlignment = NSTextAlignmentCenter;
            _kindLabel.text = @"DEBUG";
            [kindView addSubview:_kindLabel];
            
            [NSLayoutConstraint activateConstraints:@[
                [_kindLabel.leadingAnchor constraintEqualToAnchor:kindView.leadingAnchor constant:+5.0],
                [_kindLabel.trailingAnchor constraintEqualToAnchor:kindView.trailingAnchor constant:-5.0],
                [_kindLabel.topAnchor constraintEqualToAnchor:kindView.topAnchor],
                [_kindLabel.bottomAnchor constraintEqualToAnchor:kindView.bottomAnchor]
            ]];
        }
        [self addSubview:kindView];
        
        UIView *moduleView = [[UIView alloc] init];
        moduleView.translatesAutoresizingMaskIntoConstraints = NO;
        moduleView.backgroundColor = UIColor.blackColor;
        {
            _moduleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 30.0, 100.0, 20.0)];
            _moduleLabel.translatesAutoresizingMaskIntoConstraints = NO;
            _moduleLabel.font = [UIFont systemFontOfSize:14.0];
            _moduleLabel.textColor = UIColor.whiteColor;
            [moduleView addSubview:_moduleLabel];
            
            [NSLayoutConstraint activateConstraints:@[
                [_moduleLabel.leadingAnchor constraintEqualToAnchor:moduleView.leadingAnchor constant:+3.0],
                [_moduleLabel.trailingAnchor constraintEqualToAnchor:moduleView.trailingAnchor constant:-3.0],
                [_moduleLabel.topAnchor constraintEqualToAnchor:moduleView.topAnchor],
                [_moduleLabel.bottomAnchor constraintEqualToAnchor:moduleView.bottomAnchor]
            ]];
        }
        [self addSubview:moduleView];
        
        UIView *detailView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 55.0, 100.0, 60.0)];
        detailView.translatesAutoresizingMaskIntoConstraints = NO;
        detailView.backgroundColor = UIColor.blackColor;
        {
            _detailLabel = [[UILabel alloc] init];
            _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
            _detailLabel.font = [UIFont monospacedSystemFontOfSize:12.0 weight:(UIFontWeightRegular)];
            _detailLabel.textColor = UIColor.whiteColor;
            _detailLabel.numberOfLines = 4;
            [detailView addSubview:_detailLabel];
            
            [NSLayoutConstraint activateConstraints:@[
                [_detailLabel.leadingAnchor constraintEqualToAnchor:detailView.leadingAnchor constant:+3.0],
                [_detailLabel.trailingAnchor constraintEqualToAnchor:detailView.trailingAnchor constant:-3.0],
                [_detailLabel.topAnchor constraintEqualToAnchor:detailView.topAnchor],
                [_detailLabel.bottomAnchor constraintEqualToAnchor:detailView.bottomAnchor]
            ]];
        }
        [self addSubview:detailView];
        
        [NSLayoutConstraint activateConstraints:@[
            [debugView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:+5.0],
            [debugView.topAnchor constraintEqualToAnchor:self.topAnchor constant:+5.0],
            [debugView.heightAnchor constraintEqualToConstant:15.0],
            
            [kindView.leadingAnchor constraintEqualToAnchor:debugView.trailingAnchor constant:0.0],
            [kindView.topAnchor constraintEqualToAnchor:debugView.topAnchor],
            [kindView.heightAnchor constraintEqualToConstant:15.0],
            
            [moduleView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:+5.0],
            [moduleView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-5.0],
            [moduleView.topAnchor constraintEqualToAnchor:debugView.bottomAnchor constant:+5.0],
            [moduleView.heightAnchor constraintEqualToConstant:20.0],
            
            [detailView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:+5.0],
            [detailView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-5.0],
            [detailView.topAnchor constraintEqualToAnchor:moduleView.bottomAnchor constant:+5.0],
            [detailView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-5.0],
        ]];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)prepareForViewModel {
    [super prepareForViewModel];
    
    XZMocoaGroupPlaceholderViewModel *viewModel = self.viewModel;
    _moduleLabel.text = viewModel.moduleURLString;
    _kindLabel.text = viewModel.kind;
    
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.minimumLineHeight = 17.0;
    style.maximumLineHeight = 17.0;
    _detailLabel.attributedText = [[NSAttributedString alloc] initWithString:viewModel.detail attributes:@{
        NSParagraphStyleAttributeName: style
    }];
}

- (void)tapAction:(id)sender {
    NSString *title = @"温馨提示";
    NSString *message = @""
    "这是一个占位视图，因目标视图的模块信息不全而出现。\n"
    "请根据提示信息或控制台输出内容，检查相关代码。\n"
    "占位视图仅在 DEBUG 环境展示。";
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(UIAlertControllerStyleAlert)];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:nil]];
    [self.xz_viewController presentViewController:alertVC animated:YES completion:nil];
    
    NSLog(@"[XZMocoa] [DEBUG] \n%@\n--------------\n%@", _moduleLabel.text, _detailLabel.text);
}

@end
#endif
