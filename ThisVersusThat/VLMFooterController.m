//
//  VLMFooterController.m
//  ThisVersusThat
//
//  Created by David Lu on 7/17/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//
#import "VLMConstants.h"
#import "AppDelegate.h"
#import "VLMFooterController.h"
#import "VLMTextButton.h"
#import "VLMMainViewController.h"
#import "VLMUtility.h"
#import <QuartzCore/QuartzCore.h>
@interface VLMFooterController (){
    NSMutableData *_data;
}

@end

@implementation VLMFooterController

@synthesize feedbutton;
@synthesize addbutton;
@synthesize mainviewcontroller;

#pragma mark - NSObject

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}
- (id)initWithMainViewController:(VLMMainViewController *)viewcontroller{
    self = [super init];
    if ( self ){
        self.mainviewcontroller = viewcontroller;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    // dimensions
    CGFloat winh = [[UIScreen mainScreen] bounds].size.height;
    CGFloat winw = [[UIScreen mainScreen] bounds].size.width;
    CGRect contentrect = CGRectMake(0.0f, winh - FOOTER_HEIGHT - STATUSBAR_HEIGHT, winw, FOOTER_HEIGHT);

    [self.view setAutoresizesSubviews:NO];
    [self.view setBackgroundColor:FOOTER_BGCOLOR];
    [self.view setFrame:contentrect];
    /*
    [self.view.layer setShadowRadius:1.0f];
    [self.view.layer setShadowOpacity:0.05f];
    */
    
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(winw-25-27, (FOOTER_HEIGHT-27)/2, 27, 27)];
    [iv setImage:[UIImage imageNamed:@"facebook.png"]];
    [self.view addSubview:iv];
    
    // add button
    UIButton *ab = [self makeTextButtonWithFrame:CGRectMake(0.0f, 0.0f, winw, FOOTER_HEIGHT) andTypeSize:13.0f];
    [ab setTitle:@"Sign in via Facebook" forState:UIControlStateNormal];
    [ab setShowsTouchWhenHighlighted:YES];
    [ab setBackgroundColor:[UIColor clearColor]];
    [[self view] addSubview:ab];
    self.addbutton = ab;
    [ab addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    
}

#pragma mark - ()

- (UIButton*)makeTextButtonWithFrame:(CGRect)frame andTypeSize:(CGFloat)typesize
{
    UIButton *fb = [[UIButton alloc] initWithFrame:frame];
    [fb.titleLabel setFont:[UIFont fontWithName:FOOTER_FONT size:typesize]];
    [fb setTitleColor:FOOTER_TEXT_COLOR forState:UIControlStateNormal];
    [fb setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [fb setShowsTouchWhenHighlighted:YES];
    return fb;
}


-(void) buttonTapped:(id)sender{

    
    ///*
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = [NSArray arrayWithObjects:@"user_about_me", nil];
    
    // Login PFUser using facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {

        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
            }
        } else {
            if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
            } else {
                NSLog(@"User with facebook logged in!");
            }
        
            if (![self shouldProceedToMainInterface:user]) {
                [[PFFacebookUtils facebook] requestWithGraphPath:@"me/?fields=name,picture"
                                                     andDelegate:self];           
            }else{
            }
        }
    }];
    //*/

    /*
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" 
                                                    delegate:self 
                                                    cancelButtonTitle:@"Cancel"
                                                    destructiveButtonTitle:nil
                                                    otherButtonTitles:@"New Account", @"Sign In", nil];
    [sheet showInView:self.view.superview];
    //*/
}


- (BOOL)shouldProceedToMainInterface:(PFUser *)user {
    if ([VLMUtility userHasValidFacebookData:[PFUser currentUser]]) {
        AppDelegate *dell = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [dell showHUD:@"" animated:YES];
        [self.mainviewcontroller showLoggedInState];
        return YES;
    }
    
    return NO;
}

#pragma mark - PF_FBRequestDelegate
- (void)request:(PF_FBRequest *)request didLoad:(id)result {
    // This method is called twice - once for the user's /me profile, and a second time when obtaining their friends. We will try and handle both scenarios in a single method.
    
    NSArray *data = [result objectForKey:@"data"];
    
    if (data) {
        
        
        /*
        // we have friends data
        NSMutableArray *facebookIds = [[NSMutableArray alloc] initWithCapacity:[data count]];
        for (NSDictionary *friendData in data) {
            [facebookIds addObject:[friendData objectForKey:@"id"]];
        }
        
        // cache friend data
        [[PAPCache sharedCache] setFacebookFriends:facebookIds];
        
        if (![[PFUser currentUser] objectForKey:kPAPUserAlreadyAutoFollowedFacebookFriendsKey]) {
            [self.hud setLabelText:@"Following Friends"];
            NSLog(@"Auto-following");
            firstLaunch = YES;
            
            [[PFUser currentUser] setObject:[NSNumber numberWithBool:YES] forKey:kPAPUserAlreadyAutoFollowedFacebookFriendsKey];
            NSError *error = nil;
            
            // find common Facebook friends already using Anypic
            PFQuery *facebookFriendsQuery = [PFUser query];
            [facebookFriendsQuery whereKey:kPAPUserFacebookIDKey containedIn:facebookIds];
            
            NSArray *anypicFriends = [facebookFriendsQuery findObjects:&error];
            if (!error) {
                [anypicFriends enumerateObjectsUsingBlock:^(PFUser *newFriend, NSUInteger idx, BOOL *stop) {
                    NSLog(@"Join activity for %@", [newFriend objectForKey:kPAPUserDisplayNameKey]);
                    PFObject *joinActivity = [PFObject objectWithClassName:kPAPActivityClassKey];
                    [joinActivity setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
                    [joinActivity setObject:newFriend forKey:kPAPActivityToUserKey];
                    [joinActivity setObject:kPAPActivityTypeJoined forKey:kPAPActivityTypeKey];
                    
                    PFACL *joinACL = [PFACL ACL];
                    [joinACL setPublicReadAccess:YES];
                    joinActivity.ACL = joinACL;
                    
                    // make sure our join activity is always earlier than a follow
                    [joinActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            NSLog(@"Followed %@", [newFriend objectForKey:kPAPUserDisplayNameKey]);
                        }
                        
                        [PAPUtility followUserInBackground:newFriend block:^(BOOL succeeded, NSError *error) {
                            // This block will be executed once for each friend that is followed.
                            // We need to refresh the timeline when we are following at least a few friends
                            // Use a timer to avoid refreshing innecessarily
                            if (self.autoFollowTimer) {
                                [self.autoFollowTimer invalidate];
                            }
                            
                            self.autoFollowTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(autoFollowTimerFired:) userInfo:nil repeats:NO];
                        }];
                    }];
                }];
            }
            
            if (![self shouldProceedToMainInterface:[PFUser currentUser]]) {
                [self logOut];
                return;
            }
            
            if (!error) {
                [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:NO];
                self.hud = [MBProgressHUD showHUDAddedTo:self.homeViewController.view animated:NO];
                [self.hud setDimBackground:YES];
                [self.hud setLabelText:@"Following Friends"];
            }
        }
        
        [[PFUser currentUser] saveEventually];
         */
    } else {
        AppDelegate *dell = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [dell showHUD:@"creating profile"];

        NSString *facebookId = [result objectForKey:@"id"];
        NSString *facebookName = [result objectForKey:@"name"];
        
        NSLog(@"here. facebookname: %@", facebookName);
        if (facebookName && facebookName != 0) {
            [[PFUser currentUser] setObject:facebookName forKey:kPAPUserDisplayNameKey];
        }
        
        if (facebookId && facebookId != 0) {
            [[PFUser currentUser] setObject:facebookId forKey:kPAPUserFacebookIDKey];
        }
        
        [[PFUser currentUser] saveEventually];
        [self.mainviewcontroller showLoggedInState];
        //[[PFFacebookUtils facebook] requestWithGraphPath:@"me/friends" andDelegate:self];
    }
}

- (void)request:(PF_FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Facebook error: %@", error);
    /*
    [(AppDelegate *)[UIApplication sharedApplication].delegate hideHUD];
    
    if ([PFUser currentUser]) {
        if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"] 
             isEqualToString: @"OAuthException"]) {
            NSLog(@"The facebook token was invalidated");
            [self logOut];
        }
    }*/
    [self.mainviewcontroller logout];
}


- (void)logOut{

    /*
        // clear cache
        [[PAPCache sharedCache] clear];
        
        // clear NSUserDefaults
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPAPUserDefaultsCacheFacebookFriendsKey];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // Unsubscribe from push notifications
        [[PFInstallation currentInstallation] removeObjectForKey:kPAPInstallationUserKey];
        [[PFInstallation currentInstallation] removeObject:[[PFUser currentUser] objectForKey:kPAPUserPrivateChannelKey] forKey:kPAPInstallationChannelsKey];
        [[PFInstallation currentInstallation] saveEventually];
        */
        // Log out
        [PFUser logOut];

}


#pragma mark - ActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"Button %d", buttonIndex);
    if ( buttonIndex == 0 ){
        [self.mainviewcontroller presentSignUp];
        
    } else if ( buttonIndex == 1 ){
        [self.mainviewcontroller presentLogin];
    }
}

#pragma mark -

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
