//
//  VLMCellCell.m
//  ThisVersusThat
//
//  Created by David Lu on 7/18/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "VLMCell.h"
#import <QuartzCore/QuartzCore.h>
@implementation VLMCell

@synthesize containerView;
@synthesize originalOffsetX;
@synthesize originalRect;
@synthesize velocity;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setAutoresizesSubviews:NO];

        // Initialization code
        self.originalOffsetX = 0.0f;
        self.backgroundColor = [UIColor clearColor];
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 640.0f, 294.0f)];
        self.velocity = 0;
        
        UIView *left = [[UIView alloc] initWithFrame:CGRectMake(40, 14, 266, 266)];
        left.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        [self.containerView addSubview:left];

        UIView *right = [[UIView alloc] initWithFrame:CGRectMake(40 + 266 + 5, 14, 266, 266)];
        right.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        [self.containerView addSubview:right];
        self.originalRect = self.containerView.frame;

        [self.contentView addSubview:self.containerView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.userInteractionEnabled = YES;
    }
    return self;
}

-(void) translateByX: (CGFloat) offsetval withVelocity:(CGFloat)velocityval{
    CGFloat val = offsetval;
    self.velocity = velocityval;
    if (( self.containerView.frame.origin.x >= 0 && val > 0 ) ||
        ( self.containerView.frame.origin.x < -270 && val < 0 ))
    {
        val /= 4.0;
    }
    
    // preserve the previous animation state
    BOOL animationsEnabled = [UIView areAnimationsEnabled];
    
    // kill animations
    [UIView setAnimationsEnabled:NO];
    [self.containerView.layer removeAllAnimations];

    self.containerView.frame = CGRectOffset(self.containerView.frame, val, 0);
    
    // restore the previous animation state
    [UIView setAnimationsEnabled:animationsEnabled];
    
    // if we're panning turn off user input for this cell
    self.userInteractionEnabled = NO;
    NSLog(@"%f", val);
}

-(void) resetAnimated:(BOOL)anim{
    

    CGFloat val = self.containerView.frame.origin.x;
    CGFloat delta = self.containerView.frame.origin.x - self.originalOffsetX;
    CGFloat duration = 0.5;
    UIViewAnimationCurve curve = UIViewAnimationOptionCurveEaseOut;
    if ( val >= 0 ) {

        self.originalOffsetX = 0;
        
    } else if ( val <= -270 ) {
        
        self.originalOffsetX = -270;
        
    } else if (fabsf(self.velocity) > 10 ){
        duration = 270/fabsf(self.velocity);
        if ( duration < 0.3 ) duration = 0.3;
        if ( duration > 1 ) duration = 1;
        if ( self.velocity < 0 ){
            self.originalOffsetX = -270;
        }else {
            self.originalOffsetX = 0;            
        }
    } else {
        if  (fabsf(delta) < 266/2) {
            // do nothing, return to last known page
        } else {
            if ( delta < 0 ) {
                self.originalOffsetX = -270;
            }
            else if ( delta > 0 ) {
                self.originalOffsetX = 0;
            }
        }
    }
    [UIView animateWithDuration:duration
            delay:0 
            options:curve|UIViewAnimationOptionBeginFromCurrentState
            animations:^{
                self.containerView.frame = CGRectOffset(self.originalRect, self.originalOffsetX, 0.0f);
            }
            completion:^(BOOL finished){
                self.userInteractionEnabled = YES;
            }
     ];
}
@end
