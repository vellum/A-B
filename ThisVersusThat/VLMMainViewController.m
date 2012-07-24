//
//  VLMMainViewController.m
//  ThisVersusThat
//
//  Created by David Lu on 7/23/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "VLMMainViewController.h"
#import "VLMFeedViewController.h"
#import "VLMFooterController.h"
#import "VLMConstants.h"
#import "Parse/Parse.h"
#import "VLMAddButtonController.h"
@interface VLMMainViewController ()

@end

@implementation VLMMainViewController

@synthesize feedViewController;
@synthesize footerViewController;

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

    // window dimensions
    CGFloat winh = [[UIScreen mainScreen] bounds].size.height;
    CGFloat winw = [[UIScreen mainScreen] bounds].size.width;
    
    self.view.frame = CGRectMake(0, STATUSBAR_HEIGHT, winw, winh-STATUSBAR_HEIGHT);
    
    // feed view controller
	VLMFeedViewController *fvc = [[VLMFeedViewController alloc] init];
	
	// hold on to a reference
    self.feedViewController = fvc;
    
    // add children
    [self.view addSubview:[self.feedViewController view]];
    
    // bottom bar
    if (![PFUser currentUser]){
        self.footerViewController = [[VLMFooterController alloc] initWithMainViewController:self];  
        [self.view addSubview:[self.footerViewController view]];
    }
    else {
    }

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

- (void)showLoggedInState{
    CGFloat winw = [[UIScreen mainScreen] bounds].size.width;
    CGFloat winh = [[UIScreen mainScreen] bounds].size.height;
    [self.footerViewController.view removeFromSuperview];
    [self.feedViewController.view setAutoresizesSubviews:NO];
    [self.feedViewController.view setFrame:CGRectMake(0, 0, winw, winh-STATUSBAR_HEIGHT)];
    [self.feedViewController updatelayout];
    VLMAddButtonController *add = [[VLMAddButtonController alloc] init];
    [self.view addSubview:add.view];
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
