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

@interface ActivityViewController ()
@property (nonatomic) int resultcount;
@property (nonatomic, strong) id <VLMPopModalDelegate> popdelegate;
@end

@implementation ActivityViewController
@synthesize resultcount;
@synthesize popdelegate;
#pragma mark - NSObject

- (id)initWithPopDelegate:(id)popmodaldelegate{
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
    
    // TABLEHEADER
    UIView *head = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 42 + 28 + 14)];
    [head setBackgroundColor:[UIColor clearColor]];
    
    CGFloat y = 14;
    CGFloat x = 20;
    CGFloat h = 42;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 6*40, h)];
    [label setFont:[UIFont fontWithName:@"AmericanTypewriter-Bold" size:13.0f]];
    [label setText:@"Activity"];
    [label setTextAlignment:UITextAlignmentCenter];
    [label setBackgroundColor:TEXT_COLOR];
    [label setTextColor:[UIColor whiteColor]];
    [head addSubview:label];
    self.tableView.tableHeaderView = head;
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

-(void)enable:(BOOL)enabled{
    [self.tableView setUserInteractionEnabled:enabled];
}

#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    
    if ( ![PFUser currentUser] ) return nil;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:@"ToUser" equalTo:[PFUser currentUser]];
    [query orderByDescending:@"createdAt"];
    [query setLimit:1000];
    [query includeKey:@"FromUser"];
    [query includeKey:@"Poll"];
    [query includeKey:@"Poll.User"];
    [query includeKey:@"Poll.PhotoLeft"];
    [query includeKey:@"Poll.PhotoRight"];
    
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
- (void)loadObjects{
    
    [super loadObjects];
    
    PFQuery *q = [self queryForTable];
    [q countObjectsInBackgroundWithBlock:^(int number, NSError *error){
        if ( !error ){
            self.resultcount = number;
        }
    }];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //if (self.paginationEnabled) return self.objects.count + 1;
    return self.objects.count+1;
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
    if ( indexPath.row >= self.objects.count ) return 56;
    PFObject *row = [self objectAtIndex:indexPath];

    NSString *text;
    NSString *type = [row objectForKey:@"Type"];
    if ( [type isEqualToString:@"like"] ){
        text = @"voted on your poll.";
    }else if( [type isEqualToString:@"follow"] ){
        text = @"followed you.";
    }else if( [type isEqualToString:@"comment"] ){
        text = [NSString stringWithFormat: @"commented on your poll.\n\n%@", [row objectForKey:@"Description"]];
    }

    return [VLMActivityCell heightForDescriptionText:text];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( indexPath.row >= [self.objects count] ){
        UITableViewCell *cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        return cell;
    }

    // - - - - - - - - - - - - - - - - - - - - - - - - -

    static NSString *CommentIdentifier = @"commentcell";
    VLMActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:CommentIdentifier];
    if ( cell == nil ){
        cell = [[VLMActivityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CommentIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setUserColor:[UIColor colorWithWhite:1.0f alpha:0.9f]];
        [cell setCommentColor:[UIColor colorWithWhite:1.0f alpha:0.75f]];
    }
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
    return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    NSLog(@"constructing nextpagecell");
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
        if ( self.popdelegate ){
            [popdelegate popUserDetail:u];
        }
        
    } else if ( [type isEqualToString:@"like"] || [type isEqualToString:@"comment"] ){
        // open poll
        PFObject *poll = [row objectForKey:@"Poll"];
        if ( self.popdelegate ){
            [popdelegate popPollDetail:poll];
        }
    }
}

-(void)didTap:(id)sender{
    [self loadNextPage];
}

@end
