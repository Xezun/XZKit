//
//  Example0322TextViewModel.m
//  Example
//
//  Created by Xezun on 2023/8/9.
//

#import "Example0322TextViewModel.h"
#import "Example0322TextModel.h"

@implementation Example0322TextViewModel

@dynamic model;
@synthesize name = _name;
@synthesize phone = _phone;

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/22/").cell.viewModelClass = self;
}

- (void)prepare {
    [super prepare];
    
    CGFloat width = floor((UIScreen.mainScreen.bounds.size.width - 30.0) / 2.0);
    self.size = CGSizeMake(width , 60.0);
    
    [self loadData];
}

- (void)loadData {
    Example0322TextModel *model = self.model;
    _name  = [NSString stringWithFormat:@"%@ %@", model.firstName, model.lastName];
    _phone = model.phone;
}

- (NSString *)name {
    Example0322TextModel *model = self.model;
    return [NSString stringWithFormat:@"%@ %@", model.firstName, model.lastName];
}

- (NSString *)phone {
    Example0322TextModel *model = self.model;
    return model.phone;
}

- (void)didReceiveEvents:(XZMocoaEvents *)events {
    // 收到 editor 的 events 事件。作为唯一下级，这里省略了对 subViewModel 的身份判定。
    // 由于与 target-action 使用了一样的名称，因此这里用了 events.key 直接发送 target-action 事件。
    [self sendActionsForKey:events.key value:nil];
}

- (void)collectionViewCell:(UICollectionViewCell *)cell wasSelectedAtIndexPath:(NSIndexPath *)indexPath {
    NSURL *moduleURL = [NSURL URLWithString:@"https://mocoa.xezun.com/examples/21/editor"];
    [cell.xz_navigationController presentMocoaURL:moduleURL options:@{
        XZMocoaKeyModel: self.model,
        XZMocoaKeyViewModel: self
    } animated:YES];
}

@end
