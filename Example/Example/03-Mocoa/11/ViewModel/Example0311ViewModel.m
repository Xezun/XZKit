//
//  Example0311ViewModel.m
//  Example
//
//  Created by Xezun on 2023/7/23.
//

#import "Example0311ViewModel.h"
#import "Example0311Model.h"
@import XZJSON;

@implementation Example0311ViewModel

- (void)dealloc {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (instancetype)initWithModel:(id)model {
    return [super initWithModel:[Example0311Model new]];
}

- (void)prepare {
    [super prepare];
    
    [self loadData];
}

- (void)loadData {
    NSDictionary *dict = @{
        @"card": @"contact",
        @"firstName": @"Foo",
        @"lastName": @"Bar",
        @"photo": @"https://developer.apple.com/assets/elements/icons/xcode/xcode-64x64_2x.png",
        @"phone": @"13923459876",
        @"address": @"北京市海淀区人民路幸福里小区7号楼6单元503室",
        @"title": @"示例说明",
        @"content": @"本示例演示了，如何使用MVVM设计模式，来设计基于控制器的模块开发流程。\n"
        "1、控制器作为View角色，负责渲染视图。\n"
        "2、控制器作为模块入口，它不需要外部参数，自行创建ViewModel处理逻辑。\n"
        "3、ViewModel负责了请求数据和处理数据的逻辑。\n"
        "4、本例中的业务逻辑，比如格式化手机号、姓名等操作，对于作为View的控制器来说是透明的。"
    };
    [XZJSON object:self.model decodeWithDictionary:dict];
    
    [self dataDidChange];
}

- (void)dataDidChange {
    Example0311Model *data = self.model; // [self loadDataFromDatabase];
    self.name    = [NSString stringWithFormat:@"%@ %@", data.firstName, data.lastName];
    self.photo   = [NSURL URLWithString:data.photo];
    self.phone   = [self formatPhoneNumber:data.phone];
    self.address = data.address;
    self.title   = data.title;
    self.content = data.content;
    [self sendActionsForKeyEvents:nil];
}

- (NSString *)formatPhoneNumber:(NSString *)phone {
    if (phone.length <= 3) {
        return phone;
    }
    NSString *part1 = [phone substringToIndex:3];
    if (phone.length <= 7) {
        NSString *part2 = [phone substringFromIndex:3];
        return [NSString stringWithFormat:@"%@-%@", part1, part2];
    }
    NSString *part2 = [phone substringWithRange:NSMakeRange(3, phone.length - 3 - 4)];
    NSString *part3 = [phone substringFromIndex:phone.length - 4];
    return [NSString stringWithFormat:@"%@-%@-%@", part1, part2, part3];
}

@end
