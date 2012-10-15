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
@property (nonatomic) VLMFacebookQueryType currentFacebookQueryType;
@property (nonatomic) BOOL shouldSaveUser;
@end

@implementation VLMFooterController

@synthesize feedbutton;
@synthesize addbutton;
@synthesize mainviewcontroller;
@synthesize currentFacebookQueryType;
@synthesize shouldSaveUser;
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
    shouldSaveUser = NO;

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
    [ab setShowsTouchWhenHighlighted:NO];
    [ab setBackgroundColor:[UIColor clearColor]];
    [ab setBackgroundImage:[UIImage imageNamed:@"clear.png"] forState:UIControlStateNormal];
    [ab setBackgroundImage:[UIImage imageNamed:@"clear50.png"] forState:UIControlStateHighlighted];
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
    NSArray *permissionsArray = [NSArray arrayWithObjects:@"user_location", @"user_birthday", @"user_website", @"user_about_me", nil];
    
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
                //[[PFFacebookUtils facebook] requestWithGraphPath:@"me/?fields=name,picture" andDelegate:self];           
                self.currentFacebookQueryType = VLMFacebookQueryUser;

                [[PFFacebookUtils facebook] requestWithGraphPath:@"me/?fields=name,picture,birthday,location,bio,gender,website" andDelegate:self];           
            }else{
                
                
            }
            
            // Subscribe to private push channel
            NSString *privateChannelName = [NSString stringWithFormat:@"user_%@", [user objectId]];
            [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:kPAPInstallationUserKey];
            [[PFInstallation currentInstallation] addUniqueObject:privateChannelName forKey:kPAPInstallationChannelsKey];
            [[PFInstallation currentInstallation] saveEventually];
            [user setObject:privateChannelName forKey:kPAPUserPrivateChannelKey];

        }
    }];
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
    AppDelegate *dell = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (self.currentFacebookQueryType == VLMFacebookQueryUser) {
        
        [dell showHUD:@"creating profile"];
        
        NSString *facebookId = [result objectForKey:@"id"];
        if (facebookId && facebookId != 0) {
            [[PFUser currentUser] setObject:facebookId forKey:kPAPUserFacebookIDKey];
        }
        
        NSString *facebookName = [result objectForKey:@"name"];
        if (facebookName && facebookName != 0) {
            [[PFUser currentUser] setObject:facebookName forKey:kPAPUserDisplayNameKey];
        }
        
        NSString *birthday = [result objectForKey:@"birthday"];
        if ( birthday && birthday != 0 ){
            NSDateFormatter* myFormatter = [[NSDateFormatter alloc] init];
            [myFormatter setDateFormat:@"MM/dd/yyyy"];
            NSDate* myDate = [myFormatter dateFromString:birthday];
            [[PFUser currentUser] setObject:myDate forKey:@"birthday"];
        }
        
        NSDictionary *location = [result objectForKey:@"location"];
        if (location && location !=0){
            NSString *city = [location objectForKey:@"name"];
            if (city && city != 0){
                [[PFUser currentUser] setObject:city forKey:@"location"];
            }
        }
        
        NSString *bio = [result objectForKey:@"bio"];
        if ( bio && bio != 0 ){
            if ( [bio length] > 140 ){
                bio = [bio substringToIndex:139];
            }
            [[PFUser currentUser] setObject:bio forKey:@"bio"];
        }
        
        NSString *gender = [result objectForKey:@"gender"];
        if ( gender && gender != 0 ){
            [[PFUser currentUser] setObject:gender forKey:@"gender"];
            NSLog(@"gender: %@", gender);
        }
        
        NSString *website = [result objectForKey:@"website"];
        if ( website && website != 0 ){
            [[PFUser currentUser] setObject:website forKey:@"website"];
        }
        
        
        NSDictionary *locationdict = [result objectForKey:@"location"];
        NSLog(@"%@", locationdict);
        if ( locationdict ){
            NSString *location = [locationdict objectForKey:@"name"];
            NSString *locationid = [locationdict objectForKey:@"id"];

            if (location && location != 0){
                [[PFUser currentUser] setObject:location forKey:@"location"];
                NSLog(@"location: %@", location);
                
                if ( locationid && locationid != 0 ){
                    self.currentFacebookQueryType = VLMFacebookQueryLocation;
                    NSString *path = [NSString stringWithFormat:@"%@/?fields=location", locationid];
                    [[PFFacebookUtils facebook] requestWithGraphPath:path andDelegate:self]; 
                    shouldSaveUser = NO;
                } else {
                    shouldSaveUser = YES;
                }
            }
            
        } else {
            shouldSaveUser = YES;
        }
        if ( shouldSaveUser ){
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                if ( !succeeded || error ){
                    [self.mainviewcontroller logout];
                    [dell showErrorHUD:@"Error creating profile"];
                } else {
                    [self.mainviewcontroller showLoggedInState];
                }
            }];
        }
        
    } else if (self.currentFacebookQueryType == VLMFacebookQueryLocation ) {
        
        NSDictionary *latlng = [result objectForKey:@"location"];
        if ( latlng && latlng != 0 ){
            NSNumber *lat = [latlng objectForKey:@"latitude"];
            NSNumber *lng = [latlng objectForKey:@"longitude"];
            PFGeoPoint *geo = [PFGeoPoint geoPointWithLatitude:[lat doubleValue] longitude:[lng doubleValue]];
            [[PFUser currentUser] setObject:geo forKey:@"latlng"];
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                if ( !succeeded || error ){
                    [self.mainviewcontroller logout];
                    [dell showErrorHUD:@"Error creating profile"];
                } else {
                    [self.mainviewcontroller showLoggedInState];
                }
            }];
        }
        
    } else if (self.currentFacebookQueryType == VLMFacebookQueryFriends){
        
    }
}

- (void)request:(PF_FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Facebook error: %@", error);
    [self.mainviewcontroller logout];
    AppDelegate *dell = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [dell showErrorHUD:@"Error creating profile"];
}



// FIXME: not sure if this would ever get called, since we're logging out in a different viewcontroller
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
