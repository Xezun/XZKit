//
//  main.m
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import <UIKit/UIKit.h>
#import "ExampleAppDelegate.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([ExampleAppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
