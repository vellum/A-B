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
#import "UIPlaceholderTextView.h"
#import "MBProgressHUD.h"
#import "VLMFeedHeaderDelegate.h"

@interface VLMPollDetailController ()
@property (nonatomic, strong) NSArray *likersL;
@property (nonatomic, strong) NSArray *likersR;
@property (nonatomic, strong) UIPlaceHolderTextView *ptv;
@property (nonatomic) BOOL isEditing;
@property (nonatomic) BOOL isRootController;
@property (nonatomic) BOOL shouldScrollToComments;
@property (nonatomic) BOOL shouldScrollToCommentsAndPopKeyboard;

@end

@implementation VLMPollDetailController
@synthesize poll;
@synthesize likersL;
@synthesize likersR;
@synthesize ptv;
@synthesize isEditing;
@synthesize isRootController;
@synthesize shouldScrollToComments;
@synthesize shouldScrollToCommentsAndPopKeyboard;

- (id)initWithObject:(PFObject *)obj isRoot:(BOOL)isRoot{
    self = [super init];
    if ( self ){
        self.isEditing = NO;
        self.poll = obj;
        self.shouldScrollToComments = NO;
        self.shouldScrollToCommentsAndPopKeyboard = NO;
        
        self.loadingViewEnabled = NO;
        
        // The className to query on
        self.className = @"Activity";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 10;
        
        self.isRootController = isRoot;
        
        
        [self.view setAutoresizesSubviews:NO];        
        //[self.view setBackgroundColor:FEED_TABLEVIEW_BGCOLOR];
        //[self.view setBackgroundColor:DEBUG_BACKGROUND_GRID];
        [self.view setBackgroundColor:[UIColor clearColor]];
        self.title = @"Poll";
        if ( self.isRootController )
        {
            UIBarButtonItem *cancelbutton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
            [self.navigationItem setLeftBarButtonItem:cancelbutton];
        } else {
            /*
            UIBarButtonItem *backbutton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
            [self.navigationItem setLeftBarButtonItem:backbutton];
            [self.navigationItem setHidesBackButton:YES];
             */
        }

        
        UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 140)];
        footer.backgroundColor = [UIColor clearColor];
        
        UIView *fill = [[UIView alloc] initWithFrame:CGRectMake(0, 14, self.view.frame.size.width, 140-14)];
        [fill setBackgroundColor:[UIColor whiteColor]];
        [footer addSubview:fill];
        
        UIPlaceHolderTextView *textview = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(10, 5, self.view.frame.size.width-20, 140-14-10)];
        [textview setKeyboardType:UIKeyboardTypeAlphabet];
        [textview setBackgroundColor:[UIColor whiteColor]];
        [textview setPlaceholder:@"write comment"];
        [textview setFont:[UIFont fontWithName:@"AmericanTypewriter" size:14.0f]];
        [textview setReturnKeyType: UIReturnKeySend];
        [textview setDelegate:self];
        [textview setScrollsToTop:NO];
        
        self.ptv = textview;
        [fill addSubview:textview];
        self.tableView.tableFooterView = footer;
        
        if ( [[VLMCache sharedCache] attributesForPoll:poll] ){

            UIView *cell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [self heightfortableheader])];
            cell.autoresizesSubviews = NO;
            [self setupFirstCell:cell];
            self.tableView.tableHeaderView = cell;

        } else {
             @synchronized(self) {
                 PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
                 [query whereKey:@"Poll" equalTo:poll];
                 [query setCachePolicy:kPFCachePolicyNetworkOnly];
                 [query includeKey:@"FromUser"];
                 [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                     @synchronized(self){
                         
                         if ( !error ){
                             NSMutableArray *alikersL = [NSMutableArray array];
                             NSMutableArray *alikersR = [NSMutableArray array];
                             NSMutableArray *commenters = [NSMutableArray array];
                             BOOL isLikedByCurrentUserL = NO;
                             BOOL isLikedByCurrentUserR = NO;
                             PFObject *photoLeft = [self.poll objectForKey:@"LeftPhoto"];
                             
                             // loop through these mixed results
                             for (PFObject *activity in objects) {
                                 
                                 NSString *userID = [[activity objectForKey:@"FromUser"] objectId];
                                 NSString *cur = [[PFUser currentUser] objectId];
                                 
                                 // test for likes
                                 if ([[activity objectForKey:@"Type"] isEqualToString:@"like"]){
                                     
                                     // left photo likes
                                     if ([[[activity objectForKey:@"Photo"] objectId] isEqualToString:[photoLeft objectId]]){
                                         // add userid to array
                                         [alikersL addObject:[activity objectForKey:@"FromUser"]];
                                         
                                         if ( [userID isEqualToString:[[PFUser currentUser] objectId]] ){
                                             isLikedByCurrentUserL = YES;
                                         }
                                         
                                         // right photo likes
                                     } else {
                                         
                                         // add userid to array
                                         [alikersR addObject:[activity objectForKey:@"FromUser"]];
                                         
                                         if ( [userID isEqualToString: cur] ){
                                             isLikedByCurrentUserR = YES;
                                         }
                                         
                                     }
                                     
                                     
                                     // test for comments    
                                 } else if ([[activity objectForKey:@"Type"] isEqualToString:@"comment"]){
                                     
                                 }
                             }
                             
                             
                             [[VLMCache sharedCache] setAttributesForPoll:poll likersL:likersL likersR:likersR commenters:commenters isLikedByCurrentUserL:isLikedByCurrentUserL isLikedByCurrentUserR:isLikedByCurrentUserR];

                             UIView *cell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [self heightfortableheader])];
                             cell.autoresizesSubviews = NO;
                             [self setupFirstCell:cell];
                             self.tableView.tableHeaderView = cell;
                             
                             
                         }//end if (!error)
                         
                     }// end @synchronized
                 }];
             }
            
        }
        
        // Register to be notified when the keyboard will be shown to scroll the view
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];     

    }
    
    return self;
}


- (CGFloat) heightfortableheader{
        
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
- (void)viewDidLoad{
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone]; 
    [super viewDidLoad];
    self.title = @"Poll";
    
    if ( self == [self.navigationController.viewControllers objectAtIndex:0] )
    {
        UIBarButtonItem *cancelbutton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
        [self.navigationItem setLeftBarButtonItem:cancelbutton];
    }
    
    PFUser *u = [poll objectForKey:@"User"];
    PFUser *c = [PFUser currentUser];
    if ([[u objectId] isEqualToString:[c objectId]]) {
        UIBarButtonItem *dotdotdot = [[UIBarButtonItem alloc] initWithTitle:@"Remove" style:UIBarButtonItemStylePlain target:self action:@selector(dotdotdot:)];
        [self.navigationItem setRightBarButtonItem:dotdotdot];
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
    [query orderByAscending:@"createdAt"];
    [query setLimit:1000];
    [query includeKey:@"FromUser"];
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    return query;
}

- (PFObject *)objectAtIndex:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row;
    if (index >= 0 && index < self.objects.count) {
        return [self.objects objectAtIndex:index];
    }
    return nil;
}

- (void)objectsDidLoad:(NSError *)error{
    [super objectsDidLoad:error];
    if ( !shouldScrollToComments ) return;
    shouldScrollToComments = NO;

    NSIndexPath* ipath = [NSIndexPath indexPathForRow: self.objects.count-1 inSection: 0];
    [self.tableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];

}
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.objects.count == 0 ) return 1;
    return self.objects.count;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    if ( indexPath.row == 0 && self.objects.count == 0 ) return 56;
    
    PFObject *row = [self objectAtIndex:indexPath];

    NSString *text = [row objectForKey:@"Description"];

    CGSize expectedLabelSize = [text sizeWithFont:[UIFont fontWithName:@"AmericanTypewriter" size:13] constrainedToSize:CGSizeMake(40*7-3-20-5-5, 49) lineBreakMode:UILineBreakModeWordWrap];

    CGFloat cellh = expectedLabelSize.height + 18;
    cellh = ceilf(cellh/7)*7 + 28;
    return cellh;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    // - - - - - - - - - - - - - - - - - - - - - - - - -
    static NSString *EmptyCommentIdentifier = @"emptycell";
    
    if (self.objects.count == 0 && indexPath.row == 0){
        PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EmptyCommentIdentifier];
        if (self.isLoading) {
            cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"still-loading"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UILabel *nada = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 14*3)];
            [nada setFont:[UIFont fontWithName:@"AmericanTypewriter" size:13.0f]];
            [nada setBackgroundColor:[UIColor clearColor]];
            [nada setTextColor:TEXT_COLOR];
            [nada setText:@"Loading..."];
            [cell.contentView addSubview:nada];
            return cell;
        }
        if (cell == nil){
            cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:EmptyCommentIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UILabel *nada = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 14*3)];
            [nada setFont:[UIFont fontWithName:@"AmericanTypewriter" size:13.0f]];
            [nada setBackgroundColor:[UIColor clearColor]];
            [nada setTextColor:TEXT_COLOR];
            [nada setText:@"No comments yet."];
            [cell.contentView addSubview:nada];
        }
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
    [u fetchIfNeeded];
    NSString *un = [u objectForKey:@"displayName"];
    NSString *text = [row objectForKey:@"Description"];
    [cell setUser:un];
    [cell setFile:[u objectForKey:@"profilePicSmall"]];
    [cell setComment:text];
    [cell setTime:[row createdAt]];
    return cell;
}


#pragma mark - ()

- (void)setupFirstCell:(UIView *)cell {
    CGFloat contentw = self.view.frame.size.width;

    PFUser *user = [poll objectForKey:@"User"];
    [user fetchIfNeeded];
    NSString *question = [poll objectForKey:@"Question"];
    NSString *username = [user objectForKey:@"displayName"];
    VLMSectionView *sectionhead = [[VLMSectionView alloc] initWithFrame:CGRectMake(0, 0, contentw, 0) andUserName:username andQuestion:question];
    [sectionhead setDetailButtonEnabled:NO];
    [sectionhead setFile:[user objectForKey:@"profilePicSmall"]];
    [sectionhead setTime:[poll createdAt]];
    [sectionhead setDelegate:self];
    [cell addSubview:sectionhead];
    
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
        rightwidth = likesR / likesL * leftwidth;
    } else if ( likesL < likesR ){
        rightwidth = wwww;
        leftwidth = likesL / likesR * rightwidth;
    } else {
        if ( likesL == 0 ){
            leftwidth = rightwidth = 0;
        } else {
            leftwidth = rightwidth = wwww * 0.5f;
        }
    }
    
    CGFloat hh = sectionhead.frame.size.height;
    hh = ceilf(hh/7)*7;
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
    [cell addSubview:pollbreakdown];
    
    y += 28 + 14+14;
    
    UIView *left = [[UIView alloc] initWithFrame:CGRectMake(x, y, leftwidth, h + m*2)];
    left.backgroundColor = bg;
    [cell addSubview:left];
    
    PFImageView *leftimage = [[PFImageView alloc] initWithFrame:CGRectMake(3, 3, h, h)];
    [leftimage setBackgroundColor:[UIColor lightGrayColor]];
    [left addSubview:leftimage];

    UILabel *labelL = [[UILabel alloc] initWithFrame:CGRectMake(h + m + 5, 0, wwww-(h - m*2), h+m*2)];
    [labelL setFont:[UIFont fontWithName:@"AmericanTypewriter" size:13.0f]];
    [labelL setNumberOfLines:0.0f];
    [labelL setBackgroundColor:[UIColor clearColor]];
    [left addSubview:labelL];

    UILabel *countL = [[UILabel alloc] initWithFrame:CGRectMake(wwww, 0, 40, h+m*2)];
    [countL setFont:[UIFont fontWithName:@"AmericanTypewriter" size:13.0f]];
    [countL setNumberOfLines:0.0f];
    [countL setTextAlignment:UITextAlignmentCenter];
    [countL setBackgroundColor:[UIColor clearColor]];
    [countL setTextColor:TEXT_COLOR];
    [left addSubview:countL];
    
    PFObject *leftphoto = [poll objectForKey:@"PhotoLeft"];
    PFFile *leftthumb = [leftphoto objectForKey:@"Original"];
    [leftimage setFile:leftthumb];
    [leftimage loadInBackground];
    [labelL setText:[leftphoto objectForKey:@"Caption"]];
    [countL setText:[NSString stringWithFormat:@"%d", (int)likesL]];
    
    CGFloat cx = 3;
    CGFloat cy = h + m*2 +2;
    if ( likesL > 0 ){
        for ( int i = 0; i < [likersL count]; i++ ){
            
            PFImageView *iv = [[PFImageView alloc] initWithFrame:CGRectMake(cx, cy, 25, 25)];
            [iv setBackgroundColor:[UIColor lightGrayColor]];
            PFUser *u = [likersL objectAtIndex:i];
            [u fetchIfNeeded];

            [left addSubview:iv];
            PFFile *file = [u objectForKey:@"profilePicSmall"];
            [iv setFile:file];
            [iv loadInBackground];

            /*
            [u fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error){
                if ( !error ){
                    PFFile *file = [u objectForKey:@"profilePicSmall"];
                    [iv setFile:file];
                }
            }];
             */
            
            UIButton *clearbutton = [[UIButton alloc] initWithFrame:CGRectMake(left.frame.origin.x+cx, left.frame.origin.y + cy, 25, 25)];
            [clearbutton setBackgroundColor:[UIColor clearColor]];
            [clearbutton setTag:i];
            [clearbutton addTarget:self action:@selector(handleTapLikerL:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:clearbutton];
            
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
    [cell addSubview:right];
    
    PFImageView *rightimage = [[PFImageView alloc] initWithFrame:CGRectMake(3, 3, h, h)];
    [rightimage setBackgroundColor:[UIColor lightGrayColor]];
    [right addSubview:rightimage];

    UILabel *labelR = [[UILabel alloc] initWithFrame:CGRectMake(h + m + 5, 0, wwww-(h - m*2), h+m*2)];
    [labelR setFont:[UIFont fontWithName:@"AmericanTypewriter" size:13.0f]];
    [labelR setNumberOfLines:0.0f];
    [labelR setBackgroundColor:[UIColor clearColor]];
    [right addSubview:labelR];

    UILabel *countR = [[UILabel alloc] initWithFrame:CGRectMake(wwww, 0, 40, h+m*2)];
    [countR setFont:[UIFont fontWithName:@"AmericanTypewriter" size:13.0f]];
    [countR setNumberOfLines:0.0f];
    [countR setBackgroundColor:[UIColor clearColor]];
    [countR setTextColor:TEXT_COLOR];
    [countR setTextAlignment:UITextAlignmentCenter];
    [countR setText:[NSString stringWithFormat:@"%d", (int)likesR]];
    [right addSubview:countR];
    
    PFObject *rightphoto = [poll objectForKey:@"PhotoRight"];
    [rightimage setFile:[rightphoto objectForKey:@"Original"]];
    [rightimage loadInBackground];
    [labelR setText:[rightphoto objectForKey:@"Caption"]];
    
    
    cx = 3;
    cy = h + m*2 +2;
    if ( likesR > 0 ){
        for ( int i = 0; i < [likersR count]; i++ ){
            PFImageView *iv = [[PFImageView alloc] initWithFrame:CGRectMake(cx, cy, 25, 25)];
            [iv setBackgroundColor:[UIColor lightGrayColor]];
            [right addSubview:iv];
            UIButton *clearbutton = [[UIButton alloc] initWithFrame:CGRectMake(right.frame.origin.x+cx, right.frame.origin.y + cy, 25, 25)];
            [clearbutton setBackgroundColor:[UIColor clearColor]];
            [clearbutton setTag:i];
            [clearbutton addTarget:self action:@selector(handleTapLikerR:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:clearbutton];

            PFUser *u = [likersR objectAtIndex:i];
            [u fetchIfNeeded];
            PFFile *file = [u objectForKey:@"profilePicSmall"];
            [iv setFile:file];
            [iv loadInBackground];
            /*
            [u fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error){
                if ( !error ){
                    PFFile *file = [u objectForKey:@"profilePicSmall"];
                    [iv setFile:file];
                }
            }];
             */

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
    [recentcomments setText:@"Comments"];
    [recentcomments setTextAlignment:UITextAlignmentCenter];
    [recentcomments setBackgroundColor:TEXT_COLOR];
    [recentcomments setTextColor:[UIColor whiteColor]];
    [cell addSubview:recentcomments];
}

- (void)cancel:(id)sender{
    
    [self dismissModalViewControllerWithPushDirection:kCATransitionFromLeft];
    
}

- (void)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleTapLikerL:(id)sender{
    NSInteger index = [sender tag];
    PFUser *user = [self.likersL objectAtIndex:index];
    [self openUserDetail:user];
}

- (void)handleTapLikerR:(id)sender{
    NSInteger index = [sender tag];
    PFUser *user = [self.likersR objectAtIndex:index];
    [self openUserDetail:user];
}

- (void)dotdotdot:(id)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove" otherButtonTitles:nil];
    [actionSheet showInView:self.view];
    
}
#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSLog(@"pppp");
    } else if (buttonIndex == 1) {
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    int newlen = [[textView text] length] - range.length + text.length;
    if ( newlen > 140 ) {
        return NO;
    }
    
    if([text isEqualToString:@"\n"]) {
        [self.view endEditing:YES];
        self.isEditing = NO;
        [self textFieldShouldReturn:textView];
        return NO;
    }

    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextView *)textView {
    NSString *trimmedComment = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    PFObject *comment = [PFObject objectWithClassName:@"Activity"];
    if (trimmedComment.length != 0 && [self.poll objectForKey:@"User"]) {

        
        [comment setValue:trimmedComment forKey:@"Description"]; 
        [comment setValue:[self.poll objectForKey:@"User"] forKey:@"ToUser"];
        [comment setValue:[PFUser currentUser] forKey:@"FromUser"];
        [comment setValue:self.poll forKey:@"Poll"];   
        [comment setValue:@"comment" forKey:@"Type"];

        PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [ACL setPublicReadAccess:YES];
        comment.ACL = ACL;

        //[[PAPCache sharedCache] incrementCommentCountForPhoto:self.photo];

        // Show HUD view
        [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];

        // If more than 5 seconds pass since we post a comment, stop waiting for the server to respond
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(handleCommentTimeout:) userInfo:[NSDictionary dictionaryWithObject:comment forKey:@"comment"] repeats:NO];

        [comment saveEventually:^(BOOL succeeded, NSError *error) {
            [timer invalidate];
            
            if (error && [error code] == kPFErrorObjectNotFound) {
                
                //[[PAPCache sharedCache] decrementCommentCountForPhoto:self.photo];

                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not post comment" message:@"This poll was deleted by its owner" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                // refresh cache
            }
            
            [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
            [self loadObjects];
        }];
    }
    [textView setText:@""];
    self.isEditing = NO;
    return [textView resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification*)note {
    // Scroll the view to the comment text box
    NSDictionary* info = [note userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height-kbSize.height) animated:YES];
    self.isEditing = YES;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.ptv resignFirstResponder];
    self.isEditing = NO;
}


#pragma mark - VLMFeedHeaderDelegate

- (void)didTapPoll:(NSInteger)section{
    NSLog(@"tapped poll");
}

- (void)didTapUser:(NSInteger)section{
    PFUser *user = [poll objectForKey:@"User"];
    if ( user == nil ) return;
    [self openUserDetail:user];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PFObject *comment = [self objectAtIndex:indexPath];
    if (!comment) return;
    PFUser *u = [comment objectForKey:@"FromUser"];
    [self openUserDetail:u];
}

- (void)openUserDetail:(PFUser *)user{
    if ( !user ) return;
    if ( self.isEditing ) return;
    VLMUserDetailController *userdetail = [[VLMUserDetailController alloc] initWithObject:user isRoot:NO];
    UINavigationController *navigationController = self.navigationController;
    [navigationController pushViewController:userdetail animated:YES];
}


- (void)handleCommentTimeout:(NSTimer *)aTimer {
    [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Comment" message:@"Your comment will be posted next time there is an Internet connection."  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
    [alert show];
}

- (void)scrollToComments{
    self.shouldScrollToComments = YES;
}
- (void)scrollToCommentsAndPopKeyboard{
    self.shouldScrollToCommentsAndPopKeyboard = YES;
}

@end
