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

@interface VLMFeedTableViewController()
@property (nonatomic, assign) BOOL shouldReloadOnAppear;
@property (nonatomic, strong) NSMutableSet *reusableSectionHeaderViews;

@property (nonatomic, strong) NSMutableDictionary *outstandingSectionHeaderQueries;
@property (strong, nonatomic) VLMFeedHeaderController *headerViewController;
@property (nonatomic) CGRect contentRect;
@property (nonatomic) CGFloat contentOffsetY;
@end

@implementation VLMFeedTableViewController

@synthesize headerViewController;
@synthesize contentRect;
@synthesize contentOffsetY;
@synthesize reusableSectionHeaderViews;
@synthesize shouldReloadOnAppear;
@synthesize outstandingSectionHeaderQueries;

#pragma mark - NSObject

-(id) initWithHeader:(VLMFeedHeaderController *) headerController {
    self = [super initWithStyle:UITableViewStylePlain];
    if ( headerController ) {
        self.headerViewController = headerController;

        self.outstandingSectionHeaderQueries = [NSMutableDictionary dictionary];
        
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

        [self.view setAutoresizesSubviews:NO];        
        [self.view setBackgroundColor:FEED_TABLEVIEW_BGCOLOR];
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
    [super viewDidAppear:animated];
    
    if (self.shouldReloadOnAppear) {
        self.shouldReloadOnAppear = NO;
        [self loadObjects];
    }
}

#pragma mark - PFQueryTableViewController

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
    // overridden, since we want to implement sections
    if (indexPath.section < self.objects.count) {
        return [self.objects objectAtIndex:indexPath.section];
    }
    return nil;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = self.objects.count;
    //if (self.paginationEnabled && sections != 0)
    //    sections++;
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // the very first section is a special case:
    // it contains an additional variable height cell that we use for our sticky header hack
    if ( section == 0 ) return 2;
    
    // in all other cases, there is one row per section
	return 1;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
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
    PFObject *obj = [self.objects objectAtIndex:section];
    if ( obj == nil ) return nil;
    
    
    NSString *text = [obj objectForKey:@"Question"];
    PFUser *user = [obj objectForKey:@"User"];
    NSString *displayname = [user objectForKey:@"displayName"];
    PFFile *avatar = [user objectForKey:@"profilePicSmall"];

    CGFloat winw = [[UIScreen mainScreen] bounds].size.width;
    VLMSectionView *customview = [[VLMSectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, winw, 60.0f) andUserName:displayname andQuestion:text];
    [customview setFile:avatar];
    return customview;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
    
    if ( indexPath.section == 0 && indexPath.row == 0 ){
        cell.contentView.hidden = YES;
    } else {
        cell.contentView.hidden = NO;
        PFObject *photoLeft = [obj objectForKey:@"PhotoLeft"];
        PFObject *photoRight = [obj objectForKey:@"PhotoRight"];
        
        PFFile *left = [photoLeft objectForKey:@"Original"];
        PFFile *right = [photoRight objectForKey:@"Original"];
        
        NSString *leftcaption = [photoLeft objectForKey:@"Caption"];
        NSString *rightcaption = [photoRight objectForKey:@"Caption"];
        [cell setLeftFile:left andRightFile:right];
        [cell setLeftCaptionText:leftcaption andRightCaptionText:rightcaption];
    }
    
	return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.tableView.bounds.size.width, 16.0f)];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == self.objects.count) {
        return 0.0f;
    }
    return 16.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.objects.count) {
        // Load More Section
        return 44.0f;
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
    return 321.0f;
}

#pragma mark - VLMFeedTableViewController

- (VLMSectionView *)dequeueReusableSectionHeaderView {
    for (VLMSectionView *sectionHeaderView in self.reusableSectionHeaderViews) {
        if (!sectionHeaderView.superview) {
            // we found a section header that is no longer visible
            return sectionHeaderView;
        }
    }
    return nil;
}

-(void)updatelayout{
    CGFloat winh = [[UIScreen mainScreen] bounds].size.height;
    CGFloat winw = [[UIScreen mainScreen] bounds].size.width;
    CGFloat footerh = (![PFUser currentUser]) ? FOOTER_HEIGHT : 0;  
    CGRect cr = CGRectMake(0.0f, 0.0f, winw, winh-FOOTER_HEIGHT-footerh);
    //CGRect cr = CGRectMake(0.0f, 0.0f, winw, winh-footerh-HEADER_HEIGHT-STATUSBAR_HEIGHT);
    
    [self setContentRect:cr];
    [self setContentOffsetY:HEADER_HEIGHT];
    [self.view setFrame: CGRectOffset(self.contentRect, 0.0f, self.contentOffsetY)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    
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
        [tv beginUpdates];
        [tv endUpdates];
        
        // alternatively we can do
        //[tv reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        
        // restore the previous animation state
        [UIView setAnimationsEnabled:animationsEnabled];
    }
}

@end
