//
//  Example05BenchmarkViewController.m
//  Example
//
//  Created by 徐臻 on 2025/2/27.
//

#import "Example05BenchmarkViewController.h"
#import "Example05Model.h"
@import XZJSON;
@import YYModel;
@import XZToast;
@import XZExtensions;

@interface Example05BenchmarkViewController ()
@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@property (nonatomic, weak) IBOutlet UIButton *markButton;
@property (nonatomic, weak) IBOutlet UIButton *timeButton;
@end

@implementation Example05BenchmarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)markButtonAction:(UIButton *)sender {
    self.markButton.enabled = NO;
    self.timeButton.enabled = NO;
    _textLabel.text = [NSString stringWithFormat:@"Device: %@\n\n", UIDevice.currentDevice.xz_productName];
    
//    [self xz_showToast:[XZToast loadingToast:@"请稍后"] duration:0 offset:CGPointZero completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self benchmarkGithubUser];
        [self benchmarkWeiboStatus];
        
        [self testRobustness];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.markButton.enabled = YES;
            self.timeButton.enabled = YES;
            
            XZLog(@"%@", self.textLabel.text);
        });
    });
}

- (IBAction)timeButtonAction:(UIButton *)sender {
    self.markButton.enabled = NO;
    self.timeButton.enabled = NO;
    _textLabel.text = @"请打开 Instruments Time Profiler 分析耗时操作！\n\n为避免干扰，本操作没有 Toast 提示。";
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Example05User" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    int count = 10000;
    void (^yyTest)(void) = ^{
        NSMutableArray *holder = [NSMutableArray arrayWithCapacity:count * 2];
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                Example05YYGHUser *user = [Example05YYGHUser yy_modelWithJSON:json];
                [holder addObject:user];
                
                // YYModel
                NSDictionary *json = [user yy_modelToJSONObject];
                [holder addObject:json];
            }
        }
    };
    
    void (^xzTest)(void) = ^{
        NSMutableArray *holder = [NSMutableArray arrayWithCapacity:count * 2];
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                Example05XZGHUser *user = [XZJSON decode:json options:kNilOptions class:[Example05XZGHUser class]];
                [holder addObject:user];
                
                NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:64];
                [XZJSON model:user encodeIntoDictionary:json];
                [holder addObject:json];
            }
        }
    };
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        yyTest();
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            xzTest();
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.markButton.enabled = YES;
                self.timeButton.enabled = YES;
            });
        });
    });
}

- (void)addText:(NSString *)text {
    _textLabel.text = [_textLabel.text stringByAppendingString:text];
}

- (void)benchmarkGithubUser {
    [self addText:@"----------------------\n"];
    [self addText:@"Benchmark (10000 times):\n"];
    [self addText:@"GHUser             from json    to json    archive\n"];

    /// get json data
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Example05User" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    /// Benchmark
    int count = 10000;
    NSTimeInterval begin, end;
    
    /// warm up (NSDictionary's hot cache, and JSON to model framework cache)
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            // YYModel
            [Example05YYGHUser yy_modelWithJSON:json];
            
            // XZJSON
            [XZJSON decode:json options:kNilOptions class:[Example05XZGHUser class]];
        }
    }
    /// warm up holder
    NSMutableArray *holder = [NSMutableArray new];
    for (int i = 0; i < 1800; i++) {
        [holder addObject:[NSDate new]];
    }
    [holder removeAllObjects];
    
    [self xz_hideToast:nil];
    
    /*------------------- JSON Serialization -------------------*/
    {
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                [holder addObject:json];
            }
        }
        end = CACurrentMediaTime();
        [self addText:[NSString stringWithFormat:@"JSON(*):            %8.2f   ", (end - begin) * 1000]];
        
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                NSData *data = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:nil];
                [holder addObject:data];
            }
        }
        end = CACurrentMediaTime();
        [self addText:[NSString stringWithFormat:@"%8.2f   \n", (end - begin) * 1000]];
    }
    
    /*------------------- YYModel -------------------*/
    {
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                Example05YYGHUser *user = [Example05YYGHUser yy_modelWithJSON:json];
                [holder addObject:user];
            }
        }
        end = CACurrentMediaTime();
        [self addText:[NSString stringWithFormat:@"YYModel(#):         %8.2f   ", (end - begin) * 1000]];
        
        
        Example05YYGHUser *user = [Example05YYGHUser yy_modelWithJSON:json];
        if (user.userID == 0) NSLog(@"error!");
        if (!user.login) NSLog(@"error!");
        if (!user.htmlURL) NSLog(@"error");
        
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                NSDictionary *json = [user yy_modelToJSONObject];
                [holder addObject:json];
            }
        }
        end = CACurrentMediaTime();
        if ([NSJSONSerialization isValidJSONObject:[user yy_modelToJSONObject]]) {
            [self addText:[NSString stringWithFormat:@"%8.2f   ", (end - begin) * 1000]];
        } else {
            [self addText:@"   error   "];
        }
        
        
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:user requiringSecureCoding:NO error:nil];
                [holder addObject:data];
            }
        }
        end = CACurrentMediaTime();
        [self addText:[NSString stringWithFormat:@"%8.2f\n", (end - begin) * 1000]];
    }

    /*------------------- XZJSON -------------------*/
    {
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                Example05XZGHUser *user = [XZJSON decode:json options:kNilOptions class:[Example05XZGHUser class]];
                [holder addObject:user];
            }
        }
        end = CACurrentMediaTime();
        [self addText:[NSString stringWithFormat:@"XZJSON(#):          %8.2f   ", (end - begin) * 1000]];
        
        
        Example05XZGHUser *user = [XZJSON decode:json options:kNilOptions class:[Example05XZGHUser class]];
        if (user.userID == 0) NSLog(@"error!");
        if (!user.login) NSLog(@"error!");
        if (!user.htmlURL) NSLog(@"error");
        
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:64];
                [XZJSON model:user encodeIntoDictionary:json];
                [holder addObject:json];
            }
        }
        end = CACurrentMediaTime();
        
        NSMutableDictionary *json = [NSMutableDictionary dictionary];
        [XZJSON model:user encodeIntoDictionary:json];
        if ([NSJSONSerialization isValidJSONObject:json]) {
            [self addText:[NSString stringWithFormat:@"%8.2f   ", (end - begin) * 1000]];
        } else {
            [self addText:@"   error   "];
        }
        
        
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:user requiringSecureCoding:NO error:nil];
                [holder addObject:data];
            }
        }
        end = CACurrentMediaTime();
        [self addText:[NSString stringWithFormat:@"%8.2f\n", (end - begin) * 1000]];
    }
    
    [self addText:@"----------------------\n"];
    [self addText:@"\n"];
}

- (void)benchmarkWeiboStatus {
    [self addText:@"----------------------\n"];
    [self addText:@"Benchmark (1000 times):\n"];
    [self addText:@"WeiboStatus     from json    to json    archive\n"];

    /// get json data
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Example05Weibo" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    /// Benchmark
    int count = 1000;
    NSTimeInterval begin, end;
    
    /// warm up (NSDictionary's hot cache, and JSON to model framework cache)
    @autoreleasepool {
        for (int i = 0; i < count * 2; i++) {
            // YYModel
            [Example05YYWeiboStatus yy_modelWithJSON:json];
        
            // XZJSON
            [XZJSON decode:json options:kNilOptions class:[Example05XZWeiboStatus class]];
        }
    }
    
    /// warm up holder
    NSMutableArray *holder = [NSMutableArray new];
    for (int i = 0; i < count; i++) {
        [holder addObject:[NSData new]];
    }
    [holder removeAllObjects];
    
    
    /*------------------- YYModel -------------------*/
    {
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                Example05YYWeiboStatus *feed = [Example05YYWeiboStatus yy_modelWithJSON:json];
                [holder addObject:feed];
            }
        }
        end = CACurrentMediaTime();
        [self addText:[NSString stringWithFormat:@"YYModel:         %8.2f   ", (end - begin) * 1000]];

        
        Example05YYWeiboStatus *feed = [Example05YYWeiboStatus yy_modelWithJSON:json];
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                NSDictionary *json = [feed yy_modelToJSONObject];
                [holder addObject:json];
            }
        }
        end = CACurrentMediaTime();
        if ([NSJSONSerialization isValidJSONObject:[feed yy_modelToJSONObject]]) {
            [self addText:[NSString stringWithFormat:@"%8.2f   ", (end - begin) * 1000]];
        } else {
            [self addText:@"   error   "];
        }
        
        
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:feed requiringSecureCoding:NO error:nil];
                [holder addObject:data];
            }
        }
        end = CACurrentMediaTime();
        [self addText:[NSString stringWithFormat:@"%8.2f\n", (end - begin) * 1000]];
    }

    /*------------------- XZJSON -------------------*/
    {
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                Example05XZWeiboStatus *feed = [XZJSON decode:json options:kNilOptions class:[Example05XZWeiboStatus class]];
                [holder addObject:feed];
            }
        }
        end = CACurrentMediaTime();
        [self addText:[NSString stringWithFormat:@"XZJSON:          %8.2f   ", (end - begin) * 1000]];

        
        Example05XZWeiboStatus *feed = [XZJSON decode:json options:kNilOptions class:[Example05XZWeiboStatus class]];
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                NSMutableDictionary *json = [NSMutableDictionary dictionary];
                [XZJSON model:feed encodeIntoDictionary:json];
                [holder addObject:json];
            }
        }
        end = CACurrentMediaTime();
        
        NSMutableDictionary *json = [NSMutableDictionary dictionary];
        [XZJSON model:feed encodeIntoDictionary:json];
        if ([NSJSONSerialization isValidJSONObject:json]) {
            [self addText:[NSString stringWithFormat:@"%8.2f   ", (end - begin) * 1000]];
        } else {
            [self addText:@"   error   "];
        }
        
        
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:feed requiringSecureCoding:NO error:nil];
                [holder addObject:data];
            }
        }
        end = CACurrentMediaTime();
        [self addText:[NSString stringWithFormat:@"%8.2f\n", (end - begin) * 1000]];
    }
    
    [self addText:@"----------------------\n"];
    [self addText:@"\n"];
}

- (void)testRobustness {
    
    {
        [self addText:@"----------------------\n"];
        [self addText:@"The property is NSString, but the json value is number:\n"];
        NSString *jsonStr = @"{\"type\":1}";
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        
        void (^logError)(NSString *model, id user) = ^(NSString *model, id user){
            [self addText:[NSString stringWithFormat:@"%s ",model.UTF8String]];
            if (!user) {
                [self addText:@"⚠️ model is nil\n"];
            } else {
                NSString *type = ((Example05YYGHUser *)user).type;
                if (type == nil || type == (id)[NSNull null]) {
                    [self addText:@"⚠️ property is nil\n"];
                } else if ([type isKindOfClass:[NSString class]]) {
                    [self addText:[NSString stringWithFormat:@"✅ property is %s\n",NSStringFromClass(type.class).UTF8String]];
                } else {
                    [self addText:[NSString stringWithFormat:@"🚫 property is %s\n",NSStringFromClass(type.class).UTF8String]];
                }
            }
        };
        
        // YYModel
        Example05YYGHUser *yyUser = [Example05YYGHUser yy_modelWithJSON:json];
        logError(@"YYModel:        ", yyUser);
        
        // XZJSON
        Example05XZGHUser *xzUser = [XZJSON decode:json options:kNilOptions class:[Example05XZGHUser class]];
        logError(@"XZJSON:         ", xzUser);
        
        [self addText:@"\n"];
    }
    
    {
        [self addText:@"----------------------\n"];
        [self addText:@"The property is int, but the json value is string:\n"];
        NSString *jsonStr = @"{\"followers\":\"100\"}";
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        
        void (^logError)(NSString *model, id user) = ^(NSString *model, id user){
            [self addText:[NSString stringWithFormat:@"%s ",model.UTF8String]];
            if (!user) {
                [self addText:@"⚠️ model is nil\n"];
            } else {
                UInt32 num = ((Example05YYGHUser *)user).followers;
                if (num != 100) {
                    [self addText:[NSString stringWithFormat:@"🚫 property is %u\n",(unsigned int)num]];
                } else {
                    [self addText:[NSString stringWithFormat:@"✅ property is %u\n",(unsigned int)num]];
                }
            }
        };
        
        // YYModel
        Example05YYGHUser *yyUser = [Example05YYGHUser yy_modelWithJSON:json];
        logError(@"YYModel:        ", yyUser);
        
        // XZJSON
        Example05XZGHUser *xzUser = [XZJSON decode:json options:kNilOptions class:[Example05XZGHUser class]];
        logError(@"XZJSON:         ", xzUser);
    }
    
    
    {
        [self addText:@"----------------------\n"];
        [self addText:@"The property is NSDate, and the json value is string:\n"];
        NSString *jsonStr = @"{\"updated_at\":\"2009-04-02T03:35:22Z\"}";
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        
        void (^logError)(NSString *model, id user) = ^(NSString *model, id user){
            [self addText:[NSString stringWithFormat:@"%s ",model.UTF8String]];
            if (!user) {
                [self addText:@"⚠️ model is nil\n"];
            } else {
                NSDate *date = ((Example05YYGHUser *)user).updatedAt;
                if (date == nil || date == (id)[NSNull null]) {
                    [self addText:@"⚠️ property is nil\n"];
                } else if ([date isKindOfClass:[NSDate class]]) {
                    [self addText:[NSString stringWithFormat:@"✅ property is %s\n",NSStringFromClass(date.class).UTF8String]];
                } else {
                    [self addText:[NSString stringWithFormat:@"🚫 property is %s\n",NSStringFromClass(date.class).UTF8String]];
                }
            }
        };
        
        // YYModel
        Example05YYGHUser *yyUser = [Example05YYGHUser yy_modelWithJSON:json];
        logError(@"YYModel:        ", yyUser);
        
        // XZJSON
        Example05XZGHUser *xzUser = [XZJSON decode:json options:kNilOptions class:[Example05XZGHUser class]];
        logError(@"XZJSON:         ", xzUser);
        [self addText:@"\n"];
    }
    
    
    {
        [self addText:@"----------------------\n"];
        [self addText:@"The property is NSValue, and the json value is string:\n"];
        NSString *jsonStr = @"{\"test\":\"https://github.com\"}";
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        
        void (^logError)(NSString *model, id user) = ^(NSString *model, id user){
            [self addText:[NSString stringWithFormat:@"%s ",model.UTF8String]];
            if (!user) {
                [self addText:@"⚠️ model is nil\n"];
            } else {
                NSValue *valur = ((Example05YYGHUser *)user).test;
                if (valur == nil || valur == (id)[NSNull null]) {
                    [self addText:@"✅ property is nil\n"];
                } else if ([valur isKindOfClass:[NSURLRequest class]]) {
                    [self addText:[NSString stringWithFormat:@"✅ property is %s\n",NSStringFromClass(valur.class).UTF8String]];
                } else {
                    [self addText:[NSString stringWithFormat:@"🚫 property is %s\n",NSStringFromClass(valur.class).UTF8String]];
                }
            }
        };
        // YYModel
        Example05YYGHUser *yyUser = [Example05YYGHUser yy_modelWithJSON:json];
        logError(@"YYModel:        ", yyUser);
        
        // XZJSON
        Example05XZGHUser *xzUser = [XZJSON decode:json options:kNilOptions class:[Example05XZGHUser class]];
        logError(@"XZJSON:         ", xzUser);
        [self addText:@"\n"];
    }
    
}

@end
