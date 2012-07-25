//
//  VLMCellCell.m
//  ThisVersusThat
//
//  Created by David Lu on 7/18/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "VLMCell.h"
#import "VLMConstants.h"
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
        
        UIView *left = [[UIView alloc] initWithFrame:CGRectMake(35, 14-5, 276, 276)];
        left.backgroundColor = [UIColor colorWithWhite:1 alpha:1.0];
        [self.containerView addSubview:left];
        
        UIImageView *leftimage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"left_sample.jpg"]];
        [leftimage setFrame:CGRectMake(5, 5, 266, 266)];
        [left addSubview:leftimage];
        
        UIView *leftShade = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 266, 266)];
        [leftShade setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
        [left addSubview:leftShade];
        
        CGFloat leftPct = 0.25f;
        UIView *leftBar = [[UIView alloc] initWithFrame:CGRectMake(276-5, 5 + (1-leftPct)*266, 5, leftPct*266)];
        [leftBar setBackgroundColor:[UIColor colorWithWhite:0.75 alpha:1.0]];
        [left addSubview:leftBar];
        
        UILabel *leftLabelsmall = [[UILabel alloc] initWithFrame:CGRectMake(0 + 15, 14, 266-30, 266-28)];
        [leftLabelsmall setTextAlignment:UITextAlignmentCenter];
        [leftLabelsmall setFont:[UIFont fontWithName:PHOTO_LABEL size:14.0f]];
        [leftLabelsmall setBackgroundColor:[UIColor clearColor]];
        [leftLabelsmall setTextColor:[UIColor whiteColor]];
        [leftLabelsmall setNumberOfLines:0];
        [leftLabelsmall setText:@"Jennifer Brook\n\n14 votes"];
        [left addSubview:leftLabelsmall];

        /*
        UILabel *leftLabellarge = [[UILabel alloc] initWithFrame:CGRectMake(0 + 15, 14*5, 266-30, 100)];
        [leftLabellarge setTextAlignment:UITextAlignmentCenter];
        [leftLabellarge setFont:[UIFont fontWithName:@"Georgia-Italic" size:36.0f]];
        [leftLabellarge setBackgroundColor:[UIColor clearColor]];
        [leftLabellarge setTextColor:[UIColor whiteColor]];
        [leftLabellarge setText:@"25"];
        [left addSubview:leftLabellarge];
         */

        UIView *right = [[UIView alloc] initWithFrame:CGRectMake(35 + 276, 14-5, 276, 276)];
        right.backgroundColor = [UIColor colorWithWhite:1 alpha:1.0];
        [self.containerView addSubview:right];

        UIImageView *rightimage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right_sample.jpg"]];
        [rightimage setFrame:CGRectMake(5, 5, 266, 266)];
        [right addSubview:rightimage];

        UIView *rightShade = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 266, 266)];
        [rightShade setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
        [right addSubview:rightShade];

        CGFloat rightPct = 0.75f;
        UIView *rightBar = [[UIView alloc] initWithFrame:CGRectMake(0, 5 + (1-rightPct)*266, 5, rightPct*266)];
        [rightBar setBackgroundColor:[UIColor colorWithWhite:0.8 alpha:1.0]];
        [right addSubview:rightBar];

        UILabel *rightLabelsmall = [[UILabel alloc] initWithFrame:CGRectMake(0 + 15, 14, 266-30, 266-28)];
        [rightLabelsmall setTextAlignment:UITextAlignmentCenter];
        [rightLabelsmall setFont:[UIFont fontWithName:PHOTO_LABEL size:14.0f]];
        [rightLabelsmall setBackgroundColor:[UIColor clearColor]];
        [rightLabelsmall setTextColor:[UIColor whiteColor]];
        [rightLabelsmall setNumberOfLines:0];
        [rightLabelsmall setText:@"Veronica Mars\n\n52 votes"];
        [right addSubview:rightLabelsmall];
        
        /*
        UILabel *rightLabellarge = [[UILabel alloc] initWithFrame:CGRectMake(0 + 15, 14*5, 266-30, 100)];
        [rightLabellarge setTextAlignment:UITextAlignmentLeft];
        [rightLabellarge setFont:[UIFont fontWithName:@"Georgia-Italic" size:48.0f]];
        [rightLabellarge setBackgroundColor:[UIColor clearColor]];
        [rightLabellarge setTextColor:[UIColor whiteColor]];
        [rightLabellarge setText:@"75"];
        [right addSubview:rightLabellarge];
         */
        
        UIButton *leftcheck = [[UIButton alloc] initWithFrame:CGRectMake(266/2-56/2, 266-75, 55, 55)];;
        [leftcheck setShowsTouchWhenHighlighted:YES];
        [leftcheck setImage:[UIImage imageNamed:@"vote_button_selected.png"] forState:UIControlStateSelected];
        [leftcheck setImage:[UIImage imageNamed:@"vote_button_normal.png"] forState:UIControlStateNormal];
        [left addSubview:leftcheck];

        UIButton *rightcheck = [[UIButton alloc] initWithFrame:CGRectMake(266/2-56/2, 266-75, 55, 55)];;
        [rightcheck setShowsTouchWhenHighlighted:YES];
        [rightcheck setImage:[UIImage imageNamed:@"vote_button_selected.png"] forState:UIControlStateSelected];
        [rightcheck setImage:[UIImage imageNamed:@"vote_button_normal.png"] forState:UIControlStateNormal];
        [right addSubview:rightcheck];

        
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
        ( self.containerView.frame.origin.x < -275 && val < 0 ))
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
        
    } else if ( val <= -275 ) {
        
        self.originalOffsetX = -275;
        
    } else if (fabsf(self.velocity) > 10 ){
        duration = 275/fabsf(self.velocity);
        if ( duration < 0.3 ) duration = 0.3;
        if ( duration > 1 ) duration = 1;
        if ( self.velocity < 0 ){
            self.originalOffsetX = -275;
        }else {
            self.originalOffsetX = 0;            
        }
    } else {
        if  (fabsf(delta) < 275/2) {
            // do nothing, return to last known page
        } else {
            if ( delta < 0 ) {
                self.originalOffsetX = -275;
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
