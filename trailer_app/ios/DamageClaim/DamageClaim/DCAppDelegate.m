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
    
//    NSMutableSet *set1, *set2;
//    set1 = [NSMutableSet setWithObjects:@"1", @"2", @"3", nil];
//    set2 = [NSMutableSet setWithObjects:@"2", @"3", @"4", nil];
//    for (NSString *s in set1) {
//        [set2 addObject:s];
//    }
//    
//    
//#if kDebug
//    NSLog(@"%@", set2);
//#endif
  
//    NSMutableArray *array = [NSMutableArray arrayWithObjects:[NSMutableArray arrayWithObjects:@"1", @"2", @"3", nil], [NSMutableArray arrayWithObjects:@"4", @"5", @"6",nil], nil];
//    
//    NSMutableArray *array2 = [array objectAtIndex:1];
//    [array2 replaceObjectAtIndex:1 withObject:@"10"];
//    
//#if kDebug
//    NSLog(@"%@", [array description]);
//#endif
    
    
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    //self.viewController = [[[DCViewController alloc] initWithNibName:@"DCViewController" bundle:nil] autorelease];
    
    
    DCSurveyViewController *surveyViewController = [[[DCSurveyViewController alloc] initWithNibName:@"SurveyView" bundle:nil] autorelease];
    self.navigationController = [[[UINavigationController alloc] initWithRootViewController:surveyViewController] autorelease];
    
//    DCDamageViewController *d = [[[DCDamageViewController alloc] initWithNibName:@"DamageView" bundle:nil] autorelease];
//    self.navigationController = [[[UINavigationController alloc] initWithRootViewController:d] autorelease];
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
    // Display text
    UIAlertView *alertView;
    NSString *text = [[url host] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    alertView = [[UIAlertView alloc] initWithTitle:@"Text" message:text delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
