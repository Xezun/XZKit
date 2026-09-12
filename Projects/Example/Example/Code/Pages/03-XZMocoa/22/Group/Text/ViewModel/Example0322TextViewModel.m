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
    XZMocoa(@"https://mocoa.xezun.com/examples/03/22/collection").cell.viewModelClass = self;
}

- (void)prepare {
    [super prepare];
    
    CGFloat width = floor((UIScreen.mainScreen.bounds.size.width - 30.0) / 2.0);
    self.size = CGSizeMake(width , 60.0);
}

// 注册监听 model 属性的方法。
+ (NSDictionary<NSString *,id> *)mappingModelKeys {
    return @{
        NSStringFromSelector(@selector(nameDidChangeWithFirstName:lastName:)): @[@"firstName", @"lastName"],
        NSStringFromSelector(@selector(phoneDidChangeWithValue:)): @"phone"
    };
}

// 开启主动监听
- (BOOL)shouldObserveModelKeysActively {
    return YES;
}

// 监听 firstName lastName
- (void)nameDidChangeWithFirstName:(NSString *)firstName lastName:(NSString *)lastName {
    _name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    [self sendActionsForKey:XZMocoaKeyName value:_name];
}

// 监听 phone
- (void)phoneDidChangeWithValue:(NSString *)phone {
    _phone = phone.copy;
    [self sendActionsForKey:@"phone" value:_phone];
}

- (void)collectionViewCell:(UICollectionViewCell *)cell wasSelectedAtIndexPath:(NSIndexPath *)indexPath {
    NSURL *moduleURL = [NSURL URLWithString:@"https://mocoa.xezun.com/examples/03/21/editor"];
    [cell.xz_navigationController presentMocoaURL:moduleURL options:@{
        XZMocoaKeyModel: self.model,
        XZMocoaKeyViewModel: self
    } animated:YES];
}

@end
