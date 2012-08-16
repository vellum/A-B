//
//  VLMPopModalDelegate.h
//  ThisVersusThat
//
//  Created by David Lu on 8/7/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VLMPopModalDelegate <NSObject>

- (void)popPollDetail:(PFObject *)poll;
- (void)popUserDetail:(PFUser *)user;
- (void)popPollDetailAndScrollToComments:(PFObject *)poll;

@end
