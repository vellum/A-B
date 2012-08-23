//
//  ActivityViewController.m
//  ThisVersusThat
//
//  Created by David Lu on 8/11/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "ActivityViewController.h"
#import "VLMConstants.h"
#import "VLMActivityCell.h"
#import "LoadMoreCell.h"
#import "VLMPopModalDelegate.h"
#import "VLMTextButton.h"

@interface ActivityViewController ()
@property (nonatomic) int resultcount;
@property (nonatomic, strong) id <VLMPopModalDelegate> popdelegate;
@property (nonatomic, strong) UIView *headerview;
@property (nonatomic) CGRect contentRect;
@property (nonatomic) CGFloat contentOffsetY;
@property (nonatomic) CGRect headerRect;
@property (nonatomic) CGFloat headerHeight;
@end

@implementation ActivityViewController
@synthesize resultcount;
@synthesize popdelegate;
@synthesize headerview;
@synthesize contentRect;
@synthesize contentOffsetY;

@synthesize headerRect;
@synthesize headerHeight;
#pragma mark - NSObject

- (id)initWithPopDelegate:(id)popmodaldelegate andHeaderView:(UIView *)headview{
    self = [super init];
    if ( self ){
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
        [self.view setBackgroundColor:[UIColor clearColor]];
        
        self.resultcount = 0;
        self.popdelegate = popmodaldelegate;

        self.headerview = headview;
        self.contentOffsetY = 0;
        
        CGFloat winh = [[UIScreen mainScreen] bounds].size.height;
        CGFloat winw = [[UIScreen mainScreen] bounds].size.width-40;
        self.tableView.frame = CGRectMake(0, headerview.frame.size.height, winw, winh - STATUSBAR_HEIGHT - headerview.frame.size.height);
        
        self.contentRect = self.tableView.frame;
        self.headerRect = self.headerview.frame;
        self.headerHeight = headerview.frame.size.height;
    
        
    }
    return self;
    
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone]; 
    [self.tableView setUserInteractionEnabled:NO];
    
    CGFloat winh = [[UIScreen mainScreen] bounds].size.height;
    CGFloat winw = [[UIScreen mainScreen] bounds].size.width;
    [self.tableView setFrame:CGRectMake(0, 0, winw, winh-STATUSBAR_HEIGHT)];
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidDeletePhoto:) name:@"cc.vellum.thisversusthat.notification.userdiddeletepoll" object:nil];

}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"cc.vellum.thisversusthat.notification.userdiddeletepoll" object:nil];
    
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
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[self loadObjects];
    /*
     if (self.shouldReloadOnAppear) {
     self.shouldReloadOnAppear = NO;
     }*/
}



-(void)enable:(BOOL)enabled{
    
    NSLog(@"enable: %@", (enabled)?@"YES":@"NO");
    [self.tableView setUserInteractionEnabled:enabled];
}
- (void)refresh{
    [self loadObjects];
}
#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    if ( ![PFUser currentUser] ) {
        
        [query setLimit:0];
        return query;

    }

    [query includeKey:@"FromUser"];
    [query whereKeyExists:@"FromUser"];
    [query whereKey:@"FromUser" notEqualTo:[PFUser currentUser]];
    [query whereKey:@"ToUser" equalTo:[PFUser currentUser]];
    
    [query includeKey:@"Poll"];
    [query whereKeyExists:@"Poll"];
    
    [query includeKey:@"Poll.PhotoLeft"];
    [query includeKey:@"Poll.PhotoRight"];
    
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    [query setLimit:1000];
    [query orderByDescending:@"createdAt"];
    
    return query;
}

- (PFObject *)objectAtIndex:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row;
    index -= 2;
    if ( index < 0 ){
        return nil;
    }
    if (index >= 0 && index < self.objects.count) {
        return [self.objects objectAtIndex:index];
    }
    return nil;
}
- (void)loadObjects{
    
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


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //if (self.paginationEnabled) return self.objects.count + 1;
    return self.objects.count+3;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    int rowind = indexPath.row - 2;
    
    if ( rowind == -2 ){

        // compute dynamic height based on scroll position
        CGFloat scrollval = tableView.contentOffset.y;
        if ( scrollval < 0 ) scrollval = 0.0f;
        if ( scrollval > headerHeight ) scrollval = headerHeight;
        
        //NSLog(@"rowind -2 / returning %f", scrollval);
        return scrollval;
    }
    
    if ( rowind == -1 ){
        //NSLog(@"rowind -1 / returning 56");
        return 56;
    }
    
    if ( rowind == 0 && self.objects.count == 0 ) {
        //return self.tableView.frame.size.height;
        //NSLog(@"rowind 0, objectcount 0 / returning 56");
        return 56;
    }
    if ( rowind >= self.objects.count ) {
        CGFloat winh = [[UIScreen mainScreen] bounds].size.height;
        CGFloat maxh = winh - STATUSBAR_HEIGHT;
        CGFloat estimatedcontentheight = 0;
        for ( PFObject *row in self.objects ){
            NSString *text;
            NSString *type = [row objectForKey:@"Type"];
            if ( [type isEqualToString:@"like"] ){
                text = @"voted on your poll.";
                estimatedcontentheight += [VLMActivityCell heightForDescriptionText:text];
            }
            if( [type isEqualToString:@"follow"] ){
                text = @"followed you.";
                estimatedcontentheight += [VLMActivityCell heightForDescriptionText:text];
            }
            if( [type isEqualToString:@"comment"] ){
                text = [NSString stringWithFormat: @"commented on your poll.\n\n%@", [row objectForKey:@"Description"]];
                estimatedcontentheight += [VLMActivityCell heightForDescriptionText:text] + 14;
            }
        }
        //NSLog(@"computing estimatedcontentheight: %f", estimatedcontentheight);
        if ( headerview.frame.origin.y < 0 && maxh - estimatedcontentheight > 0 ) {
            //NSLog(@"returning %f", maxh - estimatedcontentheight);
            return maxh - estimatedcontentheight;   
        }
        //NSLog(@"just returning 56");
        return 56;
    }
    
    PFObject *row = [self objectAtIndex:indexPath];
    if (!row) return 0;
    
    NSString *text;
    NSString *type = [row objectForKey:@"Type"];
    if ( [type isEqualToString:@"like"] ){
        text = @"voted on your poll.";
        return [VLMActivityCell heightForDescriptionText:text];
    }
    if( [type isEqualToString:@"follow"] ){
        text = @"followed you.";
        return [VLMActivityCell heightForDescriptionText:text];
    }
    if( [type isEqualToString:@"comment"] ){
        text = [NSString stringWithFormat: @"commented on your poll.\n\n%@", [row objectForKey:@"Description"]];
        return [VLMActivityCell heightForDescriptionText:text] + 14;
    }
    return 0;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int rowind = indexPath.row - 2;
    static NSString *CommentIdentifier = @"commentcell";

    if ( rowind == -2 ){
        VLMActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:CommentIdentifier];
        if ( cell == nil ){
            cell = [[VLMActivityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CommentIdentifier];
            UIView *bg = [[UIView alloc] initWithFrame:CGRectZero];
            [bg setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.05]];
            [cell setSelectedBackgroundView:bg];

            
        }
        cell.contentView.hidden = YES;
        return cell;
    }
    if ( rowind == -1 ){
        
        PFTableViewCell *head = [tableView dequeueReusableCellWithIdentifier:@"activityhead"];
        if ( ! head ){
            CGFloat winw = [[UIScreen mainScreen] bounds].size.width-40;

            head = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"activityhead"];
            [head setFrame:CGRectMake(0, 0, winw, 56)];
            [head.contentView setBackgroundColor:[UIColor clearColor]];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 7, 6*40, 40)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-Bold" size:13.0f]];
            [label setText:@"Activity"];
            [label setTextAlignment:UITextAlignmentCenter];
            [label setBackgroundColor:TEXT_COLOR];
            [label setTextColor:[UIColor whiteColor]];
            [head.contentView addSubview:label];
            head.selectionStyle = UITableViewCellSelectionStyleNone;
            

        }
        return head;
    }
    ////
    
    if ( rowind > -1 && rowind >= [self.objects count] ){
        UITableViewCell *cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        return cell;
    }
    // - - - - - - - - - - - - - - - - - - - - - - - - -

    VLMActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:CommentIdentifier];
    if ( cell == nil ){
        cell = [[VLMActivityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CommentIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        [cell setUserColor:[UIColor colorWithWhite:1.0f alpha:0.9f]];
        [cell setCommentColor:[UIColor colorWithWhite:1.0f alpha:0.75f]];
        UIView *bg = [[UIView alloc] initWithFrame:CGRectZero];
        [bg setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.05]];
        [cell setSelectedBackgroundView:bg];
    }
    cell.contentView.hidden = NO;
    PFObject *row = [self objectAtIndex:indexPath];
    PFUser *u = [row objectForKey:@"FromUser"];
    NSString *un = [u objectForKey:@"displayName"];
    [cell setUser:un];
    [cell setFile:[u objectForKey:@"profilePicSmall"]];
    [cell clearLeftAndRight];
    NSString *text;
    NSString *type = [row objectForKey:@"Type"];
    if ( [type isEqualToString:@"like"] ){
        text = @"voted on your poll.";
        [cell setComment:text];
        PFObject *poll = [row objectForKey:@"Poll"];
        PFObject *photoLeft = [poll objectForKey:@"PhotoLeft"];
        PFFile *leftimage = [photoLeft objectForKey:@"Thumbnail"];
        
        PFObject *photoRight = [poll objectForKey:@"PhotoRight"];
        PFFile *rightimage = [photoRight objectForKey:@"Thumbnail"];

        PFObject *selectedPhoto = [row objectForKey:@"Photo"];
        BOOL isLeft = [[selectedPhoto objectId] isEqualToString:[photoLeft objectId]];
        
        [cell setLeftFile:leftimage];
        [cell setRightFile:rightimage];
        [cell setTriangleDirection:isLeft];
        
    }else if( [type isEqualToString:@"follow"] ){
        text = @"followed you.";
        [cell setComment:text];
    }else if( [type isEqualToString:@"comment"] ){
        text = [row objectForKey:@"Description"];
        [cell setComment:@"commented on your poll." andQuote:text];
    }
    [cell setTime:[row createdAt]];
    return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    //NSLog(@"constructing nextpagecell");
    LoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[LoadMoreCell alloc] initWithFrame:CGRectMake(20, 0, 40*6, 56)  style:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier color:[UIColor colorWithWhite:1.0f alpha:0.75f] disabledcolor:[UIColor colorWithWhite:1.0f alpha:0.5f]];
        
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
    PFObject *row = [self objectAtIndex:indexPath];
    NSString *type = [row objectForKey:@"Type"];
    if ( [type isEqualToString:@"follow"] ){
        // open user page
        PFUser *u = [row objectForKey:@"FromUser"];
        if ( self.popdelegate && u ){
            [popdelegate popUserDetail:u];
        }
        
    } else if ( [type isEqualToString:@"like"] ){
        // open poll
        PFObject *poll = [row objectForKey:@"Poll"];
        if ( self.popdelegate && poll ){
            [popdelegate popPollDetail:poll];
        }
    } else if ( [type isEqualToString:@"comment"] ){
        PFObject *poll = [row objectForKey:@"Poll"];
        if ( self.popdelegate && poll ){
            [popdelegate popPollDetailAndScrollToComments:poll];
        }
    }
}

-(void)didTap:(id)sender{
    [self loadNextPage];
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [super scrollViewDidScroll:scrollView];
    if ( self.objects.count == 0 ) return;
    if ( self.objects.count < 4 ) return;
    
    // get the scroll position of the tableview
    CGFloat lookupY = scrollView.contentOffset.y;
    
    // invert the scroll position and use it as a y offset for positioning 
    // our fake header
    CGFloat headerOffsetY = -lookupY;
    if (headerOffsetY > 0 ) headerOffsetY = 0;
    if (headerOffsetY < -headerHeight ) headerOffsetY = -headerHeight;
    //[self.headerViewController pushVerticallyBy:headerOffsetY];
    [self.headerview setFrame:CGRectOffset(self.headerRect, 0.0f, headerOffsetY)];
    
    // now compute a y offset to apply to the scrollview
    // ( we're pushing this up where the header used to be
    //   or vice versa )
    CGFloat tvOffsetY = headerHeight + headerOffsetY;
    if ( tvOffsetY != self.contentOffsetY )
    {
        ////NSLog(@"%f", tvOffsetY);
        CGFloat winh = [[UIScreen mainScreen] bounds].size.height;
        CGFloat winw = [[UIScreen mainScreen] bounds].size.width-40;
        
        [self.view setFrame: CGRectMake(0, tvOffsetY, winw, winh-tvOffsetY-STATUSBAR_HEIGHT)];
        
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



- (void)userDidDeletePhoto:(NSNotification *)note {
    NSLog(@"userdiddeletephoto");
    // refresh timeline after a delay
    [self performSelector:@selector(loadObjects) withObject:nil afterDelay:1.0f];
}


@end
