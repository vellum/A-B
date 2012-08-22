//
//  VLMTapDelegate.h
//  ThisVersusThat
//
//  Created by David Lu on 8/7/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"

@protocol VLMTapDelegate <NSObject>
- (void)didTapPoll:(PFObject *)poll;
- (void)didTapUser:(PFObject *)user;
- (void)didTapPollAndComment:(PFObject *)poll;
@end
