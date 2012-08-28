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
#import "VLMMainHeaderDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "DDPageControl.h"

@interface VLMFeedHeaderController ()

@property (nonatomic, strong) id <VLMMainHeaderDelegate> delegate;
@property (nonatomic) VLMFeedType feedtype;
@property (nonatomic, strong) DDPageControl *pagecontrol;
@property (nonatomic, strong) UIButton *titlebutton;
@end

@implementation VLMFeedHeaderController

@synthesize rect;
@synthesize offsetY;
@synthesize delegate;
@synthesize feedtype;
@synthesize pagecontrol;
@synthesize titlebutton;

- (id)initWithTitle:(NSString *)title andHeaderDelegate:(id)headerdelegate
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.title = title;
        self.delegate = headerdelegate;
        self.feedtype = VLMFeedTypeAll;
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
    //[t setEnabled:NO];
    [t setTitle:self.title forState:UIControlStateNormal];
    [t setShowsTouchWhenHighlighted:NO];
    [t.titleLabel setFont:[UIFont fontWithName:HEADER_TITLE_FONT size:NAVIGATION_HEADER_TITLE_SIZE]];
    [t setTitleColor:TEXT_COLOR forState:UIControlStateNormal];
    [t setTitleShadowColor:[UIColor colorWithWhite:0.1f alpha:1.0f] forState:UIControlStateNormal];
    //[t setBackgroundImage:[UIImage imageNamed:@"clear.png"] forState:UIControlStateNormal];
    //[t setBackgroundImage:[UIImage imageNamed:@"clear50.png"] forState:UIControlStateHighlighted];
    //[t setBackgroundColor:[UIColor blueColor]];
    [t addTarget:self action:@selector(toggleHeader:) forControlEvents:UIControlEventTouchUpInside];
    
    UISwipeGestureRecognizer *sgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toggleHeader:)];
    [sgr setDirection:UISwipeGestureRecognizerDirectionLeft];
    UISwipeGestureRecognizer *sgr2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toggleHeader:)];
    [sgr2 setDirection:UISwipeGestureRecognizerDirectionRight];
   
    [t addGestureRecognizer:sgr];
    [t addGestureRecognizer:sgr2];
    self.titlebutton = t;
    
    self.pagecontrol = [[DDPageControl alloc] init];
    [pagecontrol setCenter:CGPointMake(t.center.x, HEADER_HEIGHT - 14 + 2)];
    [pagecontrol setIndicatorDiameter:5.0f];
    [pagecontrol setIndicatorSpace:7.0f];
    [pagecontrol setNumberOfPages:2];
    [pagecontrol setCurrentPage:0];
    [pagecontrol setOnColor:[UIColor colorWithWhite:0.2f alpha:0.75f]];
    [pagecontrol setOffColor:[UIColor colorWithWhite:0.2f alpha:0.2f]];
    [pagecontrol setUserInteractionEnabled:NO];
    [self.view addSubview:pagecontrol];
    [self.view addSubview: t];
    
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    [left setImage:[UIImage imageNamed:@"3lines.png"] forState:UIControlStateNormal];
    [left setImage:[UIImage imageNamed:@"3lines_highlighted.png"] forState:UIControlStateHighlighted];
    [left setFrame:CGRectMake(0, 0, 80, 60)];
    [self.view addSubview:left];
    [left addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    [left addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchCancel];
}

- (void)toggleHeader:(id)sender{
    //NSLog(@"kew");
    int current = self.pagecontrol.currentPage;
    if ( current == 1 ){
        [self.pagecontrol setCurrentPage:0];
        [self setFeedtype:VLMFeedTypeAll];
        [self.titlebutton setTitle:@"All Polls" forState:UIControlStateNormal];
    } else {
        [self.pagecontrol setCurrentPage:1];
        [self setFeedtype:VLMFeedTypeFollowing];
        [self.titlebutton setTitle:@"Polls I Follow" forState:UIControlStateNormal];
    }
    if ( self.delegate )
        if ( [self.delegate respondsToSelector:@selector(didToggleFeedType:)] )
            [self.delegate didToggleFeedType:self.feedtype];
}

- (void)tap:(id)sender{
    if ( self.delegate ){
        if ( [self.delegate respondsToSelector:@selector(didTapLeftButton:)] )
            [self.delegate didTapLeftButton:self];
    }
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
