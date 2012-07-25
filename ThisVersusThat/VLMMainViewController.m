//
//  VLMMainViewController.m
//  ThisVersusThat
//
//  Created by David Lu on 7/23/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "Parse/Parse.h"
#import "VLMConstants.h"
#import "VLMMainViewController.h"
#import "VLMFeedViewController.h"
#import "VLMFooterController.h"
#import "VLMAddButtonController.h"
#import "VLMAddViewController.h"

@interface VLMMainViewController ()

@end

@implementation VLMMainViewController

@synthesize feedViewController;
@synthesize footerViewController;
@synthesize addButtonController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view.
    [self.view setAutoresizesSubviews:NO];
    
    [self.view setBackgroundColor:MAIN_VIEW_BGCOLOR];

    // window dimensions
    CGFloat winh = [[UIScreen mainScreen] bounds].size.height;
    CGFloat winw = [[UIScreen mainScreen] bounds].size.width;
    
    self.view.frame = CGRectMake(0, STATUSBAR_HEIGHT, winw, winh-STATUSBAR_HEIGHT);
    
	VLMFeedViewController *fvc = [[VLMFeedViewController alloc] init];
    self.feedViewController = fvc;

    [self.view addSubview:[self.feedViewController view]];
    
    // bottom bar
    if (![PFUser currentUser]){
        self.footerViewController = [[VLMFooterController alloc] initWithMainViewController:self];  
        [self.view addSubview:[self.footerViewController view]];
    } else {
    }

    VLMAddButtonController *add = [[VLMAddButtonController alloc] initWithParentController:self];
    [self.view addSubview:add.view];
    self.addButtonController = add;

}
#pragma mark -
#pragma mark Signup/Login

- (void)presentLogin{
    // Create the log in view controller
    PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
    [logInViewController setFields:PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsPasswordForgotten | PFLogInFieldsDismissButton];
    [logInViewController setDelegate:self];
    [self presentModalViewController:logInViewController animated:YES];
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

// FIXME: create add button at the start, rather than on demand, just hide and show
- (void)showLoggedInState{
    CGFloat winw = [[UIScreen mainScreen] bounds].size.width;
    CGFloat winh = [[UIScreen mainScreen] bounds].size.height;
    [self.footerViewController.view removeFromSuperview];
    [self.feedViewController.view setAutoresizesSubviews:NO];
    [self.feedViewController.view setFrame:CGRectMake(0, 0, winw, winh-STATUSBAR_HEIGHT)];
    [self.feedViewController updatelayout];
}

#pragma mark -
#pragma add poll

- (void)presentAdd {
    VLMAddViewController *avc = [[VLMAddViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:avc];
    [navigationController.navigationBar setTitleVerticalPositionAdjustment:4.0f forBarMetrics:UIBarMetricsDefault];
    [self presentModalViewController:navigationController animated:YES];
}

#pragma mark -
#pragma mark boilerplate

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
