//
//  VLMUserDetailController.m
//  ThisVersusThat
//
//  Created by David Lu on 8/7/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "VLMUserDetailController.h"
#import "VLMConstants.h"
#import "UIViewController+Transitions.h"
#import <QuartzCore/QuartzCore.h>

@interface VLMUserDetailController ()

@end

@implementation VLMUserDetailController
@synthesize user;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithObject:(PFUser *)obj{
    self = [super init];
    if ( self ){
        self.user = obj;
    }
    return self;
}


- (void)cancel:(id)sender{
    
    [self dismissModalViewControllerWithPushDirection:kCATransitionFromLeft];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view setBackgroundColor:FEED_TABLEVIEW_BGCOLOR];
    
    //self.title = @"User Detail";
    self.title = [self.user objectForKey:@"displayName"];

    
    if ( self == [self.navigationController.viewControllers objectAtIndex:0] )
    {
        UIBarButtonItem *cancelbutton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
        [self.navigationItem setLeftBarButtonItem:cancelbutton];
    }
    
}

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
