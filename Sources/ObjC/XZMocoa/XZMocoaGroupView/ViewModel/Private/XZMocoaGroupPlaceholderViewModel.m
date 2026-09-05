//
//  XZMocoaGroupPlaceholderViewModel.m
//  XZKit
//
//  Created by Xezun on 2025/1/20.
//

#import "XZMocoaGroupPlaceholderViewModel.h"
#import "XZMocoaGroupReusableViewModel.h"
#import "XZMocoaGroupViewModel.h"
#import "XZJSON.h"
#import "NSString+XZKit.h"

#if DEBUG

@implementation XZMocoaGroupPlaceholderViewModel

- (instancetype)initWithModel:(XZMocoaGroupReusableViewModel *)model {
    return [super initWithModel:model];
}

- (void)prepare {
    [super prepare];
    
    XZMocoaGroupReusableViewModel * const viewModel  = self.model;
    id<XZMocoaModel>                const model      = viewModel.model;
    XZMocoaModule                 * const module     = viewModel.module;
    
    if (module) {
        _reason = [NSString stringWithFormat:@"%@", module.url];
        
        _detail = [NSString stringWithFormat:@"[M] %@\n", ((id)module.modelClass) ?: @"<None>"];
        switch (module.viewForm) {
            case XZMocoaModuleViewFormUnknown:
                _detail = [_detail stringByAppendingFormat:@"[V] <None>\n"];
                break;
            case XZMocoaModuleViewFormClass:
                _detail = [_detail stringByAppendingFormat:@"[V] class = %@\n", module.viewClass];
                break;
            case XZMocoaModuleViewFormNib:
                if (module.viewNibClass) {
                    _detail = [_detail stringByAppendingFormat:@"[V] nibClass = %@, nibName = %@\n", module.viewNibClass, module.viewNibName];
                } else if (module.viewNibBundle) {
                    _detail = [_detail stringByAppendingFormat:@"[V] nibName = %@, nibBundle = %@\n", module.viewNibName, module.viewNibBundle.bundleIdentifier];
                } else {
                    _detail = [_detail stringByAppendingFormat:@"[V] nibName = %@\n", module.viewNibName];
                }
                break;
            case XZMocoaModuleViewFormStoryboard:
                _detail = [_detail stringByAppendingFormat:@"[V] storyboardName = %@ <注册错误，不支持>\n", module.viewStoryboardName];
                break;
            case XZMocoaModuleViewFormStoryboardReusableView:
                _detail = [_detail stringByAppendingFormat:@"[V] reuseIdentifier = %@\n", module.viewReuseIdentifier];
                break;
        }
        _detail = [_detail stringByAppendingFormat:@"[VM] %@\n--------------\n", ((id)module.viewModelClass) ?: @"<None>"];
    } else {
        _reason = @"模块未注册";
        _detail = @"";
    }
    _detail = [_detail stringByAppendingFormat:@"name: %@, \ndata: %@", model.mocoaName, [NSString xz_stringWithJSON:[XZJSON encode:model options:(NSJSONWritingPrettyPrinted) error:nil]]];
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
