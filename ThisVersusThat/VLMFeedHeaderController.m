//
//  VLMFeedHeaderViewController.m
//  ThisVersusThat
//
//  Created by David Lu on 7/17/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "VLMFeedHeaderController.h"
#import "VLMConstants.h"
#import "VLMTextButton.h"
#import <QuartzCore/QuartzCore.h>
@interface VLMFeedHeaderController ()

@end

@implementation VLMFeedHeaderController

@synthesize rect;
@synthesize offsetY;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.title = title;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGFloat winw = [[UIScreen mainScreen] bounds].size.width;
    CGRect contentrect = CGRectMake(0.0f, 0.0f, winw, HEADER_HEIGHT+HEADER_CORNER_RADIUS);

    [self.view setAutoresizesSubviews:NO];
    [self.view setBackgroundColor:FEED_HEADER_BGCOLOR];
    [self setRect:contentrect];
    [self setOffsetY:0.0f];
    [self.view setFrame:CGRectOffset(self.rect, 0.0f, self.offsetY)];
    [self.view.layer setCornerRadius:HEADER_CORNER_RADIUS];
    [self.view.layer setMasksToBounds:YES];
    
    
    UIButton *t = [self makeTextButtonWithFrame:CGRectMake(winw/2-75.0f, 0, 150.0f, HEADER_HEIGHT)];
    [t setEnabled:NO];
    [t setTitle:self.title forState:UIControlStateNormal];
    [t.titleLabel setFont:[UIFont fontWithName:HEADER_TITLE_FONT size:NAVIGATION_HEADER_TITLE_SIZE]];
    [t setTitleColor:TEXT_COLOR forState:UIControlStateNormal];
    [t setTitleShadowColor:[UIColor colorWithWhite:0.1f alpha:1.0f] forState:UIControlStateNormal];
    [self.view addSubview: t];
    
}


- (UIButton*)makeTextButtonWithFrame:(CGRect)frame
{
    UIButton *fb = [[UIButton alloc] initWithFrame:frame];
    [fb.titleLabel setFont:[UIFont fontWithName:HEADER_TITLE_FONT size:16.0f]];
    [fb setTitleColor:[UIColor colorWithWhite:0.2f alpha:1.0f] forState:UIControlStateNormal];
    //[fb setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [fb setShowsTouchWhenHighlighted:YES];
    return fb;
}

- (void)pushVerticallyBy:(CGFloat) offsetYVal{
    [self setOffsetY:offsetYVal];
    [[self view] setFrame:CGRectOffset(self.rect, 0.0f, self.offsetY)];
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
