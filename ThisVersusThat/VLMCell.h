//
//  VLMCellCell.h
//  ThisVersusThat
//
//  Created by David Lu on 7/18/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"


@interface VLMCell : PFTableViewCell{
    UIView *containerView;
    CGFloat originalOffsetX;
    CGRect originalRect;
    CGFloat velocity;
    PFImageView *leftfile;
    PFImageView *rightfile;
    UILabel *leftcaption;
    UILabel *rightcaption;
    UILabel *leftnumvotes;
    UILabel *rightnumvotes;
    CGFloat leftvotecount;
    CGFloat rightvotecount;
    UIButton *leftcheck;
    UIButton *rightcheck;
}

@property (strong, nonatomic) UIView *containerView;
@property (nonatomic) CGFloat velocity;
@property (nonatomic) CGFloat originalOffsetX;
@property (nonatomic) CGRect originalRect;
@property (nonatomic, strong) PFImageView *leftfile;
@property (nonatomic, strong) PFImageView *rightfile;
@property (nonatomic, strong) UILabel *leftcaption;
@property (nonatomic, strong) UILabel *rightcaption;
@property (nonatomic, strong) UILabel *leftnumvotes;
@property (nonatomic, strong) UILabel *rightnumvotes;
@property (nonatomic, strong) UIButton *leftcheck;
@property (nonatomic, strong) UIButton *rightcheck;

@property (nonatomic) CGFloat leftvotecount;
@property (nonatomic) CGFloat rightvotecount;

- (void)translateByX: (CGFloat) offsetval withVelocity: (CGFloat) velocityval;
- (void)resetAnimated:(BOOL)anim;
- (void)killAnimations;

- (void)setLeftFile: (PFFile *)left andRightFile: (PFFile *)right;
- (void)setLeftCaptionText: (NSString *)left andRightCaptionText: (NSString *)right;
@end
