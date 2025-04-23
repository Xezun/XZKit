//
//  ExampleAppDelegate.m
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import "ExampleAppDelegate.h"
@import XZLocale;
@import XZDefines;

union Foo {
    
};

struct Bar {
    
};

@interface ExampleAppDelegate ()

@end

@implementation ExampleAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didChangeAppLanguage) name:XZLanguagePreferencesDidChangeNotification object:nil];
    NSLog(@"%s %s %ld %ld %ld %ld", @encode(union Foo), @encode(struct Bar), sizeof(union Foo), sizeof(struct Bar), _Alignof(union Foo), _Alignof(struct Bar));
    return YES;
}

- (void)didChangeAppLanguage {
    UIWindow *window = _window;
    
    CGRect const bounds = UIScreen.mainScreen.bounds;
    
    _window = [[UIWindow alloc] initWithFrame:bounds];
    _window.backgroundColor = UIColor.whiteColor;
    UIViewController *rootVC = [UIStoryboard storyboardWithName:@"Main" bundle:nil].instantiateInitialViewController;
    _window.rootViewController = rootVC;
    [_window makeKeyAndVisible];
    
    _window.layer.shadowColor = UIColor.blackColor.CGColor;
    _window.layer.shadowOpacity = 0.5;
    _window.layer.shadowRadius = 5.0;
    _window.windowLevel = window.windowLevel + 1;
    _window.frame = CGRectOffset(bounds, bounds.size.height, 0);
    
    [UIView animateWithDuration:0.5 animations:^{
        self->_window.frame = bounds;
    } completion:^(BOOL finished) {
        window.hidden = YES;
        self->_window.layer.shadowColor = nil;
    }];
}

@end
