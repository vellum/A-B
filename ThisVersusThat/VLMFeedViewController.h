//
//  VLMFeedViewController.h
//  ThisVersusThat
//
//  Created by David Lu on 7/17/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VLMFeedTableViewController.h"
#import "VLMFeedHeaderController.h"

@interface VLMFeedViewController : UIViewController<UIGestureRecognizerDelegate> {
    VLMFeedHeaderController *headerViewController;
    VLMFeedTableViewController *tableViewController;
    NSInteger recognizedPanDirection;
    UITableViewCell *selectedCell;
}

@property (strong, nonatomic) VLMFeedHeaderController *headerViewController;
@property (strong, nonatomic) VLMFeedTableViewController *tableViewController;
@property (nonatomic) NSInteger recognizedPanDirection;
@property (nonatomic) UITableViewCell *selectedCell;

@end
