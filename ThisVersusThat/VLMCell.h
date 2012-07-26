//
//  VLMCellCell.h
//  ThisVersusThat
//
//  Created by David Lu on 7/18/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VLMCell : UITableViewCell{
    UIView *containerView;
    CGFloat originalOffsetX;
    CGRect originalRect;
    CGFloat velocity;
}

@property (strong, nonatomic) UIView *containerView;
@property (nonatomic) CGFloat velocity;
@property (nonatomic) CGFloat originalOffsetX;
@property (nonatomic) CGRect originalRect;
-(void) translateByX: (CGFloat) offsetval withVelocity: (CGFloat) velocityval;
-(void) resetAnimated:(BOOL)anim;
-(void) killAnimations;


@end
