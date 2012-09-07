//
//  VLMFeedTableViewController.m
//  ThisVersusThat
//
//  Created by David Lu on 7/17/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "VLMFeedTableViewController.h"
#import "VLMConstants.h"
#import "AppDelegate.h"
#import "VLMSectionView.h"
#import "VLMCell.h"
#import "Parse/Parse.h"
#import "VLMCache.h"
#import "LoadMoreCell.h"
#import "VLMFeedHeaderDelegate.h"
#import "VLMTapDelegate.h"
#import "VLMGenericTapDelegate.h"
#import "VLMPopModalDelegate.h"

@interface VLMFeedTableViewController()

@property (nonatomic, assign) BOOL shouldReloadOnAppear;
@property (nonatomic, strong) NSMutableSet *reusableSectionHeaderViews;
@property (nonatomic, strong) NSMutableDictionary *outstandingQueries;
@property (strong, nonatomic) VLMFeedHeaderController *headerViewController;
@property (nonatomic) CGRect contentRect;
@property (nonatomic) CGFloat contentOffsetY;
@property (nonatomic) NSInteger resultcount;
@property (nonatomic) VLMFeedType currentFeedType;
@property (nonatomic) BOOL shouldWipeCache;
@property (nonatomic) PFQuery *lastquery;
@end



@implementation VLMFeedTableViewController

@synthesize headerViewController;
@synthesize contentRect;
@synthesize contentOffsetY;
@synthesize reusableSectionHeaderViews;
@synthesize shouldReloadOnAppear;
@synthesize outstandingQueries;
@synthesize delegate;
@synthesize resultcount;
@synthesize currentFeedType;
@synthesize shouldWipeCache;
@synthesize lastquery;
#pragma mark - NSObject

-(id) initWithHeader:(VLMFeedHeaderController *) headerController {
    self = [super initWithStyle:UITableViewStylePlain];
    if ( headerController ) {

        self.loadingViewEnabled = NO;
        
        self.headerViewController = headerController;

        self.outstandingQueries = [NSMutableDictionary dictionary];
        
        // The className to query on
        self.className = POLL_CLASS_KEY;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 10;
        
        // Improve scrolling performance by reusing UITableView section headers
        self.reusableSectionHeaderViews = [NSMutableSet setWithCapacity:3];

        self.shouldReloadOnAppear = NO;
        self.resultcount = 0;

        [self.view setAutoresizesSubviews:NO];        
        
        [self.view setBackgroundColor:[UIColor clearColor]];
        //[self.view setBackgroundColor:DEBUG_BACKGROUND_GRID];
        [self updatelayout];

        self.currentFeedType = VLMFeedTypeAll;
        self.shouldWipeCache = YES;
        
    }
    return self;
}



#pragma mark - UIViewController

- (void)viewDidLoad {
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone]; 
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidPublishPoll:) name:@"cc.vellum.thisversusthat.notification.userdidpublishpoll" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidDeletePhoto:) name:@"cc.vellum.thisversusthat.notification.userdiddeletepoll" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userFollowingChanged:) name:@"cc.vellum.thisversusthat.notification.userfollowingdidchange" object:nil];
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLikeOrUnlikePhoto:) name:@"cc.vellum.thisversusthat.notification.userdidlikeorunlike" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidCommentOnPhoto:) name:@"cc.vellum.thisversusthat.notification.userdidcomment" object:nil];
     */
    self.shouldReloadOnAppear = NO;
    
}

- (void)viewDidAppear:(BOOL)animated {
    /*
    if (self.shouldReloadOnAppear) {
        [super viewDidAppear:animated];
        self.shouldReloadOnAppear = NO;
        [self loadObjects];
    }
     */
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"cc.vellum.thisversusthat.notification.userdidpublishpoll" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"cc.vellum.thisversusthat.notification.userdiddeletepoll" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"cc.vellum.thisversusthat.notification.userfollowingdidchange" object:nil];

}


#pragma mark - PFQueryTableViewController

- (void)loadObjects{
    
    if ( shouldWipeCache ){
        [[VLMCache sharedCache] clear];

    }
    [super loadObjects];
    
    PFQuery *q = [self queryForTable];
    [q countObjectsInBackgroundWithBlock:^(int number, NSError *error){
        self.resultcount = number;
        if ( !error ){
            NSInteger lastsection = [self numberOfSectionsInTableView:self.tableView] - 1;
            NSInteger lastrow = [self tableView:self.tableView numberOfRowsInSection:lastsection] - 1;
            NSArray *arr = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:lastrow inSection:lastsection]];
            [self.tableView reloadRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationFade];

        }
    }];
    self.lastquery = q;
    shouldWipeCache = YES;

}

- (PFQuery *)queryForTable {
    
    // CASE 1: FEEDTYPE ALL
    if ( self.currentFeedType == VLMFeedTypeAll ){
        // just get everything (not limited to followees)
        PFQuery *polls = [PFQuery queryWithClassName:self.className];
        [polls includeKey:@"User"];
        [polls whereKeyExists:@"User"];
        
        [polls includeKey:@"PhotoLeft"];
        [polls includeKey:@"PhotoRight"];
        [polls setLimit:1000];
        [polls setCachePolicy:kPFCachePolicyNetworkOnly];
        [polls orderByDescending:@"createdAt"];

        // If no objects are loaded in memory, we look to the cache first to fill the table
        // and then subsequently do a query against the network.
        //
        // If there is no network connection, we will hit the cache first.
        if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
            [polls setCachePolicy:kPFCachePolicyCacheThenNetwork];
        } else if (!self.shouldWipeCache) {
            [polls setCachePolicy:kPFCachePolicyNetworkOnly];
        }
        self.shouldWipeCache = YES;
        return polls;
    }
    
    // CASE 2: FEEDTYPE FOLLOW (BUT NOT LOGGED IN)
    if ( ![PFUser currentUser] ){
         // force an empty query (merely setting limit to zero doesn't work)
        PFQuery *polls = [PFQuery queryWithClassName:self.className];
        [polls whereKey:@"objectId" equalTo:@""];
        [polls setLimit:0];
        return polls;
    }

    // CASE 3: FEEDTYPE FOLLOW (LOGGED IN)
    // get people i follow
    PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:@"Activity"];
    [followingActivitiesQuery whereKey:@"Type" equalTo:@"follow"];
    [followingActivitiesQuery whereKey:@"FromUser" equalTo:[PFUser currentUser]];
    followingActivitiesQuery.limit = 1000;
    
    // get the polls for people i follow
    PFQuery *pollsFromFollowedUsersQuery = [PFQuery queryWithClassName:@"Poll"];
    [pollsFromFollowedUsersQuery whereKey:@"User" matchesKey:@"ToUser" inQuery:followingActivitiesQuery];
    [pollsFromFollowedUsersQuery whereKeyExists:@"PhotoLeft"];
    [pollsFromFollowedUsersQuery whereKeyExists:@"PhotoRight"];
    
    // get polls i've authored
    PFQuery *pollsFromCurrentUserQuery = [PFQuery queryWithClassName:@"Poll"];
    [pollsFromCurrentUserQuery whereKey:@"User" equalTo:[PFUser currentUser]];
    [pollsFromCurrentUserQuery whereKeyExists:@"PhotoLeft"];
    [pollsFromCurrentUserQuery whereKeyExists:@"PhotoRight"];
    
    // join these queries
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:pollsFromFollowedUsersQuery, pollsFromCurrentUserQuery, nil]];
    [query includeKey:@"User"];
    [query includeKey:@"PhotoLeft"];
    [query includeKey:@"PhotoRight"];
    [query orderByDescending:@"createdAt"];
    
    // A pull-to-refresh should always trigger a network request.
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    } else {
        if (!self.shouldWipeCache) {
            [query setCachePolicy:kPFCachePolicyNetworkOnly];
        }
    }
    
    self.shouldWipeCache = YES;
    return query;

    
}

- (PFObject *)objectAtIndex:(NSIndexPath *)indexPath {
    if ( self.objects.count == 0 ) return nil;
    
    // overridden, since we want to implement sections
    if (indexPath.section < self.objects.count) {
        return [self.objects objectAtIndex:indexPath.section];
    }
    return nil;
}

- (void)objectsDidLoad:(NSError *)error{
    [super objectsDidLoad:error];
    
    // hide the hud if it's visible (necessary when log out)
    [(AppDelegate *)[UIApplication sharedApplication].delegate hideHUD];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = self.objects.count;
    if (self.paginationEnabled){
        sections++;
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ( self.objects.count == 0 ) return 1;
    
    // the very first section is a special case:
    // it contains an additional variable height cell that we use for our sticky header hack
    if ( section == 0 ) return 2;
    
    // in all other cases, there is one row per section
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
    
    NSString *text = [obj objectForKey:@"Question"];
    return [VLMSectionView expectedViewHeightForText:text];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == self.objects.count) {
        // Load More section
        return nil;
    }

    PFObject *obj = [self.objects objectAtIndex:section];
    if ( obj == nil ) return nil;
        
    NSString *text = [obj objectForKey:@"Question"];
    PFUser *user = [obj objectForKey:@"User"];
    NSString *displayname = [user objectForKey:@"displayName"];
    PFFile *avatar = [user objectForKey:@"profilePicSmall"];

    CGFloat winw = [[UIScreen mainScreen] bounds].size.width;
    VLMSectionView *customview = [self dequeueReusableSectionHeaderView];
    if (!customview){
        customview = [[VLMSectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, winw, 60.0f) andUserName:displayname andQuestion:text];
        [self.reusableSectionHeaderViews addObject:customview];
    } else {
        [customview setUserName:displayname andQuestion:text];
    }
    [customview reset];
    [customview setTime:[obj createdAt]];
    [customview setFile:avatar];
    customview.delegate = self;
    customview.section = section;
    
    return customview;
}

// cell

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ////NSLog(@"section: %d", indexPath.section);
    if ( indexPath.section >= [self.objects count] ){
        
        UITableViewCell *cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        return cell;
    }
    
    PFObject *obj = [self.objects objectAtIndex:indexPath.section];
    if ( obj == nil ) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
        cell.contentView.hidden = YES;
        return cell;
    }
    
	// identifier
	static NSString *FeedCellIdentifier = @"PollCell";  
	
	// get an unused cell from existing pool of tableviewcells
	VLMCell *cell = [tableView dequeueReusableCellWithIdentifier:FeedCellIdentifier];
	
	// if no cell is available create a new one
	if (cell == nil) {
        cell = [[VLMCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FeedCellIdentifier];
        [cell setDelegate:self];
	} 
    cell.contentView.hidden = YES;
    //[cell setInitialPage:YES];

    if ( self.objects.count > 0 ){
        if ( indexPath.section == 0 && indexPath.row == 0 ){
            return cell;
        } 
    }
    [cell resetCell];
    [cell setPoll:obj];
    [cell setContentVisible:NO];
    cell.contentView.hidden = NO;
 
    PFObject *poll = obj;
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
        
        BOOL isDeleted = [[VLMCache sharedCache] isPollDeleted:poll];
        
        [cell setPersonalLeftCount:isLikedByCurrentUserL ? 1 : 0 andPersonalRightCount:isLikedByCurrentUserR ? 1: 0];
        [cell setCommentCount:[commentcount integerValue] commentedByCurrentUser:isVotedByCurrentUser];
        if ( isDeleted ) {
            [cell setPollDeleted];   
        } else {
            [cell setContentVisible:YES];
        }
        
        //NSLog(@"comments: %d", [[[VLMCache sharedCache] commentCountForPoll:poll] intValue]);


    // if not, stuff query results in the cache
    } else {
    
        //if ( ![PFUser currentUser] ) return cell;

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
                                NSString *cur = ([PFUser currentUser]) ? [[PFUser currentUser] objectId] : @"ollyollyoxenfree";
                                
                                // test for likes
                                if ([[activity objectForKey:@"Type"] isEqualToString:@"like"]){
                                    
                                    // left photo likes
                                    if ([[[activity objectForKey:@"Photo"] objectId] isEqualToString:[photoLeft objectId]]){
                                        // add userid to array
                                        [likersL addObject:[activity objectForKey:@"FromUser"]];
                                        
                                        if ( [userID isEqualToString:cur] ){
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
                                    //NSLog(@"adding a comment");
                                    [comments addObject:activity];
                                    
                                    if ( [userID isEqualToString:cur] ){
                                        isCommentedByCurrentUser = YES;
                                    }
                                }
                            }
                            
                            
                            [[VLMCache sharedCache] setAttributesForPoll:poll likersL:likersL likersR:likersR commenters:comments isLikedByCurrentUserL:isLikedByCurrentUserL isLikedByCurrentUserR:isLikedByCurrentUserR isCommentedByCurrentUser:isCommentedByCurrentUser isDeleted:NO];

                            // when fast scrolling, the current (presumably recycled) cell will fall out of sync
                            // so only update content if the cell's poll matches the current one
                            if ( [[poll objectId] isEqualToString:[cell pollID]] ){
                                NSNumber *leftcount = [[VLMCache sharedCache] likeCountForPollLeft:poll];
                                NSNumber *rightcount = [[VLMCache sharedCache] likeCountForPollRight:poll];
                                
                                [cell setLeftCount:[leftcount integerValue] andRightCount:[rightcount integerValue]];
                                
                                [cell setPersonalLeftCount:isLikedByCurrentUserL ? 1 : 0 andPersonalRightCount:isLikedByCurrentUserR ? 1: 0];
                                
                                NSNumber *commentcount = [[VLMCache sharedCache] commentCountForPoll:poll];
                                [cell setCommentCount:[commentcount integerValue] commentedByCurrentUser:isCommentedByCurrentUser];
                                
                                [cell setContentVisible:YES];
                            }


                        }//end if (!error)

                    }// end @synchronized

                }];

            
             }// end if (!outstandingquerystatus)

        }// end synchronnized

    } // end else

    [cell setTv:self];
    BOOL isLeft = [[VLMCache sharedCache] directionForPoll:poll];
    [cell setInitialPage:isLeft];
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.objects.count) {
        // Load More Section
        return 74.0f;
    }
    NSInteger rownum = [indexPath row];
    NSInteger sectionnum = [indexPath section];
    
    // for the very first row in the very first section, compute a dynamic height depending
    // on the scroll position
    if ( sectionnum == 0 && rownum == 0 ) {
        
        CGFloat scrollval = tableView.contentOffset.y;
        if ( scrollval < 0 ) scrollval = 0.0f;
        if ( scrollval > HEADER_HEIGHT ) scrollval = HEADER_HEIGHT;
        return scrollval;
    }
    
    if ( ![self objectAtIndex:indexPath] ) return 0;
    
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
    NSLog(@"%d / %d", self.objects.count, self.resultcount);
    
    if ( self.objects.count < self.resultcount ){
        [cell reset:YES isLoading:self.isLoading];
    }
    else {
        [cell reset:NO isLoading:self.isLoading];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // do nothing
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [super scrollViewDidScroll:scrollView];
    if ( self.objects.count == 0 ) return;
    
    // get the scroll position of the tableview
    CGFloat lookupY = scrollView.contentOffset.y;
    
    // invert the scroll position and use it as a y offset for positioning 
    // our fake header
    CGFloat headerOffsetY = -lookupY;
    if (headerOffsetY > 0 ) headerOffsetY = 0;
    if (headerOffsetY < -HEADER_HEIGHT ) headerOffsetY = -HEADER_HEIGHT;
    [self.headerViewController pushVerticallyBy:headerOffsetY];
    
    // now compute a y offset to apply to the scrollview
    // ( we're pushing this up where the header used to be
    //   or vice versa )
    CGFloat tvOffsetY = HEADER_HEIGHT + headerOffsetY;
    if ( tvOffsetY != self.contentOffsetY )
    {
        ////NSLog(@"%f", tvOffsetY);
        CGFloat winh = [[UIScreen mainScreen] bounds].size.height;
        CGFloat winw = [[UIScreen mainScreen] bounds].size.width;
        
        CGFloat footerh = (![PFUser currentUser]) ? FOOTER_HEIGHT : 0;
        [self.view setFrame: CGRectMake(0, tvOffsetY, winw, winh-tvOffsetY-STATUSBAR_HEIGHT - footerh)];
        
        // cast scrollview to a tableview
        UITableView *tv = (UITableView *)scrollView;
        
        // store this offset in an ivar
        self.contentOffsetY = tvOffsetY;
        
        // UITableView animates height changes by default
        // override that and make sure we don't animate
        
        // preserve the previous animation state
        BOOL animationsEnabled = [UIView areAnimationsEnabled];
        
        // kill animations
        [UIView setAnimationsEnabled:NO];
        
        // trigger a row height computation on our rows
        //[tv beginUpdates];
        //[tv endUpdates];

        // alternatively we can do
        [tv reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0], nil] withRowAnimation:UITableViewRowAnimationNone];
        
        // restore the previous animation state
        [UIView setAnimationsEnabled:animationsEnabled];
    }
}

// this method is called when we log in and out
-(void)updatelayout{
    
    // rearrange layout
    CGFloat winh = [[UIScreen mainScreen] bounds].size.height;
    CGFloat winw = [[UIScreen mainScreen] bounds].size.width;
    CGFloat footerh = (![PFUser currentUser]) ? FOOTER_HEIGHT : 0;  
    CGRect cr = CGRectMake(0.0f, 0.0f, winw, winh-FOOTER_HEIGHT-footerh);
    //CGRect cr = CGRectMake(0.0f, 0.0f, winw, winh-footerh-HEADER_HEIGHT-STATUSBAR_HEIGHT);
    
    [self setContentRect:cr];
    [self setContentOffsetY:HEADER_HEIGHT];
    [self.view setFrame: CGRectOffset(self.contentRect, 0.0f, self.contentOffsetY)];
    
    
    // reload data (since our logged in state has changed)
    [self loadObjects]; 
}



#pragma mark - VLMFeedHeaderDelegate

- (void)didTapPoll:(NSInteger)section{
    
    if ( delegate ){
        ////NSLog(@"tapped section: %d", section);
        PFObject *poll = [self.objects objectAtIndex:section];
        ////NSLog(@"tapped poll: %@", poll);
        if ( poll == nil ) return;
        //if ( [[VLMCache sharedCache] attributesForPoll:poll] == nil ) return;

        [delegate didTapPoll:poll];
    }
}

- (void)didTapUser:(NSInteger)section{
    if ( delegate ){
        PFObject *poll = [self.objects objectAtIndex:section];
        if ( poll == nil ) return;
        PFUser *user = [poll objectForKey:@"User"];
        if ( user == nil ) return;
        [delegate didTapUser:user];
    }
}

- (void)didTap:(id)sender{}

#pragma mark - VLMTapDelegate
- (void)didTapPollAndComment:(PFObject *)poll{}


#pragma mark - VLMPopModalDelegate

- (void)popPollDetail:(PFObject *)poll{}
- (void)popUserDetail:(PFUser *)user{}
- (void)popPollDetailAndScrollToComments:(PFObject *)poll{

    if ( !delegate || !poll ) return;
    
    if ( [delegate respondsToSelector:@selector(didTapPollAndComment:)] ){
        [delegate didTapPollAndComment:poll];
    }
}

#pragma mark - NOTIFICATIONS

- (void)userDidPublishPoll:(NSNotification *)note {
    NSLog(@"userdidpublishpoll");
    if (self.objects.count > 0) {
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }
    [self loadObjects];
}

- (void)userDidLikeOrUnlikePhoto:(NSNotification *)note {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)userDidCommentOnPhoto:(NSNotification *)note {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)userDidDeletePhoto:(NSNotification *)note {
    NSLog(@"userdiddeletephoto");
    
    // it's possible that the header has been pushed off screen
    // if this the one and only item has been removed, fix the scroll position (and hence the header position)
    if (self.objects.count == 1) {
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }

    NSObject *obj = [note object];
    
    // case 1: deletion was discovered during like/unlike
    if ( [obj isKindOfClass:[NSDictionary class]] ){

        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        //[self performSelector:@selector(loadObjects) withObject:nil afterDelay:3.0f];

        // case 2: we performed the deletion ourselves via "remove" button
    } else {
        // refresh timeline after a delay
        [self performSelector:@selector(loadObjects) withObject:nil afterDelay:1.0f];
    }
}


- (void)userFollowingChanged:(NSNotification *)note {
    NSLog(@"User following changed.");
    if ( currentFeedType == VLMFeedTypeFollowing ){
        self.shouldReloadOnAppear = YES;
    }
}

#pragma mark - ()
- (void)setFeedType:(int)feedtype{
    self.currentFeedType = feedtype;
    NSLog(@"newfeedtype: %d", feedtype);
    
    
    if ( self.lastquery ){
        if ( self.isLoading ) [self.lastquery cancel];
        if ( [self.lastquery hasCachedResult] ) [self.lastquery clearCachedResult];
    }

    [self setIsLoading:YES];
    self.shouldWipeCache = NO;
    self.resultcount = 0;
    [self clear];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];

    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(loadObjects) withObject:nil afterDelay:0.5f];
    //[self loadObjects];
}

@end
