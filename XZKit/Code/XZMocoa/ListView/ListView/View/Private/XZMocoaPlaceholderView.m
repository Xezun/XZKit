//
//  XZMocoaPlaceholderView.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/28.
//

#import "XZMocoaPlaceholderView.h"
#import "XZMocoaListViewSectionViewModel.h"

#if DEBUG
@implementation XZMocoaPlaceholderView {
    UILabel *_reasonLabel;
    UILabel *_detailLabel;
    UIView *_detailBackgroundView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor colorWithWhite:0x1f / 255.0 alpha:1.0];
        
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 1.0)];
        separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        separatorView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        [self addSubview:separatorView];
        
        UILabel *debugLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 40.0, 15.0)];
        debugLabel.backgroundColor = UIColor.redColor;
        debugLabel.font = [UIFont boldSystemFontOfSize:10.0];
        debugLabel.textColor = UIColor.whiteColor;
        debugLabel.textAlignment = NSTextAlignmentCenter;
        debugLabel.text = @"DEBUG";
        [self addSubview:debugLabel];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 10.0, 45.0, 15.0)];
        titleLabel.font = [UIFont boldSystemFontOfSize:10.0];
        titleLabel.textColor = UIColor.whiteColor;
        titleLabel.backgroundColor = UIColor.orangeColor;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = @"占位视图";
        [self addSubview:titleLabel];
        
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

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect const bounds = self.bounds;
    _reasonLabel.frame = CGRectMake(10.0, 30.0, bounds.size.width - 20.0, 20.0);
    _detailBackgroundView.frame = CGRectMake(10.0, 55.0, bounds.size.width - 20.0, 60.0);
}

- (void)viewModelDidChange {
    XZMocoaPlaceholderViewModel *viewModel = self.viewModel;
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
    [self.viewController presentViewController:alertVC animated:YES completion:nil];
    
    NSLog(@"[XZMocoa] [DEBUG] \n%@ \n%@", _reasonLabel.text, _detailLabel.text);
}

@end

@implementation XZMocoaPlaceholderViewModel

- (void)prepare {
    [super prepare];
    
    XZMocoaListViewCellViewModel * const viewModel = self.model;
    XZMocoaListViewSectionViewModel * const superViewModel = viewModel.superViewModel;
    
    _reason = [self reasonByCheckingModule:viewModel.module];
    
    XZMocoaName name1 = ((id<XZMocoaModel>)superViewModel.model).mocoaName;
    XZMocoaName name2 = ((id<XZMocoaModel>)viewModel.model).mocoaName;
    if (name1.length == 0) name1 = @"<None>";
    if (name2.length == 0) name2 = @"<None>";
    
    if ([superViewModel indexOfCellViewModel:viewModel] != NSNotFound) {
        _detail = [NSString stringWithFormat:@"Name: section=%@, cell=%@ \nData: %@", name1, name2, viewModel.model];
    } else {
        [superViewModel.supplementaryViewModels enumerateKeysAndObjectsUsingBlock:^(XZMocoaKind kind, NSArray<XZMocoaViewModel *> *obj, BOOL * _Nonnull stop) {
            if ([obj containsObject:viewModel]) {
                _detail = [NSString stringWithFormat:@"Name: section=%@, %@=%@ \nData: %@", name1, kind, name2, viewModel.model];
                *stop = YES;
            }
        }];
    }
}

- (NSString *)reasonByCheckingModule:(XZMocoaModule *)module {
    if (!module) {
        return @"模块不存在";
    }
    if (!module.modelClass && !module.viewClass && !module.viewModelClass) {
        return @"模块缺少 Model、View、ViewModel";
    }
    if (!module.modelClass && !module.viewClass) {
        return @"模块缺少 Model、View";
    }
    if (!module.modelClass && !module.viewModelClass) {
        return @"模块缺少 Model、ViewModel";
    }
    if (!module.viewClass && !module.viewModelClass) {
        return @"模块缺少 View、ViewModel";
    }
    if (!module.modelClass) {
        return @"模块缺少 Model";
    }
    if (!module.viewClass) {
        return @"模块缺少 View";
    }
    if (!module.viewModelClass) {
        return @"模块缺少 ViewModel";
    }
    return @"模块不可用";
}

@end

#endif
