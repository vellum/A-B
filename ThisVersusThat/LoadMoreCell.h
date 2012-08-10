//
//  LoadMoreCell.h
//  ThisVersusThat
//
//  Created by David Lu on 8/6/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VLMFeedTableViewController;

@interface LoadMoreCell : UITableViewCell{
    VLMFeedTableViewController *tv;
}
@property (strong, nonatomic) VLMFeedTableViewController *tv;

- (void)reset:(BOOL)hasMoreItems isLoading:(BOOL)loading;
- (void)translateByX: (CGFloat) offsetval withVelocity: (CGFloat) velocityval;
- (void)resetAnimated:(BOOL)anim;
- (void)killAnimations;
- (void)setInitialPage:(BOOL)leftside;
@end
