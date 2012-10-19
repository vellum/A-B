//
//  FollowerController.h
//  ThisVersusThat
//
//  Created by David Lu on 8/18/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <Parse/Parse.h>

@interface FollowerController : PFQueryTableViewController<UITableViewDelegate>
- (id)initWithObject:(PFUser *)obj isRoot:(BOOL)isRoot modeFollowing:(BOOL)isFollowingMode;
- (void)back:(id)sender;
@end
