//
//  VLMCellCell.h
//  ThisVersusThat
//
//  Created by David Lu on 7/18/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
@class VLMFeedTableViewController;

@interface VLMCell : PFTableViewCell{
    UIView *containerView;
    CGFloat originalOffsetX;
    CGRect originalRect;
    CGFloat velocity;

    PFObject *objPoll;
    
    PFImageView *imageviewLeft;
    PFImageView *imageviewRight;
    
    VLMFeedTableViewController *tv;

    UILabel *captionlabelLeft;
    UILabel *captionLabelRight;
    UILabel *votecountlabelLeft;
    UILabel *votecountlabelRight;
    int leftvotecount;
    int rightvotecount;
    UIButton *leftcheck;
    UIButton *rightcheck;
    
    int personalvotecountleft;
    int personalvotecountright;
}

@property (strong, nonatomic) UIView *containerView;
@property (nonatomic) CGFloat velocity;
@property (nonatomic) CGFloat originalOffsetX;
@property (nonatomic) CGRect originalRect;

@property (nonatomic, strong) PFObject *objPoll;
@property (nonatomic, strong) PFImageView *imageviewLeft;
@property (nonatomic, strong) PFImageView *imageviewRight;
@property (nonatomic, strong) VLMFeedTableViewController *tv;

@property (nonatomic, strong) UILabel *captionlabelLeft;
@property (nonatomic, strong) UILabel *captionLabelRight;
@property (nonatomic, strong) UILabel *votecountlabelLeft;
@property (nonatomic, strong) UILabel *votecountlabelRight;
@property (nonatomic, strong) UIButton *leftcheck;
@property (nonatomic, strong) UIButton *rightcheck;

@property (nonatomic) int leftvotecount;
@property (nonatomic) int rightvotecount;
@property (nonatomic) int personalvotecountleft;
@property (nonatomic) int personalvotecountright;


- (void)translateByX: (CGFloat) offsetval withVelocity: (CGFloat) velocityval;
- (void)resetAnimated:(BOOL)anim;
- (void)killAnimations;

- (void)setPoll: (PFObject *)poll;
- (void)setLeftFile: (PFFile *)left andRightFile: (PFFile *)right;
- (void)setLeftCaptionText: (NSString *)left andRightCaptionText: (NSString *)right;

- (void)setLeftCount:(NSInteger)left andRightCount:(NSInteger)right;
- (void)setPersonalLeftCount:(NSInteger)left andPersonalRightCount:(NSInteger)right;

-(void)setInitialPage:(BOOL)leftside;

- (void)resetCell;
- (void)setContentVisible:(BOOL)isVisible;
@end
