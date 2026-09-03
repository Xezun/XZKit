//
//  XZMocoaGroupReusableViewModel.h
//  XZKit
//
//  Created by 徐臻 on 2026/9/3.
//

#import "XZMocoaViewModel.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_UI_ACTOR @interface XZMocoaGroupReusableViewModel : XZMocoaViewModel
/// 重用标识符。
///
/// 通过 XZMocoaModule 注册的 cell 使用 ``XZMocoaReuseIdentifier(kind:name:)`` 函数构造标识符。
///
/// 通过 Storyboard 定义的 cell 虽然无法在 XZMocoaModule 中注册，
/// 但是仅需将 cell 在 Storyboard 中设置的标识符，赋值给此属性即可正常使用。
@property (nonatomic, copy) NSString *reuseIdentifier;

@property (nonatomic) NSIndexPath *indexPath;
@end

NS_ASSUME_NONNULL_END
