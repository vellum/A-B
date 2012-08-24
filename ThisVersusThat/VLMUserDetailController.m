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
#import "VLMUtility.h"
#import <QuartzCore/QuartzCore.h>
#import "VLMSectionView.h"
#import "VLMCell.h"
#import "LoadMoreCell.h"
#import "VLMFeedHeaderDelegate.h"
#import "VLMPollDetailController.h"
#import "VLMGenericTapDelegate.h"
#import "VotesViewController.h"
#import "FollowerController.h"

@interface VLMUserDetailController ()
@property (nonatomic, strong) NSMutableDictionary *outstandingQueries;
@property (nonatomic) NSInteger resultcount;
@property (nonatomic, strong) NSMutableSet *reusableSectionHeaderViews;
@property (nonatomic) BOOL isRootController;
@property (nonatomic, strong) UILabel *numPollsLabel;
@property (nonatomic, strong) UILabel *numVotesLabel;
@property (nonatomic, strong) UILabel *numFollowingLabel;
@property (nonatomic, strong) UILabel *numFollowersLabel;

@property (nonatomic) NSInteger recognizedPanDirection;
@property (unsafe_unretained, nonatomic) UITableViewCell *selectedCell;
@property (nonatomic, strong) UIPanGestureRecognizer *localPGR;
@property (nonatomic) int lastknowncount;
@property (nonatomic) BOOL shouldRefreshOnAppear;
- (void)loadFollowerDataWithPolicy:(PFCachePolicy)policy;
@end

@implementation VLMUserDetailController
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
@synthesize shouldRefreshOnAppear;
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
        self.lastknowncount = 0;
        self.isRootController = isRoot;
        [self.view setAutoresizesSubviews:NO];        
        [self.view setBackgroundColor:[UIColor clearColor]];
        [self.tableView setBackgroundColor:[UIColor clearColor]];
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
    
    self.title = [VLMUtility firstNameForDisplayName:[self.user objectForKey:@"displayName"]];

    NSLog(@"%d viewcontrollers", self.navigationController.viewControllers.count);

    if ( self.isRootController )
    {
        UIBarButtonItem *cancelbutton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
        [self.navigationItem setLeftBarButtonItem:cancelbutton];
        [self.navigationItem setHidesBackButton:YES];
    }

    
    
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 14*13)];
    //[header setBackgroundColor:DEBUG_BACKGROUND_GRID];
    
    UIView *card = [[UIView alloc] initWithFrame:CGRectMake(15, 14, 40*6+45, 14*5)];
    [card setBackgroundColor:[UIColor whiteColor]];
    [header addSubview:card];
    
    PFImageView *iv = [[PFImageView alloc] initWithFrame:CGRectMake(5, 5, 14*4+4, 14*4+4)];
    [iv setBackgroundColor:[UIColor lightGrayColor]];
    [iv setFile:[user objectForKey:@"profilePicMedium"]];
    [iv loadInBackground];
    [card addSubview:iv];
    
    
    UILabel *a = [[UILabel alloc] initWithFrame:CGRectMake(90, 14, 5*40, 14*2)];
    [a setFont:[UIFont fontWithName:@"AmericanTypewriter" size:13.0f]];
    [a setBackgroundColor:[UIColor clearColor]];
    [a setTextColor:TEXT_COLOR];
    [a setText:[user objectForKey:@"displayName"]];
    [header addSubview:a];
    
    UIView *head = [[UIView alloc] initWithFrame:CGRectMake(15, 14*7, self.view.frame.size.width-35, 14*4)];
    //[head setBackgroundColor:TEXT_COLOR];
    [head setBackgroundColor:[UIColor whiteColor]];
    [header addSubview:head];
    
    
    UILabel *col1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 71.25, 2*14)];
    [col1 setFont:[UIFont fontWithName:@"AmericanTypewriter" size:10.0f]];
    [col1 setBackgroundColor:[UIColor clearColor]];
     [col1 setTextColor:TEXT_COLOR];
    [col1 setText:@"POLLS"];
    [col1 setTextAlignment:UITextAlignmentCenter];
    [head addSubview:col1];
    
    UILabel *col2 = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 71.25, 2*14)];
    [col2 setFont:[UIFont fontWithName:@"AmericanTypewriter" size:10.0f]];
    [col2 setBackgroundColor:[UIColor clearColor]];
    [col2 setTextColor:TEXT_COLOR];
    [col2 setText:@"VOTED"];
    [col2 setTextAlignment:UITextAlignmentCenter];
    [head addSubview:col2];
    
    UILabel *col3 = [[UILabel alloc] initWithFrame:CGRectMake(160, 0, 71.25, 2*14)];
    [col3 setFont:[UIFont fontWithName:@"AmericanTypewriter" size:10.0f]];
    [col3 setBackgroundColor:[UIColor clearColor]];
    [col3 setTextColor:TEXT_COLOR];
    [col3 setText:@"FOLLOWING"];
    [col3 setTextAlignment:UITextAlignmentCenter];
    [head addSubview:col3];

    UILabel *col4 = [[UILabel alloc] initWithFrame:CGRectMake(240, 0, 71.25, 2*14)];
    [col4 setFont:[UIFont fontWithName:@"AmericanTypewriter" size:10.0f]];
    [col4 setBackgroundColor:[UIColor clearColor]];
    [col4 setTextColor:TEXT_COLOR];
    [col4 setText:@"FOLLOWERS"];
    [col4 setTextAlignment:UITextAlignmentCenter];
    [head addSubview:col4];
    
    
    [col1 sizeToFit];
    [col2 sizeToFit];
    [col3 sizeToFit];
    [col4 sizeToFit];
    CGFloat w = col1.frame.size.width + col2.frame.size.width + col3.frame.size.width + col4.frame.size.width;
    CGFloat m = card.frame.size.width - w;
    m/=4;
    [col1 setFrame:CGRectMake(0, 0, col1.frame.size.width + m, 14*2)];
    [col2 setFrame:CGRectMake(col1.frame.origin.x+col1.frame.size.width, 0, col2.frame.size.width + m, 14*2)];
    [col3 setFrame:CGRectMake(col2.frame.origin.x+col2.frame.size.width, 0, col3.frame.size.width + m, 14*2)];
    [col4 setFrame:CGRectMake(col3.frame.origin.x+col3.frame.size.width, 0, col4.frame.size.width + m, 14*2)];


    self.numPollsLabel = [[UILabel alloc] initWithFrame:CGRectMake(col1.frame.origin.x, col1.frame.origin.y+14, col1.frame.size.width, 14*3.5)];
    [self.numPollsLabel setBackgroundColor:[UIColor clearColor]];
    [self.numPollsLabel setTextColor:TEXT_COLOR];
    [self.numPollsLabel setFont:[UIFont fontWithName:@"AmericanTypewriter" size:13.0f]];
    [self.numPollsLabel setTextAlignment:UITextAlignmentCenter];
    [head addSubview:self.numPollsLabel];

    self.numVotesLabel = [[UILabel alloc] initWithFrame:CGRectMake(col2.frame.origin.x, col2.frame.origin.y+14, col2.frame.size.width, 14*3.5)];
    [self.numVotesLabel setBackgroundColor:[UIColor clearColor]];
    [self.numVotesLabel setTextColor:TEXT_COLOR];
    [self.numVotesLabel setFont:[UIFont fontWithName:@"AmericanTypewriter" size:13.0f]];
    [self.numVotesLabel setTextAlignment:UITextAlignmentCenter];
    [head addSubview:self.numVotesLabel];
    
    
    self.numFollowingLabel = [[UILabel alloc] initWithFrame:CGRectMake(col3.frame.origin.x, col3.frame.origin.y+14, col3.frame.size.width, 14*3.5)];
    [self.numFollowingLabel setBackgroundColor:[UIColor clearColor]];
    [self.numFollowingLabel setTextColor:TEXT_COLOR];
    [self.numFollowingLabel setFont:[UIFont fontWithName:@"AmericanTypewriter" size:13.0f]];
    [self.numFollowingLabel setTextAlignment:UITextAlignmentCenter];
    [head addSubview:self.numFollowingLabel];
    
    self.numFollowersLabel = [[UILabel alloc] initWithFrame:CGRectMake(col4.frame.origin.x, col4.frame.origin.y+14, col4.frame.size.width, 14*3.5)];
    [self.numFollowersLabel setBackgroundColor:[UIColor clearColor]];
    [self.numFollowersLabel setTextColor:TEXT_COLOR];
    [self.numFollowersLabel setFont:[UIFont fontWithName:@"AmericanTypewriter" size:13.0f]];
    [self.numFollowersLabel setTextAlignment:UITextAlignmentCenter];
    [head addSubview:self.numFollowersLabel];

    UIButton *clearbutton = [[UIButton alloc] initWithFrame:CGRectMake(col1.frame.origin.x, col1.frame.origin.y, col1.frame.size.width, 14*4)];
    [clearbutton setBackgroundImage:[UIImage imageNamed:@"clear.png"] forState:UIControlStateNormal];
    [clearbutton setBackgroundImage:[UIImage imageNamed:@"clear50.png"] forState:UIControlStateHighlighted];
    //[clearbutton setBackgroundColor:[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.5f]];
    [clearbutton addTarget:self action:@selector(profilePollsTapped:) forControlEvents:UIControlEventTouchUpInside];
    [head addSubview:clearbutton];
    

    UIButton *clearbutton2 = [[UIButton alloc] initWithFrame:CGRectMake(col2.frame.origin.x, col2.frame.origin.y, col2.frame.size.width, 14*4)];
    [clearbutton2 setBackgroundImage:[UIImage imageNamed:@"clear.png"] forState:UIControlStateNormal];
    [clearbutton2 setBackgroundImage:[UIImage imageNamed:@"clear50.png"] forState:UIControlStateHighlighted];
    //[clearbutton2 setBackgroundColor:[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.5f]];
    [clearbutton2 addTarget:self action:@selector(profileVotesTapped:) forControlEvents:UIControlEventTouchUpInside];
    [head addSubview:clearbutton2];
    
    UIButton *clearbutton3 = [[UIButton alloc] initWithFrame:CGRectMake(col3.frame.origin.x, col3.frame.origin.y, col3.frame.size.width, 14*4)];
    [clearbutton3 setBackgroundImage:[UIImage imageNamed:@"clear.png"] forState:UIControlStateNormal];
    [clearbutton3 setBackgroundImage:[UIImage imageNamed:@"clear50.png"] forState:UIControlStateHighlighted];
    //[clearbutton3 setBackgroundColor:[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.5f]];
    [clearbutton3 addTarget:self action:@selector(profileFollowingTapped:) forControlEvents:UIControlEventTouchUpInside];

    [head addSubview:clearbutton3];

    UIButton *clearbutton4 = [[UIButton alloc] initWithFrame:CGRectMake(col4.frame.origin.x, col4.frame.origin.y, col4.frame.size.width, 14*4)];
    [clearbutton4 setBackgroundImage:[UIImage imageNamed:@"clear.png"] forState:UIControlStateNormal];
    [clearbutton4 setBackgroundImage:[UIImage imageNamed:@"clear50.png"] forState:UIControlStateHighlighted];
    //[clearbutton4 setBackgroundColor:[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.5f]];
    [clearbutton4 addTarget:self action:@selector(profileFollowersTapped:) forControlEvents:UIControlEventTouchUpInside];

    [head addSubview:clearbutton4];
    

    
    self.tableView.tableHeaderView = header;
    
    self.shouldRefreshOnAppear = NO;
    [self loadHeaderData];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidDeletePhoto:) name:@"cc.vellum.thisversusthat.notification.userdiddeletepoll" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLikeOrUnlikePhoto:) name:@"cc.vellum.thisversusthat.notification.userdidlikeorunlike" object:nil];
    
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ( self.shouldRefreshOnAppear )
        [self loadHeaderData];
    self.shouldRefreshOnAppear = YES;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"cc.vellum.thisversusthat.notification.userdiddeletepoll" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"cc.vellum.thisversusthat.notification.userdidlikeorunlike" object:nil];
    
}

- (void)loadHeaderData{
    PFQuery *queryPollCount = [PFQuery queryWithClassName:@"Poll"];
    [queryPollCount whereKey:@"User" equalTo:self.user];
    [queryPollCount setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryPollCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [self.numPollsLabel setText:[NSString stringWithFormat:@"%d", number]];
        }
    }];
    
    PFQuery *queryVoteCount = [PFQuery queryWithClassName:@"Activity"];
    [queryVoteCount whereKey:@"FromUser" equalTo:self.user];
    [queryVoteCount whereKey:@"Type" equalTo:@"like"];
    [queryVoteCount setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryVoteCount countObjectsInBackgroundWithBlock:^(int number, NSError *error){
        if (!error) {
            [self.numVotesLabel setText:[NSString stringWithFormat:@"%d", number]];
        }
    }];
    
    [self loadFollowerDataWithPolicy:kPFCachePolicyNetworkOnly];
    
    PFQuery *queryF = [[PFQuery alloc] initWithClassName:@"Activity"];
    [queryF whereKey:@"FromUser" equalTo:[PFUser currentUser]];
    [queryF whereKey:@"ToUser" equalTo:self.user];
    [queryF whereKey:@"Type" equalTo:@"follow"];
    [queryF setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryF countObjectsInBackgroundWithBlock:^(int number, NSError *error){
        if ( !error ){
            if ( number == 0 ){
                [self configureFollowButton];
            } else {
                [self configureUnfollowButton];
            }
        }
    }];
    
}

- (void)loadFollowerDataWithPolicy:(PFCachePolicy)policy{
    
    PFQuery *queryFolloweesCount = [PFQuery queryWithClassName:@"Activity"];
    [queryFolloweesCount whereKey:@"ToUser" equalTo:self.user];
    [queryFolloweesCount whereKey:@"Type" equalTo:@"follow"];
    [queryFolloweesCount setCachePolicy:policy];
    [queryFolloweesCount countObjectsInBackgroundWithBlock:^(int number, NSError *error){
        if ( !error ){
            [self.numFollowersLabel setText:[NSString stringWithFormat:@"%d", number]];
        }
    }];
    
    PFQuery *queryFollowersCount = [PFQuery queryWithClassName:@"Activity"];
    [queryFollowersCount whereKey:@"FromUser" equalTo:self.user];
    [queryFollowersCount whereKey:@"Type" equalTo:@"follow"];
    [queryFollowersCount setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryFollowersCount countObjectsInBackgroundWithBlock:^(int number, NSError *error){
        if ( !error ){
            [self.numFollowingLabel setText:[NSString stringWithFormat:@"%d", number]];
        }
    }];
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
            [self.tableView reloadRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationFade];

        }
    }];
    
    
    
}

- (void)objectsDidLoad:(NSError *)error{
    [super objectsDidLoad:error];
    
    // iterate through and wipe the cache
    for( int i = lastknowncount; i < self.objects.count; i++){
        PFObject *o = [self.objects objectAtIndex:i];
        [[VLMCache sharedCache] removeAttributesForPoll:o];
    }
    lastknowncount = self.objects.count;
    
}


- (PFQuery *)queryForTable {
    PFQuery *polls = [PFQuery queryWithClassName:self.className];

    [polls includeKey:@"User"];
    [polls whereKeyExists:@"User"];
    [polls whereKey:@"User" equalTo:self.user];
    
    [polls includeKey:@"PhotoLeft"];
    [polls includeKey:@"PhotoRight"];
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
    [customview reset];
    [customview setTime:[obj createdAt]];
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
        
        UIView *bg = [[UIView alloc] initWithFrame:CGRectZero];
        [bg setBackgroundColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
        [cell setSelectedBackgroundView:bg];
	} else {
        //[cell setInitialPage:YES];
    }
    [cell resetCell];
    [cell setPoll:obj];
    [cell setContentVisible:NO];
    cell.contentView.hidden = NO;
    
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

- (void)followButtonAction:(id)sender {
    UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [loadingActivityIndicatorView startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
    
    [self configureUnfollowButton];
    [VLMUtility followUserInBackground:self.user block:^(BOOL succeeded, NSError *error) {
        if (error) {
            [self configureFollowButton];
        } else {
            [self loadFollowerDataWithPolicy:kPFCachePolicyNetworkOnly];
        }
    }];
    
}

- (void)unfollowButtonAction:(id)sender {
    UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [loadingActivityIndicatorView startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
    
    [self configureFollowButton];
    
    [VLMUtility unfollowUserEventually:self.user block:^(BOOL succeeded, NSError *error) {
        [self loadFollowerDataWithPolicy:kPFCachePolicyNetworkOnly];
        if ( error ){
            [self configureUnfollowButton];
        } else {
            [self loadFollowerDataWithPolicy:kPFCachePolicyNetworkOnly];
        }
    }];
}

- (void)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)configureFollowButton {

    UIBarButtonItem *followbutton = [[UIBarButtonItem alloc] initWithTitle:@"Follow" style:UIBarButtonItemStylePlain target:self action:@selector(followButtonAction:)];
    [self.navigationItem setRightBarButtonItem:followbutton];
    [[VLMCache sharedCache] setFollowStatus:NO user:self.user];
}

- (void)configureUnfollowButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Unfollow" style:UIBarButtonItemStylePlain target:self action:@selector(unfollowButtonAction:)];
    [[VLMCache sharedCache] setFollowStatus:YES user:self.user];
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

- (void)profilePollsTapped:(id)sender{
    NSLog(@"a");
    if (self.objects.count == 0 ) return;
    NSIndexPath* ipath = [NSIndexPath indexPathForRow: 0 inSection: 0];
    [self.tableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
}
- (void)profileVotesTapped:(id)sender{
    VotesViewController *v = [[VotesViewController alloc] initWithObject:user isRoot:NO];
    [self.navigationController pushViewController:v animated:YES];
}
- (void)profileFollowingTapped:(id)sender{
    NSLog(@"c");
    FollowerController *fc = [[FollowerController alloc] initWithObject:self.user isRoot:NO modeFollowing:YES];
    [self.navigationController pushViewController:fc animated:YES];
}
- (void)profileFollowersTapped:(id)sender{
    NSLog(@"d");
    FollowerController *fc = [[FollowerController alloc] initWithObject:self.user isRoot:NO modeFollowing:NO];
    [self.navigationController pushViewController:fc animated:YES];
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



- (void)userDidDeletePhoto:(NSNotification *)note {
    NSObject *obj = [note object];
    
    // case 1: deletion was discovered during like/unlike
    if ( [obj isKindOfClass:[NSDictionary class]] ){
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        
    // case 2: we performed the deletion ourselves via "remove" button
    } else {
        // refresh timeline after a delay
        [self performSelector:@selector(loadObjects) withObject:nil afterDelay:1.0f];

        
        PFQuery *queryPollCount = [PFQuery queryWithClassName:@"Poll"];
        [queryPollCount whereKey:@"User" equalTo:self.user];
        [queryPollCount setCachePolicy:kPFCachePolicyNetworkOnly];
        [queryPollCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (!error) {
                [self.numPollsLabel setText:[NSString stringWithFormat:@"%d", number]];
            }
        }];
    }

    
}

- (void)userDidLikeOrUnlikePhoto:(NSNotification *)note {

    // only respond to notification if it affects this view
    
    if ( [self.user.objectId isEqualToString:[PFUser currentUser].objectId] ){

            // requery header
        PFQuery *queryVoteCount = [PFQuery queryWithClassName:@"Activity"];
        [queryVoteCount whereKey:@"FromUser" equalTo:self.user];
        [queryVoteCount whereKey:@"Type" equalTo:@"like"];
        [queryVoteCount setCachePolicy:kPFCachePolicyNetworkOnly];
        [queryVoteCount countObjectsInBackgroundWithBlock:^(int number, NSError *error){
            if (!error) {
                [self.numVotesLabel setText:[NSString stringWithFormat:@"%d", number]];
            }
        }];
        
        // refresh tableview
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
}

@end
