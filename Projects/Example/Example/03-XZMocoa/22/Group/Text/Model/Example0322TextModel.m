//
//  Example0322TextModel.m
//  Example
//
//  Created by Xezun on 2023/8/9.
//

#import "Example0322TextModel.h"

@implementation Example0322TextModel

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/22/").section.cell.viewModelClass = self;
}

+ (Example0322TextModel *)contactWithFirstName:(NSString *)firstName lastName:(NSString *)lastName phone:(NSString *)phone {
    return [[self alloc] initWithFirstName:firstName lastName:lastName phone:phone];;
}

- (instancetype)initWithFirstName:(NSString *)firstName lastName:(NSString *)lastName phone:(NSString *)phone {
    self = [super init];
    if (self) {
        _firstName = firstName.copy;
        _lastName = lastName.copy;
        _phone = phone;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: %@ %@", self.phone, self.firstName, self.lastName];
}

- (BOOL)isEqual:(Example0322TextModel *)object {
    if ([object isKindOfClass:[Example0322TextModel class]]) {
        if ([self.firstName isEqual:object.firstName]) {
            if ([self.lastName isEqual:object.lastName]) {
                if ([self.phone isEqual:object.phone]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

+ (Example0322TextModel *)contactForIndex:(NSInteger)index {
    NSString *names = @""
    "张三李四王五赵六梁苹龚倪任妃文娅邓碧易茗"
    "黎欣秦姯钱茹龙荔徐馥邹玫汪瑗姜霓崔荔谢蔓"
    "马娘吕蕊廖潇潘玲吕筠韩菁贾瑞钟漪贺华范丝"
    "邱育贾惜任嫂任莓孔聪武佳郑薇石偲龚囡邹瑾"
    "钟仪杨筠蔡娘赖情梁偲魏漪董沁文薰曾慧蔡锦"
    "崔青武芮龚火蔡雁江艳常含汤荔杜姣叶思卢轩"
    "董漪侯莹秦霞姜淼武风马丹江晶卢娆赖羽胡娴"
    "彭娴邵奴郝盈金线龚慧邹姲姚锦白悦袁颖廖妙"
    "谢霭韩琪郭纤杜翠夏缨白娆方丹王嫣谢曼邵娴"
    "范希邹荣沈媛尹欢郝澜石亦杨晶段烁王宛文漪"
    "汪雁段影沈奴田菀";
    
    NSInteger location = index * 2;
    
    if (location >= [names lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) {
        return nil;
    }
    
    NSString *firstName = (index < 9 ? [NSString stringWithFormat:@"0%ld", index + 1] : [NSString stringWithFormat:@"%ld", index + 1]);
    NSString *lastName = [names substringWithRange:NSMakeRange(location, 2)];
    
    NSMutableString *phone = [NSMutableString stringWithCapacity:13];
    [phone appendString:@"1"];
    
    int d[] = {3, 5, 7, 8};
    [phone appendFormat:@"%d", d[arc4random_uniform(4)]];
    [phone appendFormat:@"%d", arc4random_uniform(10)];
    [phone appendString:@"-"];
    
    [phone appendFormat:@"%04d", arc4random_uniform(10000)];
    [phone appendString:@"-"];
    
    [phone appendFormat:@"%04d", arc4random_uniform(10000)];
    
    return [Example0322TextModel contactWithFirstName:firstName lastName:lastName phone:phone];
}

@end
