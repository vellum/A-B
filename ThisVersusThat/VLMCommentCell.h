//
//  VLMCommentCell.h
//  ThisVersusThat
//
//  Created by David Lu on 8/8/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <Parse/Parse.h>

@interface VLMCommentCell : PFTableViewCell
- (void)setFile:(PFFile *)file;
- (void)setUser:(NSString *)username;
- (void)setComment:(NSString *)commenttext;
@end
