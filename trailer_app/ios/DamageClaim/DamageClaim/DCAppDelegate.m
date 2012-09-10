//
//  DCAppDelegate.m
//  DamageClaim
//
//  Created by Dev on 13/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DCAppDelegate.h"


#import "DCSurveyViewController.h"

#import "DCDamageDetailViewController.h"

#import "Const.h"

#import "DCSharedObject.h"


@implementation DCAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    
    DCSurveyViewController *surveyViewController = [[[DCSurveyViewController alloc] initWithNibName:@"SurveyView" bundle:nil] autorelease];
    self.navigationController = [[[UINavigationController alloc] initWithRootViewController:surveyViewController] autorelease];
    
#if kTestingAPI
    [[NSUserDefaults standardUserDefaults] setValue:@"cloud3@gizur.com" forKey:USER_NAME];
    [[NSUserDefaults standardUserDefaults] setValue:@"rksh2jjf" forKey:PASSWORD];
    [[NSUserDefaults standardUserDefaults] setValue:@"9b45e67513cb3377b0b18958c4de55be" forKey:GIZURCLOUD_SECRET_KEY];
    [[NSUserDefaults standardUserDefaults] setValue:@"GZCLDFC4B35B" forKey:GIZURCLOUD_API_KEY];
    
#endif
    
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSMutableString *parameterString = [[[url query] mutableCopy] autorelease];
    parameterString = [[[parameterString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] mutableCopy] autorelease];    
    //remove the double quotes
    parameterString = [[parameterString stringByReplacingOccurrencesOfString:@"\"" withString:@""] mutableCopy];
#if kDebug
    NSLog(@"%@", parameterString);
#endif

    NSArray *parameterArray = [[parameterString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] componentsSeparatedByString:@"&"];
    for (NSString *singleParameter in parameterArray) {
        NSArray *parameter = [singleParameter componentsSeparatedByString:@"="];
        if (parameter) {
            if ([parameter count] > 0) {
                if ([[[parameter objectAtIndex:0] lowercaseString] isEqualToString:[GIZURCLOUD_API_KEY lowercaseString]]) {
                    if ([parameter count] > 1) {
#if kDebug
                        NSLog(@"%@", [parameter objectAtIndex:1]);
#endif
                        [[NSUserDefaults standardUserDefaults] setValue:[parameter objectAtIndex:1] forKey:GIZURCLOUD_API_KEY];
                    }
                } else if ([[[parameter objectAtIndex:0] lowercaseString] isEqualToString:[GIZURCLOUD_SECRET_KEY lowercaseString]]) {
                    if ([parameter count] > 1) {
#if kDebug
                        NSLog(@"%@", [parameter objectAtIndex:1]);
#endif
                        [[NSUserDefaults standardUserDefaults] setValue:[parameter objectAtIndex:1] forKey:GIZURCLOUD_SECRET_KEY];
                    }
                }
            }
        }
    }
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
#if kDebug
    NSLog(@"WillResignActive");
#endif
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
#if kDebug
    NSLog(@"DidEnterBackground");
#endif

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
#if kDebug
    NSLog(@"WillEnterForeground");
#endif

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
#if kDebug
    NSLog(@"DidBecomeActive");
#endif

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
