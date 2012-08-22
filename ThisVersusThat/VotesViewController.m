//
//  VotesViewController.m
//  ThisVersusThat
//
//  Created by David Lu on 8/18/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "VotesViewController.h"

#import "VotesViewController.h"
#import "VLMConstants.h"
#import "UIViewController+Transitions.h"
#import "VLMCache.h"
#import "VLMUtility.h"
#import <QuartzCore/QuartzCore.h>
#import "VLMSectionView.h"
#import "VLMCell.h"
#import "LoadMoreCell.h"
#import "VLMFeedHeaderDelegate.h"
#import "VLMPollDetailController.h"
#import "VLMGenericTapDelegate.h"
#import "VLMUserDetailController.h"



@interface VotesViewController ()
@property (nonatomic, strong) NSMutableDictionary *outstandingQueries;
@property (nonatomic) NSInteger resultcount;
@property (nonatomic, strong) NSMutableSet *reusableSectionHeaderViews;
@property (nonatomic) BOOL isRootController;
@property (nonatomic) int lastknowncount;

@property (nonatomic, strong) UILabel *numPollsLabel;
@property (nonatomic, strong) UILabel *numVotesLabel;
@property (nonatomic, strong) UILabel *numFollowingLabel;
@property (nonatomic, strong) UILabel *numFollowersLabel;

@property (nonatomic) NSInteger recognizedPanDirection;
@property (unsafe_unretained, nonatomic) UITableViewCell *selectedCell;
@property (nonatomic, strong) UIPanGestureRecognizer *localPGR;

@end

@implementation VotesViewController
@synthesize user;
@synthesize outstandingQueries;
@synthesize resultcount;
@synthesize reusableSectionHeaderViews;
@synthesize isRootController;
@synthesize numPollsLabel;
@synthesize numVotesLabel;
@synthesize numFollowersLabel;
@synthesize numFollowingLabel;
@synthesize recognizedPanDirection;
@synthesize selectedCell;
@synthesize localPGR;
@synthesize lastknowncount;
#pragma mark - NSObject

- (id)initWithObject:(PFUser *)obj isRoot:(BOOL)isRoot{
    self = [super init];
    if ( self ){
        self.user = obj;
        self.loadingViewEnabled = NO;
        self.outstandingQueries = [NSMutableDictionary dictionary];
        self.className = @"Activity";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 10;
        self.reusableSectionHeaderViews = [NSMutableSet setWithCapacity:3];
        self.resultcount = 0;
        self.isRootController = isRoot;
        [self.view setAutoresizesSubviews:NO];        
        [self.view setBackgroundColor:[UIColor clearColor]];
        [self.tableView setBackgroundColor:[UIColor clearColor]];
        lastknowncount = 0;
    }
    
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad{    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone]; 
    
    [super viewDidLoad];
    
    // set up a pan gesture recognizer to distinguish horizontal pans from vertical ones
    UIPanGestureRecognizer *pgr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    
    // look for the factory installed pangesturerecognizer in uiscrollview
    // ask it to require our pan recognizer to fail before registering scrollview touches
    for (UIGestureRecognizer* gr in self.tableView.gestureRecognizers) {
        if ( [gr isKindOfClass:[UIPanGestureRecognizer class]] ){
            [gr requireGestureRecognizerToFail:pgr];
        }
    }
    
    [pgr setDelegate:self];
    self.localPGR = pgr;
    [self.tableView addGestureRecognizer:self.localPGR];
    
    // the default recognized state is unknown
    self.recognizedPanDirection = FUCKING_UNKNOWN;
    
    
    [self.view setBackgroundColor:FEED_TABLEVIEW_BGCOLOR];
    
    self.title = @"Voted On";
    
    if ( self.isRootController )
    {
        UIBarButtonItem *cancelbutton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
        [self.navigationItem setLeftBarButtonItem:cancelbutton];
        [self.navigationItem setHidesBackButton:YES];
    }
    
    
}

- (void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.localPGR.delegate = nil;
    [self.tableView removeGestureRecognizer:self.localPGR];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - PFQueryTableViewController

- (void)loadObjects{
    
    [super loadObjects];
    lastknowncount = 0;
    PFQuery *q = [self queryForTable];
    [q countObjectsInBackgroundWithBlock:^(int number, NSError *error){
        if ( !error ){
            self.resultcount = number;
            NSInteger lastsection = [self numberOfSectionsInTableView:self.tableView] - 1;
            NSInteger lastrow = [self tableView:self.tableView numberOfRowsInSection:lastsection] - 1;
            NSArray *arr = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:lastrow inSection:lastsection]];
            [self.tableView reloadRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationNone];

        }
    }];
}

- (void)objectsDidLoad:(NSError *)error{
    [super objectsDidLoad:error];
    
    for( int i = lastknowncount; i < self.objects.count; i++){
        PFObject *o = [self.objects objectAtIndex:i];
        PFObject *poll = [o objectForKey:@"Poll"];
        if ( poll ) {
            [[VLMCache sharedCache] removeAttributesForPoll:poll];    
        }
    }
    lastknowncount = self.objects.count;

}

- (PFQuery *)queryForTable {
    PFQuery *polls = [PFQuery queryWithClassName:self.className];
    [polls whereKey:@"FromUser" equalTo:self.user];
    [polls whereKeyExists:@"Poll"];
    [polls whereKey:@"Type" equalTo:@"like"];
    [polls includeKey:@"ToUser"];
    [polls includeKey:@"Poll"];
    [polls includeKey:@"Poll.PhotoLeft"];
    [polls includeKey:@"Poll.PhotoRight"];
    [polls includeKey:@"Poll.createdAt"];
    [polls setCachePolicy:kPFCachePolicyNetworkOnly];
    [polls setLimit:1000];
    [polls orderByDescending:@"createdAt"];
    return polls;
}

- (PFObject *)objectAtIndex:(NSIndexPath *)indexPath {
    if (indexPath.section < self.objects.count) {
        return [self.objects objectAtIndex:indexPath.section];
    }
    return nil;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = self.objects.count;
    if (self.paginationEnabled){
        return sections + 1;
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}


#pragma mark - UITableViewDelegate

// header

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (section == self.objects.count){
        return 0;
    }
    
    PFObject *obj = [self.objects objectAtIndex:section];
    
    if ( obj == nil ) return 0;

    PFObject *poll = [obj objectForKey:@"Poll"];
    if ( poll == nil ) return 0;
          
    NSString *text = [poll objectForKey:@"Question"];
    CGSize expectedLabelSize = [text sizeWithFont:[UIFont fontWithName:SECTION_FONT_REGULAR size:14] constrainedToSize:CGSizeMake(275, 120) lineBreakMode:UILineBreakModeWordWrap];
    CGFloat h = expectedLabelSize.height + 37.0f;
    
    // 1 line details
    if ( h < 47.0f ) return 47.0f;   
    
    // 4 line
    if ( h > 14*7 ) return 14*7.5;
    
    // 3 line
    if ( h > 14*6 ) return 14*6.5;
    
    // 2 line
    if ( h > 14*4 ) return 14*5;
    
    return h;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == self.objects.count) {
        // Load More section
        return nil;
    }
    
    PFObject *obj = [self.objects objectAtIndex:section];
    if ( obj == nil ) return nil;

    PFObject *poll = [obj objectForKey:@"Poll"];
    if ( poll == nil ) return nil;

    NSString *text = [poll objectForKey:@"Question"];
    PFUser *u = [obj objectForKey:@"ToUser"];
    NSString *displayname = [u objectForKey:@"displayName"];
    PFFile *avatar = [u objectForKey:@"profilePicSmall"];
    
    CGFloat winw = [[UIScreen mainScreen] bounds].size.width;
    VLMSectionView *customview = [self dequeueReusableSectionHeaderView];
    if (!customview){
        customview = [[VLMSectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, winw, 60.0f) andUserName:displayname andQuestion:text];
        [self.reusableSectionHeaderViews addObject:customview];
    } else {
        [customview setUserName:displayname andQuestion:text];
    }
    [customview reset];
    [customview setTime:[poll createdAt]];
    [customview setFile:avatar];
    customview.delegate = self;
    customview.section = section;
    
    return customview;
}

// cell

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( indexPath.section >= [self.objects count] ){
        UITableViewCell *cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        return cell;
    }
    
    PFObject *obj = [self.objects objectAtIndex:indexPath.section];
    if ( obj == nil ) return nil;

    PFObject *poll = [obj objectForKey:@"Poll"];
    if ( poll == nil ) return nil;

	// identifier
	static NSString *FeedCellIdentifier = @"PollCell";
	
	// get an unused cell from existing pool of tableviewcells
	VLMCell *cell = [tableView dequeueReusableCellWithIdentifier:FeedCellIdentifier];
	
	// if no cell is available create a new one
	if (cell == nil) {
        cell = [[VLMCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FeedCellIdentifier];
        [cell setDelegate:self];
	} else {
        //[cell setInitialPage:YES];
    }
    [cell resetCell];
    [cell setPoll:poll];
    [cell setContentVisible:NO];
    cell.contentView.hidden = NO;
    
    PFObject *photoLeft = [poll objectForKey:@"PhotoLeft"];
    
    NSDictionary *attributesForPoll = [[VLMCache sharedCache] attributesForPoll:poll];
    PFCachePolicy poly = kPFCachePolicyNetworkOnly;
    
    // check if we've stored metadata (likes, comments) for this poll
    if (attributesForPoll) {
        NSNumber *leftcount = [[VLMCache sharedCache] likeCountForPollLeft:poll];
        NSNumber *rightcount = [[VLMCache sharedCache] likeCountForPollRight:poll];
        [cell setLeftCount:[leftcount integerValue] andRightCount:[rightcount integerValue]];
        
        BOOL isLikedByCurrentUserL = [[VLMCache sharedCache] isPollLikedByCurrentUserLeft:poll];
        BOOL isLikedByCurrentUserR = [[VLMCache sharedCache] isPollLikedByCurrentUserRight:poll];
        BOOL isVotedByCurrentUser = [[VLMCache sharedCache] isPollCommentedByCurrentUser:poll];
        NSNumber *commentcount = [[VLMCache sharedCache] commentCountForPoll:poll];

        [cell setPersonalLeftCount:isLikedByCurrentUserL ? 1 : 0 andPersonalRightCount:isLikedByCurrentUserR ? 1: 0];
        [cell setCommentCount:[commentcount integerValue] commentedByCurrentUser:isVotedByCurrentUser];  
        
        [cell setContentVisible:YES];

        
        // if not, stuff query results in the cache
    } else {
        
        if ( ![PFUser currentUser] ) return cell;
        
        @synchronized(self) {
            
            NSNumber *outstandingQueryStatus = [self.outstandingQueries objectForKey:[NSNumber numberWithInt:indexPath.section]];
            
            if (!outstandingQueryStatus) {
                
                PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
                [query whereKey:@"Poll" equalTo:poll];
                [query setCachePolicy:poly];
                [query includeKey:@"FromUser"];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    @synchronized(self){
                        
                        if ( !error ){
                            NSMutableArray *likersL = [NSMutableArray array];
                            NSMutableArray *likersR = [NSMutableArray array];
                            NSMutableArray *comments = [NSMutableArray array];
                            BOOL isLikedByCurrentUserL = NO;
                            BOOL isLikedByCurrentUserR = NO;
                            BOOL isCommentedByCurrentUser = NO;
                            // loop through these mixed results
                            for (PFObject *activity in objects) {
                                
                                NSString *userID = [[activity objectForKey:@"FromUser"] objectId];
                                NSString *cur = [[PFUser currentUser] objectId];
                                
                                // test for likes
                                if ([[activity objectForKey:@"Type"] isEqualToString:@"like"]){
                                    
                                    // left photo likes
                                    if ([[[activity objectForKey:@"Photo"] objectId] isEqualToString:[photoLeft objectId]]){
                                        // add userid to array
                                        [likersL addObject:[activity objectForKey:@"FromUser"]];
                                        
                                        if ( [userID isEqualToString:[[PFUser currentUser] objectId]] ){
                                            isLikedByCurrentUserL = YES;
                                        }
                                        
                                        // right photo likes
                                    } else {
                                        
                                        // add userid to array
                                        [likersR addObject:[activity objectForKey:@"FromUser"]];
                                        
                                        if ( [userID isEqualToString: cur] ){
                                            isLikedByCurrentUserR = YES;
                                        }
                                        
                                    }
                                    
                                    
                                    // test for comments    
                                } else if ([[activity objectForKey:@"Type"] isEqualToString:@"comment"]){
                                    NSLog(@"adding a comment");
                                    [comments addObject:activity];
                                    
                                    if ( [userID isEqualToString:cur] ){
                                        isCommentedByCurrentUser = YES;
                                    }

                                }
                            }
                            
                            
                            [[VLMCache sharedCache] setAttributesForPoll:poll likersL:likersL likersR:likersR commenters:comments isLikedByCurrentUserL:isLikedByCurrentUserL isLikedByCurrentUserR:isLikedByCurrentUserR isCommentedByCurrentUser:isCommentedByCurrentUser];
                            
                            // when fast scrolling, the current (presumably recycled) cell will fall out of sync
                            // so only update content if the cell's poll matches the current one
                            if ( [[poll objectId] isEqualToString:[cell pollID]] ){
                                NSNumber *leftcount = [[VLMCache sharedCache] likeCountForPollLeft:poll];
                                NSNumber *rightcount = [[VLMCache sharedCache] likeCountForPollRight:poll];
                                BOOL isVotedByCurrentUser = [[VLMCache sharedCache] isPollCommentedByCurrentUser:poll];
                                NSNumber *commentcount = [[VLMCache sharedCache] commentCountForPoll:poll];
                                
                                [cell setLeftCount:[leftcount integerValue] andRightCount:[rightcount integerValue]];
                                [cell setPersonalLeftCount:isLikedByCurrentUserL ? 1 : 0 andPersonalRightCount:isLikedByCurrentUserR ? 1: 0];
                                [cell setCommentCount:[commentcount integerValue] commentedByCurrentUser:isVotedByCurrentUser];  
                                [cell setContentVisible:YES];
                            }
                            
                        }//end if (!error)
                        
                    }// end @synchronized
                    
                }];
                
                
            }// end if (!outstandingquerystatus)
            
        }// end synchronnized
        
    } // end else
    
    //[cell setTv:self];
    BOOL isLeft = [[VLMCache sharedCache] directionForPoll:poll];
    [cell setInitialPage:isLeft];
    
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.objects.count) {
        // Load More Section
        return 74.0f;
    }
    // otherwise, row heights are fixed
    return 321.0f + 28 + 14;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    
    LoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[LoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier color:[UIColor colorWithWhite:0.2f alpha:1.0f] disabledcolor:[UIColor colorWithWhite:0.2f alpha:0.5f]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setDelegate:self];
    }
    if ( self.objects.count < self.resultcount ){
        [cell reset:YES isLoading:self.isLoading];
    }
    else {
        [cell reset:NO isLoading:self.isLoading];
    }
    return cell;
}


// footer

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.tableView.bounds.size.width, 16.0f)];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == self.objects.count) {
        return 0.0f;
    }
    return 0.0f;
}




#pragma mark - ()

- (VLMSectionView *)dequeueReusableSectionHeaderView{
    for (VLMSectionView *sectionHeaderView in self.reusableSectionHeaderViews) {
        if (!sectionHeaderView.superview) {
            // we found a section header that is no longer visible
            return sectionHeaderView;
        }
    }
    return nil;
}

- (void)setDirection:(BOOL)isLeft ForPoll:(PFObject *)poll{
    @synchronized(self){
        [[VLMCache sharedCache] setDirection:isLeft ForPoll:poll];
    }
}

- (void)cancel:(id)sender{
    
    [self dismissModalViewControllerWithPushDirection:kCATransitionFromLeft];
    
}

- (void)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

// lightweight analysis on detected pan gestures
-(void) handlePan:(id)sender{
    
    // cast sender to uipangesturerecognizer
    UIPanGestureRecognizer *pgr = ( UIPanGestureRecognizer *)sender;
    
    // cast our uiview to uiscrollview
    UIScrollView *scrollview = (UIScrollView *) self.tableView;
    
    // look at the pan gesture's internal state
    switch (pgr.state) {
            
            // when the pan starts, make sure the scrollview is enabled
            // and reset the recognized pan direction to unknown
        case UIGestureRecognizerStateBegan:
            self.recognizedPanDirection = FUCKING_UNKNOWN;
            scrollview.scrollEnabled = YES;
            //NSLog(@"pan began");
            break;
            
            // when the pan ends, make sure we reset the state
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            
            if ( self.recognizedPanDirection == FUCKING_HORIZONTAL && selectedCell != nil)
            {
                // reset cell
                [(VLMCell *)selectedCell resetAnimated:YES];
            }
            self.recognizedPanDirection = FUCKING_UNKNOWN;
            scrollview.scrollEnabled = YES;
            //NSLog(@"pan ended");
            
            // do nothing otherwise
        default:
            break;
    }
    
    // pan direction unknown
    if ( self.recognizedPanDirection == FUCKING_UNKNOWN ) {
        
        
        // accumulated translation from start point
        CGPoint p = [pgr translationInView:self.view];
        
        // establish a deadzone of 50 x 24
        // this is a generous allowance for which we ignore wiggly movement
        CGSize deadzone = DEAD_ZONE;
        
        // vertical pans will cancel this gesture recognizer 
        // and let the scrollview's recognizer to take over
        if ( p.y > deadzone.height/2 || p.y < -deadzone.height/2 ) {
            
            // set the recognized direction
            self.recognizedPanDirection = FUCKING_VERTICAL;
            
            // find the pan gesture recognizer in the scrollview
            // and set its translation value to zero
            // this means that we scroll based on fresh data (not accumulated translation data)
            for (UIGestureRecognizer* gr in self.tableView.gestureRecognizers) {
                if ( [gr isKindOfClass:[UIPanGestureRecognizer class]] && gr != pgr )
                {
                    UIPanGestureRecognizer *tvpgr = (UIPanGestureRecognizer *)gr;
                    [tvpgr setTranslation:CGPointZero inView:self.tableView];
                }
            }
            
            // cancel the recognizer and restart it for capturing the next pan
            // the current pan will continue, but the scrollview will handle it
            pgr.enabled = NO;
            pgr.enabled = YES;
            
            // a little debugging
            //NSLog(@"recognized vertical pan");
            
            /*
             // do some optimization here for scrolling perf
             if ( self.selectedCell != nil ){
             VLMCell *c = (VLMCell *) self.selectedCell;
             c.contentView.clipsToBounds = YES;
             }*/
            
        } 
        else if ( p.x > deadzone.width/2 || p.x < -deadzone.width/2 ) {
            
            // horizontal pan resets the translation point 
            // so that translationinview: reports a delta from last event
            self.recognizedPanDirection = FUCKING_HORIZONTAL;
            [pgr setTranslation:CGPointZero inView:self.view];
            
            // disable the scrollview
            scrollview.scrollEnabled = NO;
            
            // extract the selected cell from the tableview 
            // (we're going to perform horizontal swipes on it)
            UITableView *tv = self.tableView;
            CGPoint location = [pgr locationInView:tv];
            NSIndexPath *path = [tv indexPathForRowAtPoint:location];
            UITableViewCell *cell  = [tv cellForRowAtIndexPath:path];
            self.selectedCell = cell;
            [(VLMCell *)cell killAnimations];
            //NSLog(@"recognized horizontal pan");
        }
    }
    
    // now handle horizontal pan, if one has been detected
    if ( self.recognizedPanDirection == FUCKING_HORIZONTAL ) {
        
        CGPoint delta = [pgr translationInView:self.view];
        [pgr setTranslation:CGPointZero inView:self.view];
        
        if ( self.selectedCell != nil ){
            VLMCell *c = (VLMCell *) self.selectedCell;
            CGPoint velocity = [pgr velocityInView:self.view];
            [c translateByX:delta.x withVelocity:velocity.x];
            
        }
        //NSLog( @"dx:%f", delta.x );
        
    }
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer{
    // currently, our gesture recognizer is always on for the feed
    // we probably want to turn off gesturerecco if we're not dealing with votable rows
    return YES;
}

// recognize gestures at same time as scrollview
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}


#pragma mark - VLMFeedHeaderDelegate

- (void)didTapPoll:(NSInteger)section{
    
    PFObject *obj = [self.objects objectAtIndex:section];
    if ( obj == nil ) return;
    
    PFObject *poll = [obj objectForKey:@"Poll"];
    if ( poll == nil ) return;
    
    if ( [[VLMCache sharedCache] attributesForPoll:poll] == nil ) return;
    
    VLMPollDetailController *polldetail = [[VLMPollDetailController alloc] initWithObject:poll isRoot:NO];
    [self.navigationController pushViewController:polldetail animated:YES];
}

- (void)didTapUser:(NSInteger)section{
    PFObject *obj = [self.objects objectAtIndex:section];
    if ( obj == nil ) return;
    
    PFObject *poll = [obj objectForKey:@"Poll"];
    if ( poll == nil ) return;

    PFUser *u = [obj objectForKey:@"ToUser"];
    if ( u == nil ) return;
    
    VLMUserDetailController *userdetail = [[VLMUserDetailController alloc] initWithObject:u isRoot:NO];
    [self.navigationController pushViewController:userdetail animated:YES];
}

#pragma mark - VLMGenericTapDelegate

- (void)didTap:(id)sender{
    [self loadNextPage];
}


#pragma mark - VLMPopModalDelegate

- (void)popPollDetail:(PFObject *)poll{}
- (void)popUserDetail:(PFUser *)user{}
- (void)popPollDetailAndScrollToComments:(PFObject *)poll{
    if (!poll) return;
    VLMPollDetailController *polldetail = [[VLMPollDetailController alloc] initWithObject:poll isRoot:NO];
    [polldetail scrollToComments];
    [self.navigationController pushViewController:polldetail animated:YES];
}

@end
