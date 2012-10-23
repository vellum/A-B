//
//  VLMMainViewController.m
//  ThisVersusThat
//
//  Created by David Lu on 7/23/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UIViewController+Transitions.h"
#import "Parse/Parse.h"
#import "AppDelegate.h"
#import "VLMUtility.h"
#import "VLMConstants.h"
#import "VLMCache.h"
#import "VLMMainViewController.h"
#import "VLMFeedViewController.h"
#import "VLMFooterController.h"
#import "VLMAddButtonController.h"
#import "VLMAddViewController.h"
#import "VLMTapDelegate.h"
#import "VLMPollDetailController.h"
#import "VLMUserDetailController.h"
#import "ActivityViewController.h"
#import "ActivityNavButton.h"


@interface VLMMainViewController (){
    NSMutableData *_data;
}
@property (nonatomic, strong) UIButton *clearbutton;
@property (nonatomic, strong) ActivityViewController *activityController;
@property (nonatomic, strong) PFImageView *avatarview;
@end

@implementation VLMMainViewController

@synthesize feedViewController;
@synthesize footerViewController;
@synthesize addButtonController;
@synthesize clearbutton;
@synthesize activityController;
@synthesize avatarview;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    [self.view setAutoresizesSubviews:NO];
    [self.view setBackgroundColor:BLACK_LINEN];
    //[self.view setBackgroundColor:[UIColor grayColor]];

    // window dimensions
    CGFloat winh = [[UIScreen mainScreen] bounds].size.height;
    CGFloat winw = [[UIScreen mainScreen] bounds].size.width;
    
    self.view.frame = CGRectMake(0, STATUSBAR_HEIGHT, winw, winh-STATUSBAR_HEIGHT);
    
    self.avatarview = [[PFImageView alloc] initWithFrame:CGRectZero];
    [self.avatarview setHidden:YES];
    
    CGFloat y = 0;
    CGFloat x = 20;

    UIView *activityHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winw, 14*1 + (28+28)*2)];
    [activityHeader setBackgroundColor:[UIColor clearColor]];
    [activityHeader setAutoresizesSubviews:NO];

                                // THIS SHOULD BE ITS OWN CLASS
    UIColor *norm = [UIColor colorWithWhite:0.9f alpha:1.0f];
    UIColor *high = [UIColor colorWithWhite:0.9f alpha:0.5f];
    UIColor *dis = [UIColor colorWithWhite:0.9f alpha:0.25f];
                                
                                ActivityNavButton *profilebutton = [[ActivityNavButton alloc] initWithFrame:CGRectMake(x, y, 6*40, 28+28) andTypeSize:14 andColor:norm highlightColor:high disabledColor:dis andText:@"Profile" andImageView:avatarview];
                                [activityHeader addSubview:profilebutton];
                                [profilebutton addTarget:self action:@selector(tappedProfile:) forControlEvents:UIControlEventTouchUpInside];
                                y+= 28 + 28;
                                /*
                                ActivityNavButton *settingsbutton = [[ActivityNavButton alloc] initWithFrame:CGRectMake(x, y, 6*40, 28+28) andTypeSize:14 andColor:norm highlightColor:high disabledColor:dis andText:@"Settings" andImageView:nil];
                                [activityHeader addSubview:settingsbutton];
                                [settingsbutton addTarget:self action:@selector(tappedSettings:) forControlEvents:UIControlEventTouchUpInside];
                                y+= 28 + 28;
                                */
    
                                ActivityNavButton *logoutbutton = [[ActivityNavButton alloc] initWithFrame:CGRectMake(x, y, 6*40, 28+28) andTypeSize:14 andColor:norm highlightColor:high disabledColor:dis andText:@"Log out" andImageView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logout.png"]]];
                                [activityHeader addSubview:logoutbutton];
                                [logoutbutton addTarget:self action:@selector(tappedLogout:) forControlEvents:UIControlEventTouchUpInside];
                                y+= 28 + 28;
                                y+=14+7;
                                

    
    [self.view addSubview:activityHeader];
    
    self.activityController = [[ActivityViewController alloc] initWithPopDelegate:self andHeaderView:activityHeader];
    [self.view addSubview:self.activityController.tableView];

	
    VLMFeedViewController *fvc = [[VLMFeedViewController alloc] initWithTapDelegate:self];
    self.feedViewController = fvc;
    self.feedViewController.popDelegate = self;

    [self.view addSubview:[self.feedViewController view]];
    
    VLMAddButtonController *add = [[VLMAddButtonController alloc] initWithParentController:self];
    [self.view addSubview:add.view];
    self.addButtonController = add;

    self.footerViewController = [[VLMFooterController alloc] initWithMainViewController:self];  
    [self.view addSubview:[self.footerViewController view]];

    // bottom bar
    if ([PFUser currentUser]){
        [self showLoggedInState];
        [add show];
    }else {
        [add hide];
    }
    
    self.view.clipsToBounds = YES;
}

- (void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark Signup/Login

- (void)presentLogin{
    // Create the log in view controller
    PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
    [logInViewController setFields:PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsPasswordForgotten | PFLogInFieldsDismissButton];
    [logInViewController setDelegate:self];
    [self presentModalViewController:logInViewController animated:YES];
    [self.addButtonController show];
}

- (void)presentSignUp{
    PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
    [signUpViewController setDelegate:self]; // Set ourselves as the delegate
    [self presentModalViewController:signUpViewController animated:YES];
}

-(void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error{
    
}

-(void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user{
    [logInController dismissViewControllerAnimated:YES completion:nil];
    [self showLoggedInState];
}

-(void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error{
    
}

-(void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user{
    [signUpController dismissViewControllerAnimated:YES completion:nil];
    [self showLoggedInState];
}


- (void)showLoggedInState{
    //[[PFUser currentUser] fetchInBackgroundWithBlock:nil];
    
    CGFloat winw = [[UIScreen mainScreen] bounds].size.width;
    CGFloat winh = [[UIScreen mainScreen] bounds].size.height;
    [self.footerViewController.view removeFromSuperview];
    [self.feedViewController.view setAutoresizesSubviews:NO];
    [self.feedViewController.view setFrame:CGRectMake(0, 0, winw, winh-STATUSBAR_HEIGHT)];
    [self.feedViewController updatelayout];
    [self.feedViewController.tableViewController scrollViewDidScroll:self.feedViewController.tableViewController.tableView];
    [self.addButtonController show];
    [self.activityController refresh];
    
    NSLog(@"Downloading user's profile picture");
    
    NSString *fbid = [[PFUser currentUser] objectForKey:@"facebookId"];
    NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", fbid];
    
    // Download user's profile picture
    NSURL *profilePictureURL = [NSURL URLWithString:url];
    
    NSURLRequest *profilePictureURLRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f]; // Facebook profile picture cache policy: Expires in 2 weeks
    [NSURLConnection connectionWithRequest:profilePictureURLRequest delegate:self];
    
    
    [(AppDelegate *)[UIApplication sharedApplication].delegate hideHUD];
    
    PFFile *file = [[PFUser currentUser] objectForKey:@"profilePicSmall"];
    [self.avatarview setFile:file];
    [self.avatarview loadInBackground];
    [self.avatarview setHidden:NO];
    
    
}


#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [VLMUtility processFacebookProfilePictureData:_data];
}


#pragma mark - add poll

- (void)presentAdd {
    VLMAddViewController *avc = [[VLMAddViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:avc];
    [navigationController.navigationBar setTitleVerticalPositionAdjustment:HEADER_TITLE_VERTICAL_OFFSET forBarMetrics:UIBarMetricsDefault];
    
    [self presentModalViewController:navigationController animated:YES];
}
- (void)refreshfeed{
    [feedViewController refreshfeed];
    [activityController loadObjects];
}

#pragma mark - VLMPopDelegate

- (void)popPollDetail:(PFObject *)poll{
    NSLog(@"poppoll: %@", poll);
    
    UIViewController *vc = [self presentedViewController];

    VLMPollDetailController *polldetail = [[VLMPollDetailController alloc] initWithObject:poll isRoot:YES];
    UINavigationController *navigationController;
    if ( vc ) {
        navigationController = [vc navigationController];
        [navigationController pushViewController:polldetail animated:YES];
    } else {
        navigationController = [[UINavigationController alloc] initWithRootViewController:polldetail];
        [navigationController.navigationBar setTitleVerticalPositionAdjustment:HEADER_TITLE_VERTICAL_OFFSET forBarMetrics:UIBarMetricsDefault];
        [self presentModalViewController:navigationController withPushDirection:kCATransitionFromRight];
    }
}

- (void)popUserDetail:(PFUser *)user{
    
    UIViewController *vc = [self presentedViewController];
    VLMUserDetailController *userdetail = [[VLMUserDetailController alloc] initWithObject:user isRoot:YES];
    UINavigationController *navigationController;
    if ( vc ) {
        navigationController = [vc navigationController];
        [navigationController pushViewController:userdetail animated:YES];
    } else {
        navigationController = [[UINavigationController alloc] initWithRootViewController: userdetail];
        [navigationController.navigationBar setTitleVerticalPositionAdjustment:HEADER_TITLE_VERTICAL_OFFSET forBarMetrics:UIBarMetricsDefault];
        [self presentModalViewController:navigationController withPushDirection:kCATransitionFromRight];
    }
}

- (void)popPollDetailAndScrollToComments:(PFObject *)poll{
    VLMPollDetailController *polldetail = [[VLMPollDetailController alloc] initWithObject:poll isRoot:YES];
    [polldetail scrollToComments];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:polldetail];
    [navigationController.navigationBar setTitleVerticalPositionAdjustment:HEADER_TITLE_VERTICAL_OFFSET forBarMetrics:UIBarMetricsDefault];
    [self presentModalViewController:navigationController withPushDirection:kCATransitionFromRight];
}

- (void)didTap:(id)sender{
    if ( [PFUser currentUser] ){
    [self showLeftPanel];
    }
}

- (void)showLeftPanel{

    
    [activityController enable:YES];
    CGRect f = self.feedViewController.view.frame;
    f = CGRectOffset(f, f.size.width-40, 0);
    [addButtonController hide];
    [feedViewController.tableViewController.tableView setScrollsToTop:NO];
    if (!clearbutton) {
        self.clearbutton = [UIButton buttonWithType:UIButtonTypeCustom];
        [clearbutton setEnabled:YES];
        [clearbutton setHidden:NO];
        [clearbutton setUserInteractionEnabled:YES];
        [clearbutton setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:0]];
        [clearbutton setFrame:CGRectMake(self.view.frame.size.width-40, 0, 40, self.view.frame.size.height)];
        [clearbutton addTarget:self action:@selector(hideLeftPanel:) forControlEvents:UIControlEventTouchUpInside];
        [clearbutton addTarget:self action:@selector(hideLeftPanel:) forControlEvents:UIControlEventTouchDragInside];
    }
    [self.view addSubview:clearbutton];
    
    [UIView animateWithDuration:0.325
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.feedViewController.view.frame = f;
                     }
                     completion:^(BOOL finished){
                         
                     }
     ];
}
         
-(void)hideLeftPanel:(id)sender{
    [activityController enable:NO];
    [feedViewController.tableViewController.tableView setScrollsToTop:YES];
    [clearbutton removeFromSuperview];
    CGRect f = self.feedViewController.view.frame;
    f = CGRectMake(0, 0, f.size.width, f.size.height);
    if ( [PFUser currentUser] ){
        [addButtonController show];
    }
    [UIView animateWithDuration:0.325
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.feedViewController.view.frame = f;
                     }
                     completion:^(BOOL finished){
                         
                     }
     ];
 
}

-(void)tappedProfile:(id)sender{
    if (![PFUser currentUser] ) return;
    [self popUserDetail:[PFUser currentUser]];
}

- (void)tappedLogout:(id)sender{
    // open an allertyview
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Log out" otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

- (void)tappedSettings:(id)sender{
    NSLog(@"settings");
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self logout];
    } else if (buttonIndex == 1) {
    }
}

- (void)logout{
    [(AppDelegate *)[UIApplication sharedApplication].delegate showHUD:@""];
    if ([PFUser currentUser]){

        // clear cache
        [[VLMCache sharedCache] clear];
        
        // remove cached profile image
        NSURL *cachesDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject]; // iOS Caches directory
        NSURL *profilePictureCacheURL = [cachesDirectoryURL URLByAppendingPathComponent:@"FacebookProfilePicture.jpg"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:[profilePictureCacheURL path]]) {
            [[NSFileManager defaultManager] removeItemAtPath:[profilePictureCacheURL path] error:nil];
        }
        
        // Unsubscribe from push notifications by clearing the channels key (leaving only broadcast enabled).
        [[PFInstallation currentInstallation] setObject:@[@""] forKey:kPAPInstallationChannelsKey];
        [[PFInstallation currentInstallation] removeObjectForKey:kPAPInstallationUserKey];
        [[PFInstallation currentInstallation] saveInBackground];
        
        // Log out
        [PFUser logOut];
    }
    [self.view addSubview:self.footerViewController.view];
    [self.feedViewController updatelayout];

    [self hideLeftPanel:nil];
}

@end
