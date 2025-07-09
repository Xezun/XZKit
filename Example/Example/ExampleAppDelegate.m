//
//  ExampleAppDelegate.m
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import "ExampleAppDelegate.h"
@import XZLog;
@import XZLocale;
@import OSLog;

@interface ExampleAppDelegate ()

@end

@implementation ExampleAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    XZLog(@"App (%@) was launched: %@", XZLogSystem.defaultLogSystem.domain, launchOptions);
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didChangeAppLanguage) name:XZLanguagePreferencesDidChangeNotification object:nil];
    return YES;
}

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
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
