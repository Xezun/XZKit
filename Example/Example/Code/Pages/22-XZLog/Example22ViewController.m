//
//  Example22ViewController.m
//  Example
//
//  Created by Xezun on 2026/5/1.
//

#import "Example22ViewController.h"
@import XZKit;

@interface Example22Cell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@end

@interface Example22ViewController () <UICollectionViewDelegateFlowLayout>

@end

@implementation Example22ViewController {
    NSArray<NSArray<NSDictionary<NSString *, id> *> *> *_dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [self makeValues];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat const width = floor((self.view.bounds.size.width - 2.0 * 8) / 7.0);
    UICollectionViewFlowLayout *flowLayout = (id)self.collectionViewLayout;
    flowLayout.itemSize = CGSizeMake(width, 60.0);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _dataArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArray[section].count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = _dataArray[indexPath.section][indexPath.item];
    Example22Cell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:dict[@"identifier"] forIndexPath:indexPath];
    cell.textLabel.text = dict[@"value"];
    return cell;
}

- (NSArray *)makeValues {
    NSMutableArray *sectionsM = [NSMutableArray arrayWithCapacity:5];
    
    NSMutableArray *blueValues = [NSMutableArray arrayWithCapacity:5];
    NSArray *blockedBlueValues = @[@"05", @"06", @"10", @"11", @"16"];
    for (NSInteger i = 0; i < 5; i++) {
        NSString *blueValue = nil;
        do {
            blueValue = [NSString stringWithFormat:@"%02ld", (long)(arc4random_uniform(16) + 1)];
        } while ([blueValues containsObject:blueValue] || [blockedBlueValues containsObject:blueValue]);
        [blueValues addObject:blueValue];
        
        NSMutableArray *redValues = [NSMutableArray arrayWithCapacity:6];
        do {
            NSString *value = [NSString stringWithFormat:@"%02ld", (long)(arc4random_uniform(33) + 1)];
            if ([redValues containsObject:value]) {
                continue;
            }
            [redValues addObject:value];
        } while (redValues.count < 6);
        [redValues sortUsingSelector:@selector(compare:)];
        
        NSMutableArray *cellsM = [NSMutableArray arrayWithCapacity:7];
        for (NSString *redValue in redValues) {
            [cellsM addObject:@{
                @"identifier": @"red",
                @"value": redValue
            }];
        }
        [cellsM addObject:@{
            @"identifier": @"blue",
            @"value": blueValue
        }];
        
        [sectionsM addObject:cellsM];
    }
    
    return sectionsM.copy;
}

- (IBAction)buttonAction:(id)sender {
    _dataArray = [self makeValues];
    [self.collectionView reloadData];
}

- (void)exampleXZLog {
    NSString *string = nil;
    
    string = [@"" stringByPaddingToLength:500 withString:@"1234567890" startingAtIndex:0];
    XZLog(@"单行字符数：%lu", string.length);
    XZLog(@"%@", string);
    
    string = [@"" stringByPaddingToLength:999 withString:@"1234567890" startingAtIndex:0];
    XZLog(@"单行字符数：%lu", string.length);
    XZLog(@"%@", string);
    
    string = [@"" stringByPaddingToLength:1000 withString:@"1234567890" startingAtIndex:0];
    XZLog(@"单行字符数：%lu", string.length);
    XZLog(@"%@", string);
    
    string = [@"" stringByPaddingToLength:1001 withString:@"1234567890" startingAtIndex:0];
    XZLog(@"单行字符数：%lu", string.length);
    XZLog(@"%@", string);
    
    string = [@"" stringByPaddingToLength:1016 withString:@"1234567890" startingAtIndex:0];
    XZLog(@"单行字符数：%lu", string.length);
    XZLog(@"%@", string);
    
    string = [@"" stringByPaddingToLength:1017 withString:@"1234567890" startingAtIndex:0];
    XZLog(@"单行字符数：%lu", string.length);
    XZLog(@"%@", string);
    
    string = [@"" stringByPaddingToLength:1018 withString:@"1234567890" startingAtIndex:0];
    XZLog(@"单行字符数：%lu", string.length);
    XZLog(@"%@", string);
    
    string = [NSString stringWithFormat:@"%@\n%@",
              [@"" stringByPaddingToLength:998 withString:@"1234567890" startingAtIndex:0],
              [@"" stringByPaddingToLength:1000 withString:@"1234567890" startingAtIndex:0]
    ];
    XZLog(@"多行字符数：%lu", string.length);
    XZLog(@"%@", string);
    
    string = [NSString stringWithFormat:@"%@\n%@",
              [@"" stringByPaddingToLength:999 withString:@"1234567890" startingAtIndex:0],
              [@"" stringByPaddingToLength:1000 withString:@"1234567890" startingAtIndex:0]
    ];
    XZLog(@"多行字符数：%lu", string.length);
    XZLog(@"%@", string);
    
    string = [NSString stringWithFormat:@"%@\n%@",
              [@"" stringByPaddingToLength:1000 withString:@"1234567890" startingAtIndex:0],
              [@"" stringByPaddingToLength:1000 withString:@"1234567890" startingAtIndex:0]
    ];
    XZLog(@"多行字符数：%lu", string.length);
    XZLog(@"%@", string);
    
    string = [NSString stringWithFormat:@"%@\n%@",
              [@"" stringByPaddingToLength:1001 withString:@"1234567890" startingAtIndex:0],
              [@"" stringByPaddingToLength:1000 withString:@"1234567890" startingAtIndex:0]
    ];
    XZLog(@"多行字符数：%lu", string.length);
    XZLog(@"%@", string);
    
    string = [NSString stringWithFormat:@"%@\n%@",
              [@"" stringByPaddingToLength:1002 withString:@"1234567890" startingAtIndex:0],
              [@"" stringByPaddingToLength:1000 withString:@"1234567890" startingAtIndex:0]
    ];
    XZLog(@"多行字符数：%lu", string.length);
    XZLog(@"%@", string);
}

@end

@implementation Example22Cell

@end
