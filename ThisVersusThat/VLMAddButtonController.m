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
    //CGFloat winw = [[UIScreen mainScreen] bounds].size.width;
    CGFloat winh = [[UIScreen mainScreen] bounds].size.height;
    
    CGFloat BUTTON_WIDTH = 36;
    CGFloat BUTTON_HEIGHT = 36;
    CGFloat MARGIN_BOTTOM = 10;
    CGFloat MARGIN_LEFT = 6;
    
    //self.view.frame = CGRectMake(winw-BUTTON_WIDTH -MARGIN_BOTTOM, winh-BUTTON_HEIGHT-STATUSBAR_HEIGHT-MARGIN_BOTTOM, BUTTON_WIDTH, BUTTON_HEIGHT);
    self.view.frame = CGRectMake(MARGIN_LEFT, winh-BUTTON_HEIGHT-STATUSBAR_HEIGHT-MARGIN_BOTTOM, BUTTON_WIDTH, BUTTON_HEIGHT);
    CGRect circlerect = CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT);
    UIView *circle = [[UIView alloc] initWithFrame:circlerect];
    circle.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1];
    //circle.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"txture.png"]];
    circle.layer.cornerRadius = BUTTON_WIDTH/2;
    circle.layer.masksToBounds = NO;
    circle.layer.shadowRadius = 5;
    circle.layer.shadowOffset = CGSizeMake(-1, -1);
    circle.layer.shadowOpacity = 0.2;
    //circle.layer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge;
    [self.view addSubview:circle];
    
    
    UIButton *fb = [[UIButton alloc] initWithFrame:CGRectOffset(circlerect, 1.0, -1.0)];
    fb.titleLabel.font = [UIFont fontWithName:HELVETICA size:24];

    [fb setTitle:@"+" forState:UIControlStateNormal];
    [fb setTitleColor:[UIColor colorWithWhite:0.2 alpha:1.0] forState:UIControlStateNormal];
    [fb setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [fb setShowsTouchWhenHighlighted:YES];
    [self.view addSubview:fb];
    
    

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
