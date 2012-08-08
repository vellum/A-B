//
//  VLMPollDetailController.m
//  ThisVersusThat
//
//  Created by David Lu on 8/7/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "VLMConstants.h"
#import "VLMPollDetailController.h"
#import "UIViewController+Transitions.h"
#import <QuartzCore/QuartzCore.h>
#import "VLMSectionView.h"
#import "VLMCache.h"
#import "VLMUserDetailController.h"

@interface VLMPollDetailController ()
@property (nonatomic, strong) NSArray *likersL;
@property (nonatomic, strong) NSArray *likersR;

@end

@implementation VLMPollDetailController
@synthesize poll;
@synthesize likersL;
@synthesize likersR;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithObject:(PFObject *)obj{
    self = [super init];
    if ( self ){
        self.poll = obj;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // 0, 20, 320, 460
    NSString *s = NSStringFromCGRect(self.view.frame);
    NSLog(@"%@", s);
    
    CGFloat contentw = self.view.frame.size.width;
    CGFloat contenth = self.view.frame.size.height - HEADER_HEIGHT;
    CGRect contentrect = CGRectMake(0, 0, contentw, contenth);
    UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:contentrect];
    
    
    UIView *contentview = [[UIView alloc] initWithFrame:contentrect];
    
    [scrollview addSubview:contentview];
    [scrollview setContentSize:contentrect.size];
    [scrollview setContentOffset:CGPointZero];
    [scrollview setScrollEnabled:YES];
    [scrollview setBounces:YES];
    [self.view addSubview:scrollview];
    
    
    [self.view setBackgroundColor:FEED_TABLEVIEW_BGCOLOR];
    //[contentview setBackgroundColor:DEBUG_BACKGROUND_GRID];

    self.title = @"Poll Detail";
    if ( self == [self.navigationController.viewControllers objectAtIndex:0] )
    {
        UIBarButtonItem *cancelbutton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
        [self.navigationItem setLeftBarButtonItem:cancelbutton];
    }

    
    PFUser *user = [poll objectForKey:@"User"];
    NSString *question = [poll objectForKey:@"Question"];
    NSString *username = [user objectForKey:@"displayName"];
    VLMSectionView *sectionhead = [[VLMSectionView alloc] initWithFrame:CGRectMake(0, 0, contentw, 0) andUserName:username andQuestion:question];
    [sectionhead setFile:[user objectForKey:@"profilePicSmall"]];
    [contentview addSubview:sectionhead];
    
    CGFloat likesL = [[[VLMCache sharedCache] likeCountForPollLeft:poll] floatValue];
    CGFloat likesR = [[[VLMCache sharedCache] likeCountForPollRight:poll] floatValue];
    CGFloat leftwidth, rightwidth;
    
    NSDictionary *attr = [[VLMCache sharedCache] attributesForPoll:poll];
    self.likersL = [attr objectForKey:@"LikersLeft"];
    self.likersR = [attr objectForKey:@"LikersRight"];


    CGFloat wwww = 40*5;
    if ( likesL > likesR ){
        leftwidth = wwww;
        rightwidth = likesR / (likesL + likesR) * leftwidth;
    } else if ( likesL < likesR ){
        rightwidth = wwww;
        leftwidth = likesL / (likesL + likesR) * rightwidth;
    } else {
        if ( likesL == 0 ){
            leftwidth = rightwidth = 0;
        } else {
            leftwidth = rightwidth = wwww * 0.5f;
        }
    }
    
    
    CGFloat hh = sectionhead.frame.size.height;
    CGFloat hhh = ceilf(hh/14) * 14 + 14;
    
    //CGFloat y = sectionhead.frame.size.height + 21;
    CGFloat y = hhh;
    CGFloat x = 40;
    CGFloat h = 40;
    CGFloat m = 3;


    UILabel *pollbreakdown = [[UILabel alloc] initWithFrame:CGRectMake(x, y, wwww + 40, 28)];
    [pollbreakdown setFont:[UIFont fontWithName:@"AmericanTypewriter-Bold" size:13.0f]];
    [pollbreakdown setNumberOfLines:0.0f];
    [pollbreakdown setText:@"Votes So Far"];
    [pollbreakdown setTextAlignment:UITextAlignmentCenter];
    [pollbreakdown setBackgroundColor:TEXT_COLOR];
    [pollbreakdown setTextColor:[UIColor whiteColor]];
    [contentview addSubview:pollbreakdown];
    
    y += 28 + 14;
    
    UIView *left = [[UIView alloc] initWithFrame:CGRectMake(x, y, leftwidth, h + m*2)];
    left.backgroundColor = [UIColor colorWithWhite:1 alpha:1.0];
    [contentview addSubview:left];
    
    PFImageView *leftimage = [[PFImageView alloc] initWithFrame:CGRectMake(3, 3, h, h)];
    PFObject *leftphoto = [poll objectForKey:@"PhotoLeft"];
    [leftimage setFile:[leftphoto objectForKey:@"Original"]];
    [left addSubview:leftimage];

    UILabel *labelL = [[UILabel alloc] initWithFrame:CGRectMake(h + m + 5, 0, wwww-(h - m*2), h)];
    [labelL setFont:[UIFont fontWithName:@"AmericanTypewriter" size:13.0f]];
    [labelL setNumberOfLines:0.0f];
    [labelL setText:[leftphoto objectForKey:@"Caption"]];
    [labelL setBackgroundColor:[UIColor clearColor]];
    [left addSubview:labelL];

    UILabel *countL = [[UILabel alloc] initWithFrame:CGRectMake(wwww, 0, 40, h)];
    [countL setFont:[UIFont fontWithName:@"AmericanTypewriter" size:13.0f]];
    [countL setNumberOfLines:0.0f];
    [countL setText:[NSString stringWithFormat:@"%d", (int)likesL]];
    [countL setTextAlignment:UITextAlignmentCenter];
    [countL setBackgroundColor:[UIColor clearColor]];
    [countL setTextColor:TEXT_COLOR];
    [left addSubview:countL];
    
    CGFloat cx = 3;
    CGFloat cy = h + m*2 +2;
    if ( likesL > 0 ){
        for ( int i = 0; i < [likersL count]; i++ ){
            PFUser *u = [likersL objectAtIndex:i];
            [u fetchIfNeeded];

            PFImageView *iv = [[PFImageView alloc] initWithFrame:CGRectMake(cx, cy, 20, 20)];
            PFFile *file = [u objectForKey:@"profilePicSmall"];
            [iv setFile:file];
            [left addSubview:iv];
            
            UIButton *clearbutton = [[UIButton alloc] initWithFrame:CGRectMake(left.frame.origin.x+cx, left.frame.origin.y + cy, 20, 20)];
            [clearbutton setBackgroundColor:[UIColor clearColor]];
            [clearbutton setTag:i];
            [clearbutton addTarget:self action:@selector(handleTapLikerL:) forControlEvents:UIControlEventTouchUpInside];
            [contentview addSubview:clearbutton];

            cx += 25;
            if ( cx > wwww ){
                cx = 5;
                cy += 25;
            }
        }
        cy += 37;
    } else {
        cy += 10;
    }

    y += cy;
    
    UIView *right = [[UIView alloc] initWithFrame:CGRectMake(x, y, rightwidth, h+m*2)];
    right.backgroundColor = [UIColor colorWithWhite:1 alpha:1.0];
    [contentview addSubview:right];
    
    PFImageView *rightimage = [[PFImageView alloc] initWithFrame:CGRectMake(3, 3, h, h)];
    PFObject *rightphoto = [poll objectForKey:@"PhotoRight"];
    [rightimage setFile:[rightphoto objectForKey:@"Original"]];
    [right addSubview:rightimage];

    UILabel *labelR = [[UILabel alloc] initWithFrame:CGRectMake(h + m + 5, 0, wwww-(h - m*2), h)];
    [labelR setFont:[UIFont fontWithName:@"AmericanTypewriter" size:13.0f]];
    [labelR setNumberOfLines:0.0f];
    [labelR setText:[rightphoto objectForKey:@"Caption"]];
    [labelR setBackgroundColor:[UIColor clearColor]];
    [right addSubview:labelR];
    
    UILabel *countR = [[UILabel alloc] initWithFrame:CGRectMake(wwww, 0, 40, h)];
    [countR setFont:[UIFont fontWithName:@"AmericanTypewriter" size:13.0f]];
    [countR setNumberOfLines:0.0f];
    [countR setBackgroundColor:[UIColor clearColor]];
    [countR setTextColor:TEXT_COLOR];
    [countR setText:[NSString stringWithFormat:@"%d", (int)likesR]];
    [countR setTextAlignment:UITextAlignmentCenter];
    [right addSubview:countR];
    
    cx = 3;
    cy = h + m*2 +2;
    if ( likesR > 0 ){
        for ( int i = 0; i < [likersR count]; i++ ){
            PFUser *u = [likersR objectAtIndex:i];
            [u fetchIfNeeded];
            
            PFImageView *iv = [[PFImageView alloc] initWithFrame:CGRectMake(cx, cy, 20, 20)];
            PFFile *file = [u objectForKey:@"profilePicSmall"];
            [iv setFile:file];
            [right addSubview:iv];
            
            UIButton *clearbutton = [[UIButton alloc] initWithFrame:CGRectMake(right.frame.origin.x+cx, right.frame.origin.y + cy, 20, 20)];
            [clearbutton setBackgroundColor:[UIColor clearColor]];
            [clearbutton setTag:i];
            [clearbutton addTarget:self action:@selector(handleTapLikerR:) forControlEvents:UIControlEventTouchUpInside];
            [contentview addSubview:clearbutton];

            cx += 25;
            if ( cx > wwww ){
                cx = 5;
                cy += 25;
            }
        }
        cy += 40;
    } else {
        cy += 10;
    }
    
    y += cy;

    
    if ( y > self.view.frame.size.height ){
        [scrollview setContentSize:CGSizeMake(self.view.frame.size.width, y )];
    } else {
        [scrollview setContentSize:CGSizeMake(contentw, contenth + 15)];
    }
        
}


- (void)cancel:(id)sender{
    
    [self dismissModalViewControllerWithPushDirection:kCATransitionFromLeft];
    
}

- (void)handleTapLikerL:(id)sender{
    NSInteger index = [sender tag];
    PFUser *user = [self.likersL objectAtIndex:index];
    NSLog(@"%@", user);
    NSLog(@"tapped: %d", index);
    VLMUserDetailController *userdetail = [[VLMUserDetailController alloc] initWithObject:user];
    UINavigationController *navigationController = self.navigationController;
    [navigationController pushViewController:userdetail animated:YES];
}

- (void)handleTapLikerR:(id)sender{
    NSInteger index = [sender tag];
    PFUser *user = [self.likersR objectAtIndex:index];
    NSLog(@"%@", user);
    NSLog(@"tapped r: %d", index);
    VLMUserDetailController *userdetail = [[VLMUserDetailController alloc] initWithObject:user];
    UINavigationController *navigationController = self.navigationController;
    [navigationController pushViewController:userdetail animated:YES];
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
