//
//  VLMFeedTableViewController.h
//  ThisVersusThat
//
//  Created by David Lu on 7/17/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VLMFeedHeaderController.h"
#import "Parse/Parse.h"

@interface VLMFeedTableViewController : PFQueryTableViewController<UIScrollViewDelegate>{
}

- (id)initWithHeader:(VLMFeedHeaderController *) headerController;
- (void)updatelayout;
- (void)setDirection:(BOOL)isLeft ForPoll:(PFObject *)poll;
@end
