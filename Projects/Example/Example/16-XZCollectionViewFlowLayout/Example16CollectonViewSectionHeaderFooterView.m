//
//  Example16CollectonViewSectionHeaderFooterView.m
//  Example
//
//  Created by Xezun on 2024/6/1.
//

#import "Example16CollectonViewSectionHeaderFooterView.h"

@implementation Example16CollectonViewSectionHeaderFooterView {
    UILabel *_textLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _textLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _textLabel.numberOfLines = 0;
        _textLabel.backgroundColor = UIColor.systemGray6Color;
        _textLabel.font = [UIFont boldSystemFontOfSize:17.0];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_textLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    
    _textLabel.text = [NSString stringWithFormat:@"Section %@ %ld", self.reuseIdentifier, layoutAttributes.indexPath.section];
}

- (void)tapAction:(id)sender {
    [self.delegate didSelectHeaderFooterView:self];
}


@end
