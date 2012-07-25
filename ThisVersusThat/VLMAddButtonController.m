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
    CGFloat BUTTON_WIDTH = 45;
    CGFloat BUTTON_HEIGHT = 45;
    CGFloat MARGIN_BOTTOM = 12;
    CGFloat MARGIN_LEFT = 12;
    
    CGRect circlerect = CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT);
    UIView *circle = [[UIView alloc] initWithFrame:circlerect];
    [circle setBackgroundColor:[UIColor colorWithWhite:0.8 alpha:1]];
    [circle.layer setCornerRadius:BUTTON_WIDTH/2];
    [circle.layer setMasksToBounds:NO];
    [circle.layer setShadowRadius:2.0f];
    [circle.layer setShadowOffset:CGSizeMake(0, 0)];
    [circle.layer setShadowOpacity:0.5f];

    UIButton *fb = [[UIButton alloc] initWithFrame:CGRectOffset(circlerect, 1.0, -1.0)];
    [fb.titleLabel setFont:[UIFont fontWithName:FOOTER_FONT size:24]];
    [fb setTitle:@"+" forState:UIControlStateNormal];
    [fb setTitleColor:[UIColor colorWithWhite:0.2 alpha:1.0] forState:UIControlStateNormal];
    [fb setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [fb setShowsTouchWhenHighlighted:YES];
    [self setButton:fb];


    [self.view setFrame:CGRectMake(MARGIN_LEFT, winh-BUTTON_HEIGHT-STATUSBAR_HEIGHT-MARGIN_BOTTOM, BUTTON_WIDTH, BUTTON_HEIGHT)];
    [self.view addSubview:circle];
    [self.view addSubview:fb];

    [self.button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];

}

-(void) buttonTapped:(id)sender{
    [self.mvc presentAdd];
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
