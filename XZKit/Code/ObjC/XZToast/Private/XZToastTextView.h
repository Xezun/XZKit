//
//  XZToastTextView.h
//  XZToast
//
//  Created by 徐臻 on 2025/5/9.
//

#import <UIKit/UIKit.h>
#import "XZToast.h"

NS_ASSUME_NONNULL_BEGIN

/// 方便做动画的文本视图。
///
/// 使用 UIView.animation 对 UILabel 进行动画时，如果 UILabel 文字由多变少，即宽度从长变短，那么实际效果可能是 UILabel 直接变短，而没有动画变短的过程。
///
/// 特别是，在短的状态下，文字占不满宽度，即是通过 sizeToFit 得到的宽度，都无法展示 UILabel 变短的动画，因此定义了此视图。
@interface XZToastTextView : UIView <XZToastView>
@property (nonatomic, copy, nullable) NSString *text;
@end


NS_ASSUME_NONNULL_END
