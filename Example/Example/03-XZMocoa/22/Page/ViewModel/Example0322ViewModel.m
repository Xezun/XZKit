//
//  Example0322ViewModel.m
//  Example
//
//  Created by Xezun on 2023/8/9.
//

#import "Example0322ViewModel.h"
#import "Example0321ContactBook.h"

typedef NS_ENUM(NSUInteger, Example0321ContactBookTestAction) {
    Example0321ContactBookTestActionRestData = 0,
    Example0321ContactBookTestActionSwitchList1,
    Example0321ContactBookTestActionSwitchList2,
    Example0321ContactBookTestActionSortByNameAsc,
    Example0321ContactBookTestActionSortByNameDesc,
    Example0321ContactBookTestActionSortByPhoneAsc,
    Example0321ContactBookTestActionSortByPhoneDesc,
    Example0321ContactBookTestActionInsertAtFirst,
    Example0321ContactBookTestActionInsertAtMiddle,
    Example0321ContactBookTestActionInsertAtLast,
    Example0321ContactBookTestActionDeleteFirst,
    Example0321ContactBookTestActionDeleteLast,
    Example0321ContactBookTestActionDeleteRandom,
    Example0321ContactBookTestActionDeleteAll,
};

@implementation Example0322ViewModel {
    Example0321ContactBook *_contactBook;
}

- (void)prepare {
    [super prepare];
    
    _contactBook = [[Example0321ContactBook alloc] init];
    
    _collectionViewModel = [[XZMocoaCollectionViewModel alloc] initWithModel:_contactBook];
    _collectionViewModel.module = XZMocoa(@"https://mocoa.xezun.com/examples/22/");
    [self addSubViewModel:_collectionViewModel];
}

- (NSArray<NSString *> *)testActions {
    return @[
        @"恢复默认列表",
        @"列表切换测试-列表1", @"列表切换测试-列表2",
        @"姓名正序", @"姓名反序",
        @"号码正序", @"号码反序",
        @"在头部添加一个", @"在中间添加一个", @"在尾部添加一个",
        @"删除第一个", @"删除最后一个", @"随即删除一个",
        @"移除所有"
    ];
}

- (void)performTestActionAtIndex:(NSUInteger)index {
    [_collectionViewModel performBatchUpdates:^{
        [self performTestAction:(Example0321ContactBookTestAction)index];
    } completion:nil];
}

- (void)performTestAction:(Example0321ContactBookTestAction)action {
    switch (action) {
        case Example0321ContactBookTestActionRestData: {
            NSMutableArray *contacts = [NSMutableArray arrayWithCapacity:10];
            for (NSInteger index = 0; index < 10; index++) {
                [contacts addObject:[Example0321Contact contactForIndex:index]];
            }
            _contactBook.contacts = contacts;
            break;
        }
        case Example0321ContactBookTestActionSwitchList1: {
            _contactBook.contacts = @[
                [Example0321Contact contactWithFirstName:@"TEST" lastName:@"A" phone:@"138-0000-0000"],
                [Example0321Contact contactWithFirstName:@"TEST" lastName:@"B" phone:@"138-0000-0000"],
                [Example0321Contact contactWithFirstName:@"TEST" lastName:@"C" phone:@"138-0000-0000"],
                [Example0321Contact contactWithFirstName:@"TEST" lastName:@"D" phone:@"138-0000-0000"],
                [Example0321Contact contactWithFirstName:@"TEST" lastName:@"E" phone:@"138-0000-0000"],
                [Example0321Contact contactWithFirstName:@"TEST" lastName:@"F" phone:@"138-0000-0000"],
            ];
            break;
        }
        case Example0321ContactBookTestActionSwitchList2: { // @"0", @"1", @"2", @"3", @"4", @"F", @"6", @"E", @"8", @"9", @"10", @"11", @"C"
            _contactBook.contacts = @[
                [Example0321Contact contactWithFirstName:@"TEST" lastName:@"0" phone:@"138-0000-0000"],
                [Example0321Contact contactWithFirstName:@"TEST" lastName:@"1" phone:@"138-0000-0000"],
                [Example0321Contact contactWithFirstName:@"TEST" lastName:@"2" phone:@"138-0000-0000"],
                [Example0321Contact contactWithFirstName:@"TEST" lastName:@"3" phone:@"138-0000-0000"],
                [Example0321Contact contactWithFirstName:@"TEST" lastName:@"4" phone:@"138-0000-0000"],
                [Example0321Contact contactWithFirstName:@"TEST" lastName:@"F" phone:@"138-0000-0000"],
                [Example0321Contact contactWithFirstName:@"TEST" lastName:@"6" phone:@"138-0000-0000"],
                [Example0321Contact contactWithFirstName:@"TEST" lastName:@"E" phone:@"138-0000-0000"],
                [Example0321Contact contactWithFirstName:@"TEST" lastName:@"8" phone:@"138-0000-0000"],
                [Example0321Contact contactWithFirstName:@"TEST" lastName:@"9" phone:@"138-0000-0000"],
                [Example0321Contact contactWithFirstName:@"TEST" lastName:@"10" phone:@"138-0000-0000"],
                [Example0321Contact contactWithFirstName:@"TEST" lastName:@"11" phone:@"138-0000-0000"],
                [Example0321Contact contactWithFirstName:@"TEST" lastName:@"C" phone:@"138-0000-0000"],
            ];
            break;
        }
        case Example0321ContactBookTestActionSortByNameAsc: {
            _contactBook.contacts = [_contactBook.contacts sortedArrayUsingComparator:^NSComparisonResult(Example0321Contact *obj1, Example0321Contact *obj2) {
                return [obj1.firstName compare:obj2.firstName];
            }];
            break;
        }
        case Example0321ContactBookTestActionSortByNameDesc: {
            _contactBook.contacts = [_contactBook.contacts sortedArrayUsingComparator:^NSComparisonResult(Example0321Contact *obj1, Example0321Contact *obj2) {
                return [obj1.firstName compare:obj2.firstName] * -1;
            }];
            break;
        }
        case Example0321ContactBookTestActionSortByPhoneAsc: {
            _contactBook.contacts = [_contactBook.contacts sortedArrayUsingComparator:^NSComparisonResult(Example0321Contact *obj1, Example0321Contact *obj2) {
                return [obj1.phone compare:obj2.phone];
            }];
            break;
        }
        case Example0321ContactBookTestActionSortByPhoneDesc: {
            _contactBook.contacts = [_contactBook.contacts sortedArrayUsingComparator:^NSComparisonResult(Example0321Contact *obj1, Example0321Contact *obj2) {
                return [obj1.phone compare:obj2.phone] * -1;
            }];
            break;
        }
        case Example0321ContactBookTestActionInsertAtFirst: {
            Example0321Contact *contact = [Example0321Contact contactForIndex:_contactBook.contacts.count];
            if (contact == nil) {
                return;
            }
            
            NSMutableArray *contacts = [NSMutableArray arrayWithCapacity:_contactBook.contacts.count + 1];
            [contacts addObject:contact];
            [contacts addObjectsFromArray:_contactBook.contacts];
            
            _contactBook.contacts = contacts;
            break;
        }
        case Example0321ContactBookTestActionInsertAtMiddle: {
            Example0321Contact *contact = [Example0321Contact contactForIndex:_contactBook.contacts.count];
            if (contact == nil) {
                return;
            }
            
            NSMutableArray *contacts = [NSMutableArray arrayWithCapacity:_contactBook.contacts.count + 1];
            [contacts addObjectsFromArray:_contactBook.contacts];
            
            if (_contactBook.contacts.count >= 2) {
                NSUInteger index = (NSUInteger)arc4random_uniform((uint32_t)_contactBook.contacts.count - 2) + 1;
                [contacts insertObject:contact atIndex:index];
            } else {
                [contacts addObject:contact];
            }
            
            _contactBook.contacts = contacts;
            break;
        }
        case Example0321ContactBookTestActionInsertAtLast: {
            Example0321Contact *contact = [Example0321Contact contactForIndex:_contactBook.contacts.count];
            if (contact == nil) {
                return;
            }
            
            NSMutableArray *contacts = [NSMutableArray arrayWithCapacity:_contactBook.contacts.count + 1];
            [contacts addObjectsFromArray:_contactBook.contacts];
            [contacts addObject:contact];
            
            _contactBook.contacts = contacts;
            break;
        }
        case Example0321ContactBookTestActionDeleteFirst: {
            if (_contactBook.contacts.count == 0) {
                return;
            }
            NSRange range = NSMakeRange(1, _contactBook.contacts.count -1);
            _contactBook.contacts = [_contactBook.contacts subarrayWithRange:range];
            break;
        }
        case Example0321ContactBookTestActionDeleteLast:
            if (_contactBook.contacts.count == 0) {
                return;
            }
            NSRange range = NSMakeRange(0, _contactBook.contacts.count -1);
            _contactBook.contacts = [_contactBook.contacts subarrayWithRange:range];
            break;
        case Example0321ContactBookTestActionDeleteRandom: {
            if (_contactBook.contacts.count == 0) {
                return;
            }
            NSMutableArray *contacts = _contactBook.contacts.mutableCopy;
            NSUInteger index = (NSUInteger)arc4random_uniform((uint32_t)_contactBook.contacts.count - 2) + 1;
            [contacts removeObjectAtIndex:index];
            _contactBook.contacts = contacts;
            break;
        }
        case Example0321ContactBookTestActionDeleteAll: {
            _contactBook.contacts = @[];
            break;
        }
        default:
            break;
    }
}
@end
