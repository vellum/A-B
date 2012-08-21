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
#import "MBProgressHUD.h"
#import "VLMCache.h"
#import "Reachability.h"

@interface AppDelegate()
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) MBProgressHUD *hudp;
@property (nonatomic, strong) UIView *hudlayer;

@property (nonatomic, readonly) int networkStatus;
@property (nonatomic, strong) Reachability *hostReach;
@property (nonatomic, strong) Reachability *internetReach;
@property (nonatomic, strong) Reachability *wifiReach;

@end

@implementation AppDelegate

@synthesize window=_window;
@synthesize mainViewController;
@synthesize hud;
@synthesize hudp;
@synthesize hudlayer;

@synthesize networkStatus;
@synthesize hostReach;
@synthesize internetReach;
@synthesize wifiReach;

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
    /*
    if ([PFUser currentUser]){
        
        // clear cache
        [[VLMCache sharedCache] clear];

        // remove cached profile image
        NSURL *cachesDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject]; // iOS Caches directory
        NSURL *profilePictureCacheURL = [cachesDirectoryURL URLByAppendingPathComponent:@"FacebookProfilePicture.jpg"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:[profilePictureCacheURL path]]) {
            [[NSFileManager defaultManager] removeItemAtPath:[profilePictureCacheURL path] error:nil];
        }
        
        // Log out
        [PFUser logOut];
    }
    //*/
    
    [self establishAppearanceDefaults];
       
	// Configure and display the window.
    [self.window setBackgroundColor: WINDOW_BGCOLOR];
    
    VLMMainViewController *mvc = [[VLMMainViewController alloc] init];
    [self.window addSubview:mvc.view];
    [self setMainViewController:mvc];
    
    UIView *layer = [[UIView alloc] initWithFrame:self.window.frame];
    [layer setBackgroundColor:[UIColor clearColor]];
    //[layer setBackgroundColor:[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.5f]];
    [layer setUserInteractionEnabled:NO];
    [self.window addSubview:layer];
    self.hudlayer = layer;
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

    //self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    /*
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
                                                    UIRemoteNotificationTypeAlert|
                                                    UIRemoteNotificationTypeSound];
    */
    
    //[self showHUD:@"test"];

    // Use Reachability to monitor connectivity
    [self monitorReachability];

    return YES;
}

#pragma mark - 
#pragma mark appearance

- (void)establishAppearanceDefaults{

    // background images
    UIImage *custombgd = NAVIGATION_HEADER_BACKGROUND_IMAGE;
    UIImage *clear = [[UIImage imageNamed:@"clear.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    // set navbar background
    [[UINavigationBar appearance] setBackgroundImage:custombgd forBarMetrics:UIBarMetricsDefault];
 
    // set navbar typography
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                        [UIColor colorWithWhite:0.2f alpha:1.0f], UITextAttributeTextColor, 
                        [UIColor clearColor], UITextAttributeTextShadowColor, 
                        [UIFont fontWithName:NAVIGATION_HEADER size:NAVIGATION_HEADER_TITLE_SIZE], UITextAttributeFont, 
                        nil
                        ]];

    
    // bar button item background
    [[UIBarButtonItem appearance] setBackgroundImage:clear forState:UIControlStateNormal barMetrics:UIBarMetricsDefault]; 
    [[UIBarButtonItem appearance] setBackgroundImage:clear forState:UIControlStateSelected barMetrics:UIBarMetricsDefault]; 
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:clear forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    
    // set plain bar button item typography
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor clearColor], UITextAttributeTextShadowColor,
                                                          [UIColor colorWithWhite:0.2f alpha:1.0f], UITextAttributeTextColor, 
                                                          [UIFont fontWithName:@"AmericanTypewriter" size:13.0f], UITextAttributeFont, 
                                                          nil] // end dictionary
                                                forState:UIControlStateNormal
     ];
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor clearColor], UITextAttributeTextShadowColor,
                                                          [UIColor colorWithWhite:1.0f alpha:1.0f], UITextAttributeTextColor, 
                                                          [UIFont fontWithName:@"AmericanTypewriter" size:13.0f], UITextAttributeFont, 
                                                          nil] // end dictionary
                                                forState:UIControlStateHighlighted
     ];
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor clearColor], UITextAttributeTextShadowColor,
                                                          [UIColor colorWithWhite:1.0f alpha:1.0f], UITextAttributeTextColor, 
                                                          [UIFont fontWithName:@"AmericanTypewriter" size:13.0f], UITextAttributeFont, 
                                                          nil] // end dictionary
                                                forState:UIControlStateHighlighted
     ];
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor clearColor], UITextAttributeTextShadowColor,
                                                          [UIColor colorWithWhite:0.2f alpha:0.2f], UITextAttributeTextColor, 
                                                          [UIFont fontWithName:@"AmericanTypewriter" size:13.0f], UITextAttributeFont, 
                                                          nil] // end dictionary
                                                forState:UIControlStateDisabled
     ];
    [[UIBarButtonItem appearance] setTitlePositionAdjustment:UIOffsetMake(0.0f, BAR_BUTTON_ITEM_VERTICAL_OFFSET) forBarMetrics:UIBarMetricsDefault];

    // interestingly, backbutton needs its own adjustment
    [[UIBarButtonItem appearance] setBackButtonBackgroundVerticalPositionAdjustment:BAR_BUTTON_ITEM_VERTICAL_OFFSET-1 forBarMetrics:UIBarMetricsDefault];
    
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

#pragma mark - ()

- (void)showHUD:(NSString *)text{
    if ( !self.hud ){

        hud = [MBProgressHUD showHUDAddedTo:hudlayer animated:YES];
        hud.square = YES;

    }   
    
    [hud show:YES];
    [self.hud setLabelText:text];
    [self.hud setDimBackground:YES];
}

- (void)updateHUD:(NSString *)text{
    if ( self.hud ){
        [self.hud setLabelText:text];
    }
}

- (void)hideHUD{
    if ( self.hud ){
        [self.hud hide:YES];
        
        //[mainViewController refreshfeed];
    }
}
- (void)showHUD:(NSString *)text animated:(BOOL)animated{
    if ( !self.hud ){
        
        hud = [MBProgressHUD showHUDAddedTo:hudlayer animated:animated];
        hud.square = YES;
        
    }   
    
    [hud show:animated];
    [self.hud setLabelText:text];
    [self.hud setDimBackground:YES];
}
- (void)showHUDPosting{
    if ( !self.hudp ){
        
        hudp = [MBProgressHUD showHUDAddedTo:hudlayer animated:YES];
        hudp.square = YES;
        
    }   
    
    [hudp show:YES];
    [self.hud setLabelText:@""];
    [self.hud setDimBackground:NO];
}
- (void)hideHUDPosting{
    if ( self.hudp ){
        [self.hudp hide:YES];
        
        [mainViewController refreshfeed];
    }

}

#pragma mark -

- (BOOL)isParseReachable {
    return self.networkStatus != NotReachable;
}
- (void)monitorReachability {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.hostReach = [Reachability reachabilityWithHostname:@"api.parse.com"];//reachabilityWithHostName: @"api.parse.com"];
    [self.hostReach startNotifier];
    
    self.internetReach = [Reachability reachabilityForInternetConnection];
    [self.internetReach startNotifier];
    
    self.wifiReach = [Reachability reachabilityForLocalWiFi];
    [self.wifiReach startNotifier];
}

//Called by Reachability whenever status changes.
- (void)reachabilityChanged:(NSNotification* )note {
    Reachability *curReach = (Reachability *)[note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NSLog(@"Reachability changed: %@", curReach);
    networkStatus = [curReach currentReachabilityStatus];
    
    /*
    if ([self isParseReachable] && [PFUser currentUser] && self.homeViewController.objects.count == 0) {
        // Refresh home timeline on network restoration. Takes care of a freshly installed app that failed to load the main timeline under bad network conditions.
        // In this case, they'd see the empty timeline placeholder and have no way of refreshing the timeline unless they followed someone.
        [self.homeViewController loadObjects];
    }
     */
}

@end
