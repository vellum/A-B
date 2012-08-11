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
#import "VLMTapDelegate.h"
#import "VLMMainViewController.h"
#import "VLMGenericTapDelegate.h"

@protocol VLMPopModalDelegate;

@interface VLMFeedViewController : UIViewController<UIGestureRecognizerDelegate, VLMTapDelegate, VLMGenericTapDelegate> {
    VLMFeedHeaderController *headerViewController;
    VLMFeedTableViewController *tableViewController;
    NSInteger recognizedPanDirection;
    UITableViewCell *__unsafe_unretained selectedCell;
    id <VLMPopModalDelegate>popDelegate;
}

@property (strong, nonatomic) VLMFeedHeaderController *headerViewController;
@property (strong, nonatomic) VLMFeedTableViewController *tableViewController;
@property (nonatomic) NSInteger recognizedPanDirection;
@property (unsafe_unretained, nonatomic) UITableViewCell *selectedCell;
@property (strong, nonatomic) id <VLMPopModalDelegate> popDelegate;

-(id)initWithTapDelegate:(id)delegate;
-(void)updatelayout;
-(void)refreshfeed;

@end
