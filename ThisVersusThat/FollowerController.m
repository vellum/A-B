//
//  FollowerController.m
//  ThisVersusThat
//
//  Created by David Lu on 8/18/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "FollowerController.h"
#import "FollowCell.h"
#import "VLMUserDetailController.h"

@interface FollowerController ()
@property (nonatomic) BOOL isRootContoller;
@property (nonatomic) BOOL useFollowingQuery;
@property (nonatomic, strong) PFUser *user;
@end

@implementation FollowerController
@synthesize isRootContoller;
@synthesize useFollowingQuery;
@synthesize user;

- (id)initWithObject:(PFUser *)obj isRoot:(BOOL)isRoot modeFollowing:(BOOL)isFollowingMode{
    self = [super initWithClassName:@"User"];
    if ( self ){
        self.user = obj;
        self.isRootContoller = isRoot;
        self.useFollowingQuery = isFollowingMode;
        [self.tableView setBackgroundColor:[UIColor clearColor]];
        [self.view setBackgroundColor:[UIColor clearColor]];
        if ( isFollowingMode ){
            self.title = @"Following";
        }else {
            self.title = @"Followers";
        }
        [self.tableView setAllowsSelection:YES];
        [self.tableView setDelegate:self];
        NSLog(@"here");
    }
    return self;
}

- (void)viewDidLoad
{
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone]; 
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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

- (PFQuery *)queryForTable{
    PFQuery *q = [[PFQuery alloc] initWithClassName:@"Activity"];
    [q setLimit:1000];
    [q orderByDescending:@"createdAt"];
    [q setCachePolicy:kPFCachePolicyNetworkOnly];
    [q whereKey:@"Type" equalTo:@"follow"];

    if ( self.useFollowingQuery ){
        [q whereKey:@"FromUser" equalTo:self.user];
        [q includeKey:@"ToUser"];
    } else {
        [q whereKey:@"ToUser" equalTo:self.user];
        [q includeKey:@"FromUser"];
    }
    return q;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PFObject *row = [self objectAtIndex:indexPath];
    PFUser * u = self.useFollowingQuery ? (PFUser *)[row objectForKey:@"ToUser"] : (PFUser *)[row objectForKey:@"FromUser"];
    if (!u) return;
    VLMUserDetailController *deet = [[VLMUserDetailController alloc] initWithObject:u isRoot:NO];
    [self.navigationController pushViewController:deet animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 4*14+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%d", indexPath.row);
    FollowCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"followcell"];
    if (!cell){
        cell = [[FollowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"followcell"];
        UIView *bg = [[UIView alloc] initWithFrame:CGRectZero];
        //[cell setSelectionStyle:UITableViewCellEditingStyleNone];
        [bg setBackgroundColor:[UIColor colorWithWhite:0.95f alpha:1.0f]];
        [cell setSelectedBackgroundView:bg];
    }
    PFObject *row = [self objectAtIndex:indexPath];
    PFUser * u = self.useFollowingQuery ? (PFUser *)[row objectForKey:@"ToUser"] : (PFUser *)[row objectForKey:@"FromUser"];
    
    [cell setFile:[u objectForKey:@"profilePicSmall"]];
    [cell setText:[u objectForKey:@"displayName"]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}


@end
