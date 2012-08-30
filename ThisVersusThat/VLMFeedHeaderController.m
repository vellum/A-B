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
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic) CGRect titleframe;
@end

@implementation VLMFeedHeaderController

@synthesize rect;
@synthesize offsetY;
@synthesize delegate;
@synthesize feedtype;
@synthesize pagecontrol;
@synthesize titleView;
@synthesize titleframe;
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
    
    UIView *titleviewmask = [[UIView alloc] initWithFrame:CGRectMake(winw/2-75.0f, 0, 150.0f, HEADER_HEIGHT)];
    [titleviewmask setClipsToBounds:YES];
    [titleviewmask setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:titleviewmask];

    
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300.0f, HEADER_HEIGHT)];
    [titleView setBackgroundColor:[UIColor clearColor]];
    [titleviewmask addSubview:titleView];
    self.titleframe = titleView.frame;

    
    UILabel *A = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, HEADER_HEIGHT)];
    [A setText:@"All Polls"];
    [A setFont:[UIFont fontWithName:HEADER_TITLE_FONT size:NAVIGATION_HEADER_TITLE_SIZE]];
    [A setTextColor:TEXT_COLOR];
    [A setTextAlignment:UITextAlignmentCenter];
    [A setBackgroundColor:[UIColor clearColor]];
    [titleView addSubview:A];
    
    CGRect f = A.frame;
    [A sizeToFit];
    CGFloat aw = A.frame.size.width;
    CGFloat ah = A.frame.size.height;
    [A setFrame:f];
    UIView *underlineA = [[UIView alloc] initWithFrame:CGRectMake(75-aw/2, HEADER_HEIGHT/2 + ah/2-2, aw, 1)];
    [underlineA setBackgroundColor:TEXT_COLOR];
    //[titleView addSubview:underlineA];

    UILabel *B = [[UILabel alloc] initWithFrame:CGRectMake(150, 0, 150, HEADER_HEIGHT)];
    //[B setText:@"Friends\u2019 Polls"];
    [B setText:@"Polls I Follow"];
    [B setFont:[UIFont fontWithName:HEADER_TITLE_FONT size:NAVIGATION_HEADER_TITLE_SIZE]];
    [B setTextColor:TEXT_COLOR];
    [B setTextAlignment:UITextAlignmentCenter];
    [B setBackgroundColor:[UIColor clearColor]];
    [titleView addSubview:B];

    f = B.frame;
    [B sizeToFit];
    CGFloat bw = B.frame.size.width;
    CGFloat bh = B.frame.size.height;
    [B setFrame:f];
    UIView *underlineB = [[UIView alloc] initWithFrame:CGRectMake(150 + 75-bw/2, HEADER_HEIGHT/2 + bh/2 -2, bw, 1)];
    [underlineB setBackgroundColor:TEXT_COLOR];
    //[titleView addSubview:underlineB];

    UISwipeGestureRecognizer *sgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toggleHeader:)];
    [sgr setDirection:UISwipeGestureRecognizerDirectionLeft];
    UISwipeGestureRecognizer *sgr2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toggleHeader:)];
    [sgr2 setDirection:UISwipeGestureRecognizerDirectionRight];
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleHeader:)];
    [titleviewmask addGestureRecognizer:sgr];
    [titleviewmask addGestureRecognizer:sgr2];
    [titleviewmask addGestureRecognizer:tgr];
    
    
    self.pagecontrol = [[DDPageControl alloc] init];
    [pagecontrol setCenter:CGPointMake(winw/2, HEADER_HEIGHT - 14 + 2)];
    [pagecontrol setIndicatorDiameter:5.0f];
    [pagecontrol setIndicatorSpace:7.0f];
    [pagecontrol setNumberOfPages:2];
    [pagecontrol setCurrentPage:0];
    [pagecontrol setOnColor:[UIColor colorWithWhite:0.2f alpha:0.75f]];
    [pagecontrol setOffColor:[UIColor colorWithWhite:0.2f alpha:0.2f]];
    [pagecontrol setUserInteractionEnabled:NO];
    [self.view addSubview:pagecontrol];
    
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    [left setImage:[UIImage imageNamed:@"3lines.png"] forState:UIControlStateNormal];
    [left setImage:[UIImage imageNamed:@"3lines_highlighted.png"] forState:UIControlStateHighlighted];
    [left setFrame:CGRectMake(0, 0, 80, 60)];
    [self.view addSubview:left];
    [left addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    //[left addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchCancel];
    UISwipeGestureRecognizer *leftbuttonswipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [leftbuttonswipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [left addGestureRecognizer:leftbuttonswipe];
}

- (void)toggleHeader:(id)sender{
    //NSLog(@"kew");
    int current = self.pagecontrol.currentPage;
    
    UISwipeGestureRecognizer *sgr;
    if ( [sender isMemberOfClass:[UISwipeGestureRecognizer class]] ){
        sgr = (UISwipeGestureRecognizer *)sender;
    }
    
    if ( current == 1 ){
        if ( sgr && sgr.direction == UISwipeGestureRecognizerDirectionLeft ) return;
        [self setFeedtype:VLMFeedTypeAll];
        [UIView animateWithDuration:0.325f
                              delay:0.0f 
                            options:UIViewAnimationCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [titleView setFrame:CGRectOffset(titleframe, 0, 0)];
                         }
                         completion:^(BOOL finished){
                             [self.pagecontrol setCurrentPage:0];
                         }
         ];

    } else {
        if ( sgr && sgr.direction == UISwipeGestureRecognizerDirectionRight ) return;
        [self setFeedtype:VLMFeedTypeFollowing];
        [UIView animateWithDuration:0.325f
                              delay:0.0f 
                            options:UIViewAnimationCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [titleView setFrame:CGRectOffset(titleframe, -150, 0)];
                         }
                         completion:^(BOOL finished){
                             [self.pagecontrol setCurrentPage:1];
                         }
         ];
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
