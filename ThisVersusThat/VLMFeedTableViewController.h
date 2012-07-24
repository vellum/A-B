//
//  VLMFeedTableViewController.h
//  ThisVersusThat
//
//  Created by David Lu on 7/17/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VLMFeedHeaderController.h"

@interface VLMFeedTableViewController : UITableViewController{
    CGRect contentRect;
    CGFloat contentOffsetY;
    VLMFeedHeaderController *headerViewController;
}

-(id) initWithHeader:(VLMFeedHeaderController *) headerController;

@property (strong, nonatomic) VLMFeedHeaderController *headerViewController;
@property (nonatomic) CGRect contentRect;
@property (nonatomic) CGFloat contentOffsetY;
-(void)updatelayout;
@end
