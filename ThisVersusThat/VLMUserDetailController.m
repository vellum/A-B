//
//  VLMUserDetailController.m
//  ThisVersusThat
//
//  Created by David Lu on 8/7/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "VLMUserDetailController.h"
#import "VLMConstants.h"
#import "UIViewController+Transitions.h"
#import "VLMCache.h"
#import <QuartzCore/QuartzCore.h>
#import "VLMSectionView.h"
#import "VLMCell.h"
#import "LoadMoreCell.h"
#import "VLMFeedHeaderDelegate.h"
#import "VLMPollDetailController.h"


@interface VLMUserDetailController ()
@property (nonatomic, strong) NSMutableDictionary *outstandingQueries;
@property (nonatomic) NSInteger resultcount;
@property (nonatomic, strong) NSMutableSet *reusableSectionHeaderViews;
@property (nonatomic) BOOL isRootController;

@end

@implementation VLMUserDetailController
@synthesize user;
@synthesize outstandingQueries;
@synthesize resultcount;
@synthesize reusableSectionHeaderViews;
@synthesize isRootController;

#pragma mark - NSObject

- (id)initWithObject:(PFUser *)obj isRoot:(BOOL)isRoot{
    self = [super init];
    if ( self ){
        self.user = obj;
        self.loadingViewEnabled = NO;
        self.outstandingQueries = [NSMutableDictionary dictionary];
        self.className = @"Poll";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 10;
        self.reusableSectionHeaderViews = [NSMutableSet setWithCapacity:3];
        self.resultcount = 0;
        self.isRootController = isRoot;
        [self.view setAutoresizesSubviews:NO];        
        [self.view setBackgroundColor:FEED_TABLEVIEW_BGCOLOR];

    }
    
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad{    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone]; 

    [super viewDidLoad];

    [self.view setBackgroundColor:FEED_TABLEVIEW_BGCOLOR];
    self.title = [self.user objectForKey:@"displayName"];

    NSLog(@"%d viewcontrollers", self.navigationController.viewControllers.count);

    if ( self.isRootController )
    {
        UIBarButtonItem *cancelbutton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
        [self.navigationItem setLeftBarButtonItem:cancelbutton];
        [self.navigationItem setHidesBackButton:YES];
    } else {
        UIBarButtonItem *backbutton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
        [self.navigationItem setLeftBarButtonItem:backbutton];
        [self.navigationItem setHidesBackButton:YES];
    }
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"Activity"];
    [query whereKey:@"FromUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"ToUser" equalTo:self.user];
    [query whereKey:@"Type" equalTo:@"follow"];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error){
        if ( !error ){
            if ( number == 0 ){
                UIBarButtonItem *followbutton = [[UIBarButtonItem alloc] initWithTitle:@"Follow" style:UIBarButtonItemStylePlain target:self action:@selector(follow:)];
                [self.navigationItem setRightBarButtonItem:followbutton];
                
            } else {
                UIBarButtonItem *followbutton = [[UIBarButtonItem alloc] initWithTitle:@"Unfollow" style:UIBarButtonItemStylePlain target:self action:@selector(unfollow:)];
                [self.navigationItem setRightBarButtonItem:followbutton];
                
            }
        }
    }];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - PFQueryTableViewController

- (void)loadObjects{

    // FIXME: clear the cache of objects in the view already
    //[[VLMCache sharedCache] clear]; // this nukes EVERYTHING which is bad

    [super loadObjects];
    
    PFQuery *q = [self queryForTable];
    [q countObjectsInBackgroundWithBlock:^(int number, NSError *error){
        if ( !error ){
            self.resultcount = number;
        }
    }];
}

- (PFQuery *)queryForTable {
    PFQuery *polls = [PFQuery queryWithClassName:self.className];
    [polls whereKey:@"User" equalTo:self.user];
    [polls includeKey:@"User"];
    [polls includeKey:@"PhotoLeft"];
    [polls includeKey:@"PhotoRight"];
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
    PFUser *u = [obj objectForKey:@"User"];
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
    
	// identifier
	static NSString *FeedCellIdentifier = @"PollCell";
	
	// get an unused cell from existing pool of tableviewcells
	VLMCell *cell = [tableView dequeueReusableCellWithIdentifier:FeedCellIdentifier];
	
	// if no cell is available create a new one
	if (cell == nil) {
        cell = [[VLMCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FeedCellIdentifier];
	} else {
        [cell setInitialPage:YES];
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
                            NSMutableArray *commenters = [NSMutableArray array];
                            BOOL isLikedByCurrentUserL = NO;
                            BOOL isLikedByCurrentUserR = NO;
                            
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
    return 321.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    
    LoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[LoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        //cell.tv = self;
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

- (void)follow:(id)sender{
    NSLog(@"follow");
}

- (void)unfollow:(id)sender{
    NSLog(@"unfollow");
}



#pragma mark - VLMFeedHeaderDelegate

- (void)didTapPoll:(NSInteger)section{
    PFObject *poll = [self.objects objectAtIndex:section];
    if ( poll == nil ) return;
    if ( [[VLMCache sharedCache] attributesForPoll:poll] == nil ) return;

    VLMPollDetailController *polldetail = [[VLMPollDetailController alloc] initWithObject:poll isRoot:NO];
    [self.navigationController pushViewController:polldetail animated:YES];
}

- (void)didTapUser:(NSInteger)section{
    PFObject *poll = [self.objects objectAtIndex:section];
    if ( poll == nil ) return;
    PFUser *u = [poll objectForKey:@"User"];
    if ( u == nil ) return;
    
    VLMUserDetailController *userdetail = [[VLMUserDetailController alloc] initWithObject:u isRoot:NO];
    [self.navigationController pushViewController:userdetail animated:YES];
}


@end
