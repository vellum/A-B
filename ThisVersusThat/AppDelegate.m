//
//  VLMAppDelegate.m
//  ThisVersusThat
//
//  Created by David Lu on 7/17/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "JSONKit.h"

#import "AppDelegate.h"
#import "VLMConstants.h"
#import "VLMMainViewController.h"
#import "MBProgressHUD.h"
#import "VLMCache.h"
#import "Reachability.h"
#import "TestFlight.h"
#import "PopoverView.h"
#import "VLMResultCell.h"
#import "VLMMessageCell.h"
#import "VLMSearchViewController.h"

typedef enum {
    kQueryWaiting,
    kQueryFound,
    kQueryTimedOut,
    kQueryDownloadErrror
} VLMQueryResponseState;


@interface AppDelegate()
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) MBProgressHUD *hudp;
@property (nonatomic, strong) UIView *hudlayer;

@property (nonatomic, readonly) int networkStatus;
@property (nonatomic, strong) Reachability *hostReach;
@property (nonatomic, strong) Reachability *internetReach;
@property (nonatomic, strong) Reachability *wifiReach;
@property (nonatomic) BOOL firsttimenetworkchange;
@property (nonatomic) BOOL receivedPushNotificationInBackground;
@property (nonatomic, strong) NSDictionary *lastknownpush;
@property (nonatomic, weak) PopoverView *pop;
@property VLMQueryResponseState responseState;
@property (nonatomic, weak) UITableView *tableview;
@property (nonatomic, strong) NSArray *productresults;
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
@synthesize firsttimenetworkchange;
@synthesize receivedPushNotificationInBackground;

@synthesize pop;
@synthesize responseState;
@synthesize tableview;
@synthesize searchDelegate;

#pragma mark -
#pragma mark Setup

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    responseState = kQueryWaiting;

    firsttimenetworkchange = YES;
    receivedPushNotificationInBackground = NO;
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
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backfieldTapped:)];
    [self.hudlayer addGestureRecognizer:tgr];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

    //self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
                                                    UIRemoteNotificationTypeAlert|
                                                    UIRemoteNotificationTypeSound];
    
    //[self showHUD:@"test"];

    // Use Reachability to monitor connectivity
    [self monitorReachability];
    
    
    // TESTFLIGHT
    // installs HandleExceptions as the Uncaught Exception Handler
    NSSetUncaughtExceptionHandler(&HandleExceptions);
    // create the signal action structure
    struct sigaction newSignalAction;
    // initialize the signal action structure
    memset(&newSignalAction, 0, sizeof(newSignalAction));
    // set SignalHandler as the handler in the signal action structure
    newSignalAction.sa_handler = &SignalHandler;
    // set SignalHandler as the handlers for SIGABRT, SIGILL and SIGBUS
    sigaction(SIGABRT, &newSignalAction, NULL);
    sigaction(SIGILL, &newSignalAction, NULL);
    sigaction(SIGBUS, &newSignalAction, NULL);
    // Call takeOff after install your own unhandled exception and signal handlers
    [TestFlight takeOff:@"9e1e68fa893a729a18ba2c5022acc60b_MTI4NDkwMjAxMi0wOS0wNCAxMzoxMzo0MS44MjYyOTU"];
    
    
    // PUSH
    
    [self handlePush:launchOptions];
    
    return YES;
}

#pragma mark - testflight exception handling
/*
 My Apps Custom uncaught exception catcher, we do special stuff here, and TestFlight takes care of the rest
 **/
void HandleExceptions(NSException *exception) {
    NSLog(@"This is where we save the application data during a exception");
    // Save application data on crash
}
/*
 My Apps Custom signal catcher, we do special stuff here, and TestFlight takes care of the rest
 **/
void SignalHandler(int sig) {
    NSLog(@"This is where we save the application data during a signal");
    // Save application data on crash
}


#pragma mark -
#pragma mark appearance

- (void)establishAppearanceDefaults{

    // background images
    UIImage *custombgd = NAVIGATION_HEADER_BACKGROUND_IMAGE;
    UIImage *clear = [[UIImage imageNamed:@"clear.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    UIImage *clearfixed = [UIImage imageNamed:@"clear.png"];

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

    [[UIBarButtonItem appearance] setBackButtonBackgroundVerticalPositionAdjustment:BAR_BUTTON_ITEM_VERTICAL_OFFSET-1 forBarMetrics:UIBarMetricsDefault];

    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:clearfixed forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    // interestingly, backbutton needs its own adjustment
    
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
    
    [[PFInstallation currentInstallation] addUniqueObject:@"" forKey:kPAPInstallationChannelsKey];
    if ([PFUser currentUser]) {
        // Make sure they are subscribed to their private push channel
        NSString *privateChannelName = [[PFUser currentUser] objectForKey:kPAPUserPrivateChannelKey];
        if (privateChannelName && privateChannelName.length > 0) {
            NSLog(@"Subscribing user to %@", privateChannelName);
            [[PFInstallation currentInstallation] addUniqueObject:privateChannelName forKey:kPAPInstallationChannelsKey];
        }
    }
    [[PFInstallation currentInstallation] saveEventually];}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
	NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
	if ([error code] != 3010) // 3010 is for the iPhone Simulator
    {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"Application failed to register for push notifications: %@", error);
	}
}

// TODO: handle push notifications in app
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

    
    if ( [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive ){
        [PFPush handlePush:userInfo];
    } else {
        [self handlePush:userInfo];
        self.receivedPushNotificationInBackground = YES;
    }
    

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
    if (receivedPushNotificationInBackground) {
        receivedPushNotificationInBackground = NO;
        [mainViewController performSelector:@selector(showLeftPanel) withObject:nil afterDelay:1.0f];
        
    }
    //[mainViewController showLeftPanel];
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
    [self.hud setDimBackground:NO];
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
    [self.hud setDimBackground:NO];
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
        
        //[mainViewController refreshfeed];
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
    
    BOOL wasParseReachable = [self isParseReachable];
    
    Reachability *curReach = (Reachability *)[note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NSLog(@"Reachability changed: %@", curReach);
    networkStatus = [curReach currentReachabilityStatus];
    
    if (self.firsttimenetworkchange){
        self.firsttimenetworkchange = NO;
        if (![self isParseReachable]) {
            [self showConnectionChangedHUD:@"Cannot connect to network"];
        }
        return;
    }
    
    if ([self isParseReachable] == wasParseReachable) {
        //return;
    }

    if ([self isParseReachable]){
        //[self showConnectionChangedHUD:@"Connection Returned"];
        [mainViewController refreshfeed];
    } else {
        [self showConnectionChangedHUD:@"Connection Lost"];
    }

    
    /*
    UIViewController *currentViewContoller = mainViewController.navigationController.visibleViewController;
    if ( !currentViewContoller ){
        currentViewContoller = mainViewController;
    } 
    PFQueryTableViewController *qtvc = nil;
    if ( [currentViewContoller isMemberOfClass:NSClassFromString(@"PFQueryTableViewController")] ){
        qtvc = (PFQueryTableViewController *)currentViewContoller;
    }
    
    // Refresh timeline on network restoration. 
    if ([self isParseReachable] && [PFUser currentUser] && qtvc && qtvc.objects.count == 0){
        [qtvc loadObjects];
    }
     */
}

- (void)showErrorHUD:(NSString *)text{
    MBProgressHUD *h = [MBProgressHUD showHUDAddedTo:hudlayer animated:YES];
    [h setSquare:NO];
    UIImageView *custom = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [custom setImage:[UIImage imageNamed:@"error.png"]];
    [h setCustomView:custom];
    [h setMode:MBProgressHUDModeCustomView];
    
    [h setLabelText:text];
    [h show:YES];
    [h setDimBackground:NO];
    [h hide:YES afterDelay:2.0f];
}

- (void)showConnectionChangedHUD:(NSString *)text{
    MBProgressHUD *h = [MBProgressHUD showHUDAddedTo:hudlayer animated:YES];
    [h setSquare:NO];
    UIImageView *custom = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [custom setImage:[UIImage imageNamed:@"connection.png"]];
    [h setCustomView:custom];
    [h setMode:MBProgressHUDModeCustomView];
    
    [h setLabelText:text];
    [h show:YES];
    [h setDimBackground:NO];
    [h hide:YES afterDelay:2.0f];
    
}

- (void)handlePush:(NSDictionary *)launchOptions {
    [self setLastknownpush:nil];
    
    NSLog(@"handlepush");
    NSLog(@"%@", launchOptions);
    // If the app was launched in response to a push notification, we'll handle the payload here
    NSDictionary *remoteNotificationPayload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if ([PFUser currentUser]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cc.vellum.thisversusthat.notification.didreceivenotification" object:nil userInfo:nil];
        
    }
    if (remoteNotificationPayload) {
        
        NSLog(@"payload found");
        
        // we may want to post an internal notification to update activity
            /*        [[NSNotificationCenter defaultCenter] postNotificationName:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:remoteNotificationPayload];
            */
        
        
        if ([PFUser currentUser]) {
            
            NSLog( @"here" );
            
            [self.mainViewController showLeftPanel];
            
            /*
            // if the push notification payload references a photo, we will attempt to push this view controller into view
            NSString *photoObjectId = [remoteNotificationPayload objectForKey:kPAPPushPayloadPhotoObjectIdKey];
            NSString *fromObjectId = [remoteNotificationPayload objectForKey:kPAPPushPayloadFromUserObjectIdKey];
            
            
            if (photoObjectId && photoObjectId.length > 0) {
                
                // check if this photo is already available locally.
             
                PFObject *targetPoll = [PFObject objectWithoutDataWithClassName:@"Poll" objectId:photoObjectId];
                // if we have a local copy of this photo, this won't result in a network fetch
                [targetPoll fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    if (!error) {
                        [mainViewController popPollDetail:targetPoll];
                    }
                }];
            } else if (fromObjectId && fromObjectId.length > 0) {
                // load fromUser's profile
                
                PFQuery *query = [PFUser query];
                query.cachePolicy = kPFCachePolicyCacheElseNetwork;
                [query getObjectInBackgroundWithId:fromObjectId block:^(PFObject *user, NSError *error) {
                    if (!error) {
                        PFUser *u = (PFUser *)user;
                        [mainViewController popUserDetail:u];
                    }
                }];
                
            }
            */
        }
    }
}

- (void)showPopover:(NSString *)query delegate:(id)mydelegate{
    NSLog(@"showpopover");
    self.searchDelegate = mydelegate;
    UIView *layer = self.hudlayer;
    [layer setUserInteractionEnabled:YES];

    [UIView animateWithDuration:0.25f
                          delay:0
                        options:UIViewAnimationCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [layer setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f]];

                     }
                     completion:nil
     ];

    CGRect rect = CGRectMake(0, 0, 280, self.window.frame.size.height-220-60-20);

    UITableView *tableView = [[UITableView alloc] initWithFrame:rect];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableview = tableView;
    self.tableview.backgroundColor = [UIColor clearColor];
    self.tableview.separatorColor = [UIColor clearColor];
    [self querySvpplyFor:query];


    self.pop = [PopoverView
                
                showPopoverAtPoint:CGPointMake(160, 215)
                inView:self.window
                withTitle:@"Choose Item"
                withContentView:tableView
                delegate:self];
    
}

- (void)backfieldTapped:(id)sender{
    
    NSLog(@"backfield tapped");
    UIView *layer = self.hudlayer;
    
    [UIView animateWithDuration:0.25f
                          delay:0
                        options:UIViewAnimationCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                        [layer setBackgroundColor:[UIColor clearColor]];
                     }
                     completion:nil
     ];

    
    [layer setUserInteractionEnabled:NO];

}


#pragma mark - popoverdelegate
//Delegate receives this call once the popover has begun the dismissal animation
- (void)popoverViewDidDismiss:(PopoverView *)popoverView{
    self.pop = nil;
    self.tableview = nil;
    self.productresults = nil;
    [self backfieldTapped:nil];
    
    if ( self.searchDelegate != nil ){
        [self.searchDelegate searchViewControllerFinished:nil];
    }
}



#pragma mark - DEMO - UITableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"numrowsinsection");
    if ( self.responseState == kQueryFound){
        int ret = [self.productresults count];
        if ( ret > 25 ) ret = 25;
        return ret;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
    /*
    if ( self.responseState == kQueryFound){
        return 60;
    }
    return tableView.frame.size.height;
     */
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ResultCellIdentifier = @"ResultCell";
    static NSString *MessageCellIdentifier = @"MessageCell";
    
    if (self.responseState != kQueryFound){
        VLMMessageCell *cell = (VLMMessageCell*)[tableView dequeueReusableCellWithIdentifier:MessageCellIdentifier];
        if (cell == nil) {
            cell = [[VLMMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MessageCellIdentifier];
        }
        NSString *messaging = @"no results";
        switch (self.responseState) {
            case kQueryWaiting:
                messaging = @"loading...";
                [cell showSpinner];
                break;
            case kQueryTimedOut:
                messaging = @"timed out";
                [cell hideSpinner];
                break;
            case kQueryDownloadErrror:
                messaging = @"download error";
                [cell hideSpinner];
                break;
                
            default:
                break;
        }

        [cell setItemText:messaging];

        //cell.textLabel.text = messaging;
        return cell;
    }else{
        int ind = indexPath.row;
        VLMResultCell *cell = (VLMResultCell*)[tableView dequeueReusableCellWithIdentifier:ResultCellIdentifier];
        if (cell == nil) {
            cell = [[VLMResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ResultCellIdentifier];
        }
        if (self.productresults == nil){
            NSLog(@"products is nil");
        } else {
            NSDictionary *product = (NSDictionary *) [self.productresults objectAtIndex:ind];
            NSString *image = [product valueForKey:@"image"];
            NSString *pagetitle = [product valueForKey:@"page_title"];
            //NSString *pageurl = [product valueForKey:@"page_url"];

            //NSLog(@"%@", pagetitle);
            //cell.textLabel.text = pagetitle;
            [cell setItemPhoto:image];
            [cell setItemText:pagetitle];
        }
        return cell;

    }
    //cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.f];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ( self.responseState == kQueryFound){
        int count = [self.productresults count];
        if ( count > 0 ){
            NSLog(@"row selected: %d", indexPath.row);
            NSDictionary *product = (NSDictionary *) [self.productresults objectAtIndex:indexPath.row];
            NSString *image = [product valueForKey:@"image"];
            NSString *pagetitle = [product valueForKey:@"page_title"];
            //NSString *pageurl = [product valueForKey:@"page_url"];
            
            [self.searchDelegate didSelectItemWithTitle:pagetitle andImageURL:image];
            
            NSLog(@"%@", pagetitle);
            [self.pop dismiss];

        }
    }

}

#pragma mark - JSON

- (void)querySvpplyFor:(NSString *)query{
    self.responseState = kQueryWaiting;
    
    NSString *SEARCHTERM = [NSString stringWithFormat:@"%@", query];
    NSLog(@"query svpply for: %@", SEARCHTERM );
    
    SEARCHTERM = [SEARCHTERM stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString* urlString = [NSString stringWithFormat:SERVER_STRING, SEARCHTERM];
    
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if ([data length] > 0 && error == nil){
             [self receivedData:data];
         } else if ([data length] == 0 && error == nil){
             [self emptyReply];
         } else if (error != nil && error.code == NSURLErrorTimedOut){
             [self timedOut];
         } else if (error != nil){
             [self downloadError:error];
         }
         [self performSelectorOnMainThread:@selector(updatetable) withObject:nil waitUntilDone:NO];

     }];
}

- (void)receivedData:(NSData *)data {
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //NSLog(@"Here is what we got %@", jsonString);
    
    NSDictionary *got = [jsonString objectFromJSONString];
    NSDictionary *gotresponse = [got valueForKey:@"response"];
    NSArray *gotproducts = [gotresponse valueForKey:@"products"];
    self.productresults = [gotproducts copy];
    self.responseState = kQueryFound;
}

- (void)updatetable{
    if ( self.tableview != nil ){
        [self.tableview reloadData];
    }
}

- (void)emptyReply{
    NSLog(@"emptyreply");
    self.responseState = kQueryDownloadErrror;
}

- (void)timedOut{
    NSLog(@"timedout");
    self.responseState = kQueryTimedOut;
}

- (void)downloadError:(NSError *)error{
    NSLog(@"downloaderror");
    self.responseState = kQueryDownloadErrror;
}


@end
