//
//  LoadMoreCell.h
//  ThisVersusThat
//
//  Created by David Lu on 8/6/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VLMTapDelegate.h"
@interface LoadMoreCell : UITableViewCell{
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier color:(UIColor*)color disabledcolor:(UIColor*)disabledcolor;

- (id)initWithFrame:(CGRect)frame style:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier color:(UIColor*)color disabledcolor:(UIColor*)disabledcolor;

- (void)reset:(BOOL)hasMoreItems isLoading:(BOOL)loading;
- (void)translateByX: (CGFloat) offsetval withVelocity: (CGFloat) velocityval;
- (void)resetAnimated:(BOOL)anim;
- (void)killAnimations;
- (void)setInitialPage:(BOOL)leftside;

- (void)setTextColor:(UIColor *)textColor;
- (void)setDelegate:(id)delegate;
@end
