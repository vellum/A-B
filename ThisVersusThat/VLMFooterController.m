//
//  VLMFooterController.m
//  ThisVersusThat
//
//  Created by David Lu on 7/17/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//
#import "VLMFooterController.h"
#import "VLMConstants.h"
#import "VLMTextButton.h"
#import "VLMMainViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface VLMFooterController ()

@end

@implementation VLMFooterController

@synthesize feedbutton;
@synthesize addbutton;
@synthesize mainviewcontroller;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    
    // dimensions
    CGFloat winh = [[UIScreen mainScreen] bounds].size.height;
    CGFloat winw = [[UIScreen mainScreen] bounds].size.width;
    CGRect contentrect = CGRectMake(0.0f, winh - FOOTER_HEIGHT - STATUSBAR_HEIGHT, winw, FOOTER_HEIGHT);
    [[self view] setFrame:contentrect];
    
    // set background
    [[self view] setBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1.0]];
    
    // log in
    UIButton *ab = [self makeTextButtonWithFrame:CGRectMake(winw/2-50.0f, 0.0f, 100.0f, FOOTER_HEIGHT) andTypeSize:14.0f];
    [ab setTitle:@"Continue" forState:UIControlStateNormal];
    [ab setShowsTouchWhenHighlighted:YES];
    CGRect r = ab.titleLabel.frame;
    ab.titleLabel.frame = r;
    [[self view] addSubview:ab];
    self.addbutton = ab;
    [ab addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];

self.view.layer.shadowRadius = 1;
self.view.layer.shadowOpacity = 0.05;

}


- (UIButton*)makeTextButtonWithFrame:(CGRect)frame andTypeSize:(CGFloat)typesize
{
    UIButton *fb = [[UIButton alloc] initWithFrame:frame];
    fb.titleLabel.font = [UIFont fontWithName:GEORGIA size:typesize];
    [fb setTitleColor:FOOTER_TEXT_COLOR forState:UIControlStateNormal];
    [fb setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [fb setShowsTouchWhenHighlighted:YES];
    
    return fb;
}


-(void) buttonTapped:(id)sender{
    NSLog(@"tapped");
    UIActionSheet *sheet = [[UIActionSheet alloc] 
                                initWithTitle:@"" 
                                delegate:self 
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:@"New Account", @"Sign In", nil];
    [sheet showInView:self.view.superview];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"Button %d", buttonIndex);
    if ( buttonIndex == 0 ){
        
        [self.mainviewcontroller presentSignUp];
        
    } else if ( buttonIndex == 1 ){
        [self.mainviewcontroller presentLogin];

    }
    switch (buttonIndex){
        //new
        case 0:
            /*
            */
            break;
        // sign in    
        case 1:
            break;
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
