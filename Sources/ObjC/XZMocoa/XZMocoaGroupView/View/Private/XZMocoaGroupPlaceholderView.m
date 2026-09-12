//
//  XZMocoaGroupPlaceholderView.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/28.
//

#import "XZMocoaGroupPlaceholderView.h"

#if DEBUG
@implementation XZMocoaGroupPlaceholderView {
    UILabel *_debugLabel;
    UILabel *_nameLabel;
    UILabel *_reasonLabel;
    UILabel *_detailLabel;
    UIView *_detailBackgroundView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        
        _name = @"DEBUG";
        
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 1.0)];
        separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        separatorView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        [self addSubview:separatorView];
        
        _debugLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 25.0, 15.0)];
        _debugLabel.backgroundColor = UIColor.redColor;
        _debugLabel.font = [UIFont boldSystemFontOfSize:10.0];
        _debugLabel.textColor = UIColor.whiteColor;
        _debugLabel.textAlignment = NSTextAlignmentCenter;
        _debugLabel.text = @"占位";
        [self addSubview:_debugLabel];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(35.0, 10.0, 45.0, 15.0)];
        _nameLabel.font = [UIFont boldSystemFontOfSize:10.0];
        _nameLabel.textColor = UIColor.whiteColor;
        _nameLabel.backgroundColor = UIColor.orangeColor;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.text = _name;
        [self addSubview:_nameLabel];
        
        _reasonLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 30.0, 100.0, 20.0)];
        _reasonLabel.font = [UIFont systemFontOfSize:14.0];
        _reasonLabel.textColor = UIColor.whiteColor;
        [self addSubview:_reasonLabel];
        
        _detailBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 55.0, 100.0, 60.0)];
        _detailBackgroundView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1.0];
        [self addSubview:_detailBackgroundView];
        
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont fontWithName:@".AppleSystemUIFontMonospaced-Regular" size:12.0];
        _detailLabel.textColor = UIColor.whiteColor;
        _detailLabel.numberOfLines = 4;
        [_detailBackgroundView addSubview:_detailLabel];
        
        _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_detailBackgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_detailLabel]-3-|" options:(NSLayoutFormatDirectionLeadingToTrailing) metrics:nil views:NSDictionaryOfVariableBindings(_detailLabel)]];
        [_detailBackgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[_detailLabel]-(>=3@751)-|" options:(NSLayoutFormatDirectionLeadingToTrailing) metrics:nil views:NSDictionaryOfVariableBindings(_detailLabel)]];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)setName:(NSString *)name {
    if (![_name isEqualToString:name]) {
        _name = name.copy;
        _nameLabel.text = _name;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect const bounds = self.bounds;
    _reasonLabel.frame = CGRectMake(10.0, 30.0, bounds.size.width - 20.0, 20.0);
    _detailBackgroundView.frame = CGRectMake(10.0, 55.0, bounds.size.width - 20.0, 60.0);
}

- (void)prepareForViewModel {
    [super prepareForViewModel];
    
    XZMocoaGroupPlaceholderViewModel *viewModel = self.viewModel;
    _reasonLabel.text = viewModel.reason;
    
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
    
    NSLog(@"[XZMocoa] [DEBUG] \n%@\n--------------\n%@", _reasonLabel.text, _detailLabel.text);
}

@end
#endif
