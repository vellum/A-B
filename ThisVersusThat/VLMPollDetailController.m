//
//  VLMPollDetailController.m
//  ThisVersusThat
//
//  Created by David Lu on 8/7/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "VLMConstants.h"
#import "VLMPollDetailController.h"
#import "UIViewController+Transitions.h"
#import "VLMSectionView.h"
#import "VLMCache.h"
#import "VLMUserDetailController.h"
#import "VLMCommentCell.h"

@interface VLMPollDetailController ()
@property (nonatomic, strong) NSArray *likersL;
@property (nonatomic, strong) NSArray *likersR;
@end

@implementation VLMPollDetailController
@synthesize poll;
@synthesize likersL;
@synthesize likersR;

- (id)initWithObject:(PFObject *)obj{
    self = [super init];
    if ( self ){
        self.poll = obj;
        
        self.loadingViewEnabled = NO;
        
        // The className to query on
        self.className = @"Activity";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 10;
        
        
        [self.view setAutoresizesSubviews:NO];        
        [self.view setBackgroundColor:FEED_TABLEVIEW_BGCOLOR];
        //[self.view setBackgroundColor:DEBUG_BACKGROUND_GRID];
        self.title = @"Poll";
        //if ( self == [self.navigationController.viewControllers objectAtIndex:0] )
        if ( [self.navigationController.viewControllers count] == 0 )
        {
            UIBarButtonItem *cancelbutton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
            [self.navigationItem setLeftBarButtonItem:cancelbutton];
        }
        
    }
    return self;
}

- (void)viewDidLoad{
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone]; 
    [super viewDidLoad];
    self.title = @"Poll";
    if ( self == [self.navigationController.viewControllers objectAtIndex:0] )
    {
        UIBarButtonItem *cancelbutton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
        [self.navigationItem setLeftBarButtonItem:cancelbutton];
    }


}

- (void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:@"Poll" equalTo:poll];
    [query whereKey:@"Type" equalTo:@"comment"];
    [query orderByDescending:@"createdAt"];
    [query setLimit:100];
    [query includeKey:@"FromUser"];
    return query;
}

- (PFObject *)objectAtIndex:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row - 1;
    if (index >= 0 && index < self.objects.count) {
        return [self.objects objectAtIndex:index];
    }
    return nil;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count + 2;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    if ( indexPath.row == 0 ){

        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        
        NSString *text = [poll objectForKey:@"Question"];
        CGSize expectedLabelSize = [text sizeWithFont:[UIFont fontWithName:SECTION_FONT_REGULAR size:14] constrainedToSize:CGSizeMake(275, 120) lineBreakMode:UILineBreakModeWordWrap];
        CGFloat h = expectedLabelSize.height + 37.0f;
        
        // 1 line details
        if ( h < 47.0f ) h = 47.0f;   
        
        // 4 line
        else if ( h > 14*7 ) h = 14*7.5;
        
        // 3 line
        else if ( h > 14*6 ) h = 14*6.5;
        
        // 2 line
        else if ( h > 14*4 ) h = 14*5;

        CGFloat hh = h;
        hh = ceilf(hh/7)*7;

        CGFloat hhh = ceilf(hh/14) * 14 + 28;
        CGFloat y = hhh;
        CGFloat m = 3;
        h = 60;
        y += 28 + 14+14;
        CGFloat likesL = [[[VLMCache sharedCache] likeCountForPollLeft:poll] floatValue];
        CGFloat likesR = [[[VLMCache sharedCache] likeCountForPollRight:poll] floatValue];
        CGFloat cx = 3;
        CGFloat cy = h + m*2 +2;
        CGFloat wwww = 40*5;

        if ( likesL > 0 ){
            for ( int i = 0; i < likesL; i++ ){
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
        cx = 3;
        cy = h + m*2 +2;
        
        if ( likesR > 0 ){
            for ( int i = 0; i < likesR; i++ ){
                cx += 30;
                if ( cx > wwww ){
                    cx = 5;
                    cy += 30;
                }
            }
            cy += 40;
        } else {
            cy += 10;
        }

        y += cy;
        y = ceilf(y/14)*14 + 14;
        y += 28 + 14;
        return y;
    }

    if ( indexPath.row >= self.objects.count + 1 ){
        return 100;
    }
    
    PFObject *row = [self objectAtIndex:indexPath];

    NSString *text = [row objectForKey:@"Description"];

    CGSize expectedLabelSize = [text sizeWithFont:[UIFont fontWithName:@"AmericanTypewriter" size:13] constrainedToSize:CGSizeMake(40*7-3-20-5-5, 49) lineBreakMode:UILineBreakModeWordWrap];

    CGFloat cellh = expectedLabelSize.height + 18;
    cellh = ceilf(cellh/7)*7  + 1;
    return cellh;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    // - - - - - - - - - - - - - - - - - - - - - - - - -
	
    static NSString *BarGraphIdentifier = @"firstbarcell";

    if ( indexPath.row == 0 ){
        PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BarGraphIdentifier];
        if ( cell == nil ){
            cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BarGraphIdentifier];            
            cell.autoresizesSubviews = NO;
            [self setupFirstCell:cell];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }

    // - - - - - - - - - - - - - - - - - - - - - - - - -
    static NSString *EmptyCommentIdentifier = @"emptycell";
    
    if (self.objects.count == 0){
        NSLog(@"here");
        PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EmptyCommentIdentifier];
        if (cell == nil){
            cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:EmptyCommentIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UILabel *nada = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 14*3)];
            [nada setFont:[UIFont fontWithName:@"AmericanTypewriter" size:13.0f]];
            [nada setBackgroundColor:[UIColor clearColor]];
            [nada setTextColor:TEXT_COLOR];
            [nada setText:@"No comments yet"];
            [cell.contentView addSubview:nada];
        }
        return cell;
    }
    // - - - - - - - - - - - - - - - - - - - - - - - - -

    static NSString *LastIdentifier = @"lastcell";

    if ( indexPath.row >= self.objects.count + 1 ){
        PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LastIdentifier];
        if ( cell == nil ){
            cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LastIdentifier];            
            cell.autoresizesSubviews = NO;
            cell.contentView.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.4];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }


    // - - - - - - - - - - - - - - - - - - - - - - - - -

    static NSString *CommentIdentifier = @"commentcell";
    VLMCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CommentIdentifier];
    if ( cell == nil ){
        cell = [[VLMCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CommentIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    PFObject *row = [self objectAtIndex:indexPath];
    PFUser *u = [row objectForKey:@"FromUser"];
    NSString *un = [u objectForKey:@"displayName"];
    NSString *text = [row objectForKey:@"Description"];
    [cell setUser:un];
    [cell setFile:[u objectForKey:@"profilePicSmall"]];
    [cell setComment:text];
    return cell;
}

#pragma mark - ()

- (void)setupFirstCell:(PFTableViewCell *)cell {
    CGFloat contentw = self.view.frame.size.width;

    PFUser *user = [poll objectForKey:@"User"];
    NSString *question = [poll objectForKey:@"Question"];
    NSString *username = [user objectForKey:@"displayName"];
    VLMSectionView *sectionhead = [[VLMSectionView alloc] initWithFrame:CGRectMake(0, 0, contentw, 0) andUserName:username andQuestion:question];
    [sectionhead setFile:[user objectForKey:@"profilePicSmall"]];
    [cell.contentView addSubview:sectionhead];
    
    //UIColor *bg = [UIColor colorWithHue:189.0f/360.0f saturation:0.79f brightness:0.87f alpha:0.5f];
    UIColor *bg = [UIColor whiteColor];
    CGFloat likesL = [[[VLMCache sharedCache] likeCountForPollLeft:poll] floatValue];
    CGFloat likesR = [[[VLMCache sharedCache] likeCountForPollRight:poll] floatValue];
    CGFloat leftwidth, rightwidth;
    
    NSDictionary *attr = [[VLMCache sharedCache] attributesForPoll:poll];
    self.likersL = [attr objectForKey:@"LikersLeft"];
    self.likersR = [attr objectForKey:@"LikersRight"];
    
    CGFloat wwww = 40*6;
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
    hh = ceilf(hh/7)*7;
    NSLog(@"%f",hh);
    if ( hh < 56 ) hh = 56;
    sectionhead.frame = CGRectMake(0, 0, contentw, hh);
    
    CGFloat hhh = ceilf(hh/14) * 14 + 14;
    CGFloat y = hhh;
    CGFloat x = 20;
    CGFloat h = 60;
    CGFloat m = 3;
    
    UILabel *pollbreakdown = [[UILabel alloc] initWithFrame:CGRectMake(x, y, wwww + 40, 28+14)];
    [pollbreakdown setFont:[UIFont fontWithName:@"AmericanTypewriter-Bold" size:13.0f]];
    [pollbreakdown setNumberOfLines:0.0f];
    [pollbreakdown setText:@"Votes So Far"];
    [pollbreakdown setTextAlignment:UITextAlignmentCenter];
    [pollbreakdown setBackgroundColor:TEXT_COLOR];
    [pollbreakdown setTextColor:[UIColor whiteColor]];
    [cell.contentView addSubview:pollbreakdown];
    
    y += 28 + 14+14;
    
    UIView *left = [[UIView alloc] initWithFrame:CGRectMake(x, y, leftwidth, h + m*2)];
    left.backgroundColor = bg;
    [cell.contentView addSubview:left];
    
    PFImageView *leftimage = [[PFImageView alloc] initWithFrame:CGRectMake(3, 3, h, h)];
    PFObject *leftphoto = [poll objectForKey:@"PhotoLeft"];
    [leftimage setFile:[leftphoto objectForKey:@"Original"]];
    [left addSubview:leftimage];
    
    UILabel *labelL = [[UILabel alloc] initWithFrame:CGRectMake(h + m + 5, 0, wwww-(h - m*2), h+m*2)];
    [labelL setFont:[UIFont fontWithName:@"AmericanTypewriter" size:13.0f]];
    [labelL setNumberOfLines:0.0f];
    [labelL setText:[leftphoto objectForKey:@"Caption"]];
    [labelL setBackgroundColor:[UIColor clearColor]];
    [left addSubview:labelL];
    
    UILabel *countL = [[UILabel alloc] initWithFrame:CGRectMake(wwww, 0, 40, h+m*2)];
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
            
            PFImageView *iv = [[PFImageView alloc] initWithFrame:CGRectMake(cx, cy, 25, 25)];
            PFFile *file = [u objectForKey:@"profilePicSmall"];
            [iv setFile:file];
            [left addSubview:iv];
            
            UIButton *clearbutton = [[UIButton alloc] initWithFrame:CGRectMake(left.frame.origin.x+cx, left.frame.origin.y + cy, 25, 25)];
            [clearbutton setBackgroundColor:[UIColor clearColor]];
            [clearbutton setTag:i];
            [clearbutton addTarget:self action:@selector(handleTapLikerL:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:clearbutton];
            
            cx += 30;
            if ( cx > wwww ){
                cx = 5;
                cy += 30;
            }
        }
        cy += 45;
    } else {
        cy += 17;
    }
    
    y += cy;
    
    UIView *right = [[UIView alloc] initWithFrame:CGRectMake(x, y, rightwidth, h+m*2)];
    right.backgroundColor = bg;
    [cell.contentView addSubview:right];
    
    PFImageView *rightimage = [[PFImageView alloc] initWithFrame:CGRectMake(3, 3, h, h)];
    PFObject *rightphoto = [poll objectForKey:@"PhotoRight"];
    [rightimage setFile:[rightphoto objectForKey:@"Original"]];
    [right addSubview:rightimage];
    
    UILabel *labelR = [[UILabel alloc] initWithFrame:CGRectMake(h + m + 5, 0, wwww-(h - m*2), h+m*2)];
    [labelR setFont:[UIFont fontWithName:@"AmericanTypewriter" size:13.0f]];
    [labelR setNumberOfLines:0.0f];
    [labelR setText:[rightphoto objectForKey:@"Caption"]];
    [labelR setBackgroundColor:[UIColor clearColor]];
    [right addSubview:labelR];
    
    UILabel *countR = [[UILabel alloc] initWithFrame:CGRectMake(wwww, 0, 40, h+m*2)];
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
            
            PFImageView *iv = [[PFImageView alloc] initWithFrame:CGRectMake(cx, cy, 25, 25)];
            PFFile *file = [u objectForKey:@"profilePicSmall"];
            [iv setFile:file];
            [right addSubview:iv];
            
            UIButton *clearbutton = [[UIButton alloc] initWithFrame:CGRectMake(right.frame.origin.x+cx, right.frame.origin.y + cy, 25, 25)];
            [clearbutton setBackgroundColor:[UIColor clearColor]];
            [clearbutton setTag:i];
            [clearbutton addTarget:self action:@selector(handleTapLikerR:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:clearbutton];
            
            cx += 30;
            if ( cx > wwww ){
                cx = 5;
                cy += 30;
            }
        }
        cy += 40;
    } else {
        cy += 10;
    }
    
    y += cy;
    y = ceilf(y/14)*14 + 14;
    
    UILabel *recentcomments = [[UILabel alloc] initWithFrame:CGRectMake(x, y, wwww + 40, 14*3)];
    [recentcomments setFont:[UIFont fontWithName:@"AmericanTypewriter-Bold" size:13.0f]];
    [recentcomments setNumberOfLines:0.0f];
    [recentcomments setText:@"Recent Comments"];
    [recentcomments setTextAlignment:UITextAlignmentCenter];
    [recentcomments setBackgroundColor:TEXT_COLOR];
    [recentcomments setTextColor:[UIColor whiteColor]];
    [cell.contentView addSubview:recentcomments];
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


@end
