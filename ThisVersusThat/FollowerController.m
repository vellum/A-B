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
@property (nonatomic, strong) NSMutableDictionary *outstandingQueries;

@end

@implementation FollowerController
@synthesize isRootContoller;
@synthesize useFollowingQuery;
@synthesize user;
@synthesize outstandingQueries;

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
        self.outstandingQueries = [NSMutableDictionary dictionary]; 
    }
    return self;
}

- (void)viewDidLoad
{
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone]; 
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.navigationItem setHidesBackButton:YES];
    UIBarButtonItem *backbutton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    [self.navigationItem setLeftBarButtonItem:backbutton];
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
    PFQuery *q = [PFQuery queryWithClassName:@"Activity"];//[[PFQuery alloc] initWithClassName:@"Activity"];
    [q whereKey:@"Type" equalTo:@"follow"];

    if ( self.useFollowingQuery ){
        [q includeKey:@"ToUser"];
        [q whereKeyExists:@"ToUser"];
        [q whereKey:@"FromUser" equalTo:self.user];
    } else {
        [q includeKey:@"FromUser"];
        [q whereKeyExists:@"FromUser"];
        [q whereKey:@"ToUser" equalTo:self.user];
    }
    [q setLimit:1000];
    [q orderByDescending:@"createdAt"];
    [q setCachePolicy:kPFCachePolicyCacheThenNetwork];
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
    if ( ![self objectAtIndex:indexPath] ) return 0;
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
- (PFObject *)objectAtIndex:(NSIndexPath *)indexPath {
    if (indexPath.row < self.objects.count) {
        return [self.objects objectAtIndex:indexPath.row];
    }
    return nil;
}

- (void)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
