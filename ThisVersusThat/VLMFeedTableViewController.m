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

@interface VLMFeedTableViewController()

@property (nonatomic, assign) BOOL shouldReloadOnAppear;
@property (nonatomic, strong) NSMutableSet *reusableSectionHeaderViews;
@property (nonatomic, strong) NSMutableDictionary *outstandingQueries;
@property (strong, nonatomic) VLMFeedHeaderController *headerViewController;
@property (nonatomic) CGRect contentRect;
@property (nonatomic) CGFloat contentOffsetY;
@property (nonatomic) NSInteger resultcount;

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
        //[self.view setBackgroundColor:FEED_TABLEVIEW_BGCOLOR];
        [self.view setBackgroundColor:[UIColor clearColor]];
        [self updatelayout];
        
        
    }
    return self;
}



#pragma mark - UIViewController

- (void)viewDidLoad {
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone]; 
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    //[super viewDidAppear:animated];
    
    /*
    if (self.shouldReloadOnAppear) {
        self.shouldReloadOnAppear = NO;
        [self loadObjects];
    }*/
}




#pragma mark - PFQueryTableViewController

- (void)loadObjects{
    [[VLMCache sharedCache] clear];
    [super loadObjects];
    
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

- (PFQuery *)queryForTable {
    // just get everything (not limited to followees)
    PFQuery *polls = [PFQuery queryWithClassName:self.className];
    [polls includeKey:@"User"];
    [polls includeKey:@"PhotoLeft"];
    [polls includeKey:@"PhotoRight"];
    [polls setLimit:1000];
    [polls orderByDescending:@"createdAt"];
    return polls;
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
    [customview setTime:[obj createdAt]];
    [customview setFile:avatar];
    customview.delegate = self;
    customview.section = section;
    
    return customview;
}

// cell

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"section: %d", indexPath.section);
    if ( indexPath.section >= [self.objects count] ){
        
        UITableViewCell *cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        return cell;
    }
    
    PFObject *obj = [self.objects objectAtIndex:indexPath.section];
    if ( obj == nil ) return nil;
    
	// identifier
	static NSString *FeedCellIdentifier = @"PollCell";  
	
	// get an unused cell from existing pool of tableviewcells
	VLMCell *cell = [tableView dequeueReusableCellWithIdentifier:FeedCellIdentifier];
	
	// if no cell is available create a new one
	if (cell == nil) {
        cell = [[VLMCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FeedCellIdentifier];
	} 
    //[cell setInitialPage:YES];
    [cell resetCell];

    if ( self.objects.count > 0 ){
        if ( indexPath.section == 0 && indexPath.row == 0 ){
            cell.contentView.hidden = YES;
            return cell;
        } 
    }
    cell.contentView.hidden = NO;
    [cell setPoll:obj];

    PFObject *poll = obj;
    PFObject *photoLeft = [poll objectForKey:@"PhotoLeft"];
    //PFObject *photoRight = [poll objectForKey:@"PhotoRight"];

    NSDictionary *attributesForPoll = [[VLMCache sharedCache] attributesForPoll:poll];
    PFCachePolicy poly = kPFCachePolicyNetworkOnly;

    // check if we've stored metadata (likes, comments) for this poll
    if (attributesForPoll) {
        NSNumber *leftcount = [[VLMCache sharedCache] likeCountForPollLeft:poll];
        NSNumber *rightcount = [[VLMCache sharedCache] likeCountForPollRight:poll];
        [cell setLeftCount:[leftcount integerValue] andRightCount:[rightcount integerValue]];

        BOOL isLikedByCurrentUserL = [[VLMCache sharedCache] isPollLikedByCurrentUserLeft:poll];
        BOOL isLikedByCurrentUserR = [[VLMCache sharedCache] isPollLikedByCurrentUserRight:poll];
        [cell setPersonalLeftCount:isLikedByCurrentUserL ? 1 : 0 andPersonalRightCount:isLikedByCurrentUserR ? 1: 0];
        

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
                            NSMutableArray *commenters = [NSMutableArray array];
                            BOOL isLikedByCurrentUserL = NO;
                            BOOL isLikedByCurrentUserR = NO;
                            
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
                                    
                                }
                            }
                            
                            
                            [[VLMCache sharedCache] setAttributesForPoll:poll likersL:likersL likersR:likersR commenters:commenters isLikedByCurrentUserL:isLikedByCurrentUserL isLikedByCurrentUserR:isLikedByCurrentUserR];
                            
                            NSNumber *leftcount = [[VLMCache sharedCache] likeCountForPollLeft:poll];
                            NSNumber *rightcount = [[VLMCache sharedCache] likeCountForPollRight:poll];
                            
                            [cell setLeftCount:[leftcount integerValue] andRightCount:[rightcount integerValue]];

                            [cell setPersonalLeftCount:isLikedByCurrentUserL ? 1 : 0 andPersonalRightCount:isLikedByCurrentUserR ? 1: 0];

                        }//end if (!error)

                    }// end @synchronized

                }];

            
             }// end if (!outstandingquerystatus)

        }// end synchronnized

    } // end else

    [cell setTv:self];
    BOOL isLeft = [[VLMCache sharedCache] directionForPoll:poll];
    [cell setInitialPage:isLeft];
    [cell setTime:[poll createdAt]];
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
    
    // otherwise, row heights are fixed
    return 321.0f + 0;
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
        //NSLog(@"%f", tvOffsetY);
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
        [tv reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        
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
        //NSLog(@"tapped section: %d", section);
        PFObject *poll = [self.objects objectAtIndex:section];
        //NSLog(@"tapped poll: %@", poll);
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

#pragma mark - VLMGenericTapDelegate
- (void)didTap:(id)sender{
    [self loadNextPage];
}

@end
