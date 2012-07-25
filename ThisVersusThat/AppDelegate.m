//
//  VLMAppDelegate.m
//  ThisVersusThat
//
//  Created by David Lu on 7/17/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "AppDelegate.h"
#import "VLMConstants.h"
#import "VLMMainViewController.h"

@implementation AppDelegate

@synthesize window=_window;
@synthesize mainViewController;

#pragma mark -
#pragma mark Setup

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // ****************************************************************************
    // Uncomment and fill in with your Parse credentials:
    [Parse setApplicationId:PARSE_APP_ID clientKey:PARSE_CLIENT_KEY];
    
    // If you are using Facebook, uncomment and fill in with your Facebook App Id:
    [PFFacebookUtils initializeWithApplicationId:FACEBOOK_APP_ID];
    // ****************************************************************************
    
    //[PFUser enableAutomaticUser];
    PFACL *defaultACL = [PFACL ACL];

    // Optionally enable public read access by default.
    [defaultACL setPublicReadAccess:YES];
    //[PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    // Override point for customization after application launch.
    if ([PFUser currentUser]){
        [PFUser logOut];
    }
    
    
    [self establishAppearanceDefaults];
       
	// Configure and display the window.
    [self.window setBackgroundColor: WINDOW_BGCOLOR];
    
    VLMMainViewController *mvc = [[VLMMainViewController alloc] init];
    [self.window addSubview:mvc.view];
    [self setMainViewController:mvc];

    [[UIApplication sharedApplication] setStatusBarHidden:NO];

    //self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    /*
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
                                                    UIRemoteNotificationTypeAlert|
                                                    UIRemoteNotificationTypeSound];
    */
    return YES;
}

#pragma mark - 
#pragma mark appearance

- (void)establishAppearanceDefaults{
    // appearance api
    UIImage * custombgd = [UIImage imageNamed:@"customheaderbackground.png"];
    [[UINavigationBar appearance] setBackgroundImage:custombgd forBarMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithWhite:0.2f alpha:1.0f], UITextAttributeTextColor, 
      [UIColor clearColor], UITextAttributeTextShadowColor, 
      [UIFont fontWithName:NAVIGATION_HEADER size:14.0f], UITextAttributeFont, 
      nil
      ]
     ];
    
    [[UIBarButtonItem appearance] setBackgroundImage:custombgd 
                                            forState:UIControlStateNormal
                                          barMetrics:UIBarMetricsDefault]; 
    [[UIBarButtonItem appearance] setBackgroundImage:custombgd 
                                            forState:UIControlStateSelected
                                          barMetrics:UIBarMetricsDefault]; 
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithWhite:0.2f alpha:1.0f], UITextAttributeTextColor, 
      [UIColor clearColor], UITextAttributeTextShadowColor, 
      nil
      ]
                                                forState:UIControlStateNormal
     ];

}

#pragma mark -
#pragma mark Facebook

///////////////////////////////////////////////////////////
// Uncomment these two methods if you are using Facebook
///////////////////////////////////////////////////////////
 
// Pre 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [PFFacebookUtils handleOpenURL:url];
}
 
// For 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
} 
 

#pragma mark -
#pragma mark Boilerplate

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    [PFPush storeDeviceToken:newDeviceToken];
    [PFPush subscribeToChannelInBackground:@"" target:self selector:@selector(subscribeFinished:error:)];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
	NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
	if ([error code] != 3010) // 3010 is for the iPhone Simulator
    {
        // show some alert or otherwise handle the failure to register.
	}
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark -
#pragma mark Parse Notifications

- (void)subscribeFinished:(NSNumber *)result error:(NSError *)error {
    if ([result boolValue]) {
        NSLog(@"ParseStarterProject successfully subscribed to push notifications on the broadcast channel.");
    } else {
        NSLog(@"ParseStarterProject failed to subscribe to push notifications on the broadcast channel.");
    }
}


@end
