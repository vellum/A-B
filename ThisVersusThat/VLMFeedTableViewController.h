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
#import "VLMFeedHeaderDelegate.h"
#import "VLMTapDelegate.h"
#import "VLMGenericTapDelegate.h"
#import "VLMPopModalDelegate.h"
#import "VLMFeedbackDelegate.h"

@interface VLMFeedTableViewController : PFQueryTableViewController<UIScrollViewDelegate, VLMSectionDelegate, VLMTapDelegate, VLMGenericTapDelegate, VLMPopModalDelegate, VLMFeedbackDelegate, UIActionSheetDelegate>{
    id <VLMTapDelegate> delegate;
}
@property (nonatomic, strong) id <VLMTapDelegate> delegate;

- (id)initWithHeader:(VLMFeedHeaderController *) headerController;
- (void)updatelayout;
- (void)setDirection:(BOOL)isLeft ForPoll:(PFObject *)poll;
- (void)setFeedType:(int)feedtype;

@end
