//
//  XZImageLineDash+XZImage.h
//  XZKit
//
//  Created by Xezun on 2021/2/21.
//

#import <XZKit/XZImageLineDash.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XZImageLineDashDelegate <NSObject>
- (void)lineDashDidChange:(XZImageLineDash *)lineDash;
@end

@interface XZImageLineDash ()
@property (nonatomic, weak) id<XZImageLineDashDelegate> delegate;

- (void)setPhase:(CGFloat)phase segments:(CGFloat *)segments length:(NSInteger)length;
@end

NS_ASSUME_NONNULL_END
