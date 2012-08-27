//
//  VLMAddButtonController.m
//  ThisVersusThat
//
//  Created by David Lu on 7/23/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "VLMAddButtonController.h"
#import "VLMConstants.h"
@interface VLMAddButtonController ()

@end

@implementation VLMAddButtonController

@synthesize button;
@synthesize mvc;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithParentController:(VLMMainViewController *)controller{
    self = [super init];
    if ( self ){
        self.mvc = controller;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setAutoresizesSubviews:NO];

    CGFloat winh = [[UIScreen mainScreen] bounds].size.height;
    /*
    CGFloat BUTTON_WIDTH = 55;
    CGFloat BUTTON_HEIGHT = 55;
    CGFloat MARGIN_BOTTOM = 6;
    CGFloat MARGIN_LEFT = 7;
    
    CGRect circlerect = CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT);
    UIView *circle = [[UIView alloc] initWithFrame:circlerect];
    //[circle setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.75f]];
    [circle setBackgroundColor:[UIColor colorWithWhite:0.1f alpha:0.9f]];
    [circle.layer setCornerRadius:BUTTON_WIDTH/2];
    [circle.layer setMasksToBounds:NO];
    [circle.layer setShadowRadius:2.0f];
    [circle.layer setShadowOffset:CGSizeMake(0, 0)];
    [circle.layer setShadowOpacity:0.25f];

    UIButton *fb = [[UIButton alloc] initWithFrame:CGRectOffset(circlerect, 1.0, -2.0)];
    [fb.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:28]];
    [fb setTitle:@"+" forState:UIControlStateNormal];
    [fb setTitleColor:[UIColor colorWithWhite:0.8f alpha:1.0f] forState:UIControlStateNormal];
    [fb setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [fb setShowsTouchWhenHighlighted:YES];
    [self setButton:fb];


    [self.view setFrame:CGRectMake(MARGIN_LEFT, winh-BUTTON_HEIGHT-STATUSBAR_HEIGHT-MARGIN_BOTTOM, BUTTON_WIDTH, BUTTON_HEIGHT)];
    [self.view addSubview:circle];
    [self.view addSubview:fb];
    */
    CGFloat BUTTON_WIDTH = 59;
    CGFloat BUTTON_HEIGHT = 59;
    CGFloat MARGIN_BOTTOM = 6;
    CGFloat MARGIN_LEFT = 7;
    [self.view setFrame:CGRectMake(MARGIN_LEFT, winh-BUTTON_HEIGHT-STATUSBAR_HEIGHT-MARGIN_BOTTOM, BUTTON_WIDTH, BUTTON_HEIGHT)];
    self.button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT)];
    [self.button setBackgroundImage:[UIImage imageNamed:@"plus.png"] forState:UIControlStateNormal];
    [self.button setBackgroundImage:[UIImage imageNamed:@"plus_highlight.png"] forState:UIControlStateHighlighted];
    [self.button setShowsTouchWhenHighlighted:NO];
    [self.button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
    [self show];
    //[self hide];
}

-(void) buttonTapped:(id)sender{
    [self.mvc presentAdd];
}

- (void)show{
    [self.view setAlpha:0];
    [self.view setHidden:NO];
    [self.button setEnabled:YES];
    [UIView animateWithDuration:0.325
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         [self.view setAlpha:1];
                     }
                     completion:^(BOOL finished){
                         
                     }
     ];

}

- (void)hide{
    [UIView animateWithDuration:0.325
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         [self.view setAlpha:0];
                     }
                     completion:^(BOOL finished){
                         [self.view setHidden:YES];
                         [self.button setEnabled:NO];
                     }
     ];
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
