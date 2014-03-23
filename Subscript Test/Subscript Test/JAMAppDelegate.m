//
//  JAMAppDelegate.m
//  Subscript Test
//
//  Created by Jerry Mayers on 3/23/14.
//  Copyright (c) 2014 Jerry Andrew Mayers. All rights reserved.
//

#import "JAMAppDelegate.h"

#import "JAMMainViewController.h"

@implementation JAMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window setRootViewController:[JAMMainViewController new]];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
