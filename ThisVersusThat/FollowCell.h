//
//  FollowCell.h
//  ThisVersusThat
//
//  Created by David Lu on 8/18/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <Parse/Parse.h>

@interface FollowCell : PFTableViewCell
- (void)setFile:(PFFile *)file;
- (void)setText:(NSString *)text;
@end
