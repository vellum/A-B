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
#import "Parse/Parse.h"

@implementation VLMCell


@synthesize containerView;
@synthesize originalOffsetX;
@synthesize originalRect;
@synthesize velocity;
@synthesize leftfile;
@synthesize rightfile;
@synthesize leftcaption;
@synthesize rightcaption;
@synthesize leftnumvotes;
@synthesize rightnumvotes;
@synthesize leftvotecount;
@synthesize rightvotecount;
@synthesize leftcheck;
@synthesize rightcheck;

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
        self.leftvotecount = 0;
        self.rightvotecount = 0;
        
        UIView *left = [[UIView alloc] initWithFrame:CGRectMake(20, 14, 286, 286)];
        left.backgroundColor = [UIColor colorWithWhite:1 alpha:1.0];
        [self.containerView addSubview:left];
        
        PFImageView *leftimage = [[PFImageView alloc] initWithFrame:CGRectMake(5, 5, 276, 276)];
        [left addSubview:leftimage];
        self.leftfile = leftimage;
        
        UIView *leftShade = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 276, 276)];
        [leftShade setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
        [left addSubview:leftShade];
        
        //CGFloat leftPct = 0.25f;
        //UIView *leftBar = [[UIView alloc] initWithFrame:CGRectMake(286-5, 5 + (1-leftPct)*276, 5, leftPct*276)];
        //[leftBar setBackgroundColor:[UIColor colorWithWhite:0.75 alpha:1.0]];
        //[left addSubview:leftBar];
        
        self.leftcaption = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 286-30, 286/2)];
        [self.leftcaption setTextAlignment:UITextAlignmentCenter];
        [self.leftcaption setContentMode:UIViewContentModeBottom];
        [self.leftcaption setFont:[UIFont fontWithName:PHOTO_LABEL size:21.0f]];
        [self.leftcaption setBackgroundColor:[UIColor clearColor]];
        [self.leftcaption setTextColor:[UIColor whiteColor]];
        [left addSubview:self.leftcaption];
        
        self.leftnumvotes = [[UILabel alloc] initWithFrame:CGRectMake(15, 286/2+7, 286-30, 14)];
        [self.leftnumvotes setTextAlignment:UITextAlignmentCenter];
        [self.leftnumvotes setFont:[UIFont fontWithName:PHOTO_LABEL size:14.0f]];
        [self.leftnumvotes setBackgroundColor:[UIColor clearColor]];
        [self.leftnumvotes setTextColor:[UIColor whiteColor]];
        [left addSubview:self.leftnumvotes];


        UIView *right = [[UIView alloc] initWithFrame:CGRectMake(35 + 276, 14, 286, 286)];
        right.backgroundColor = [UIColor colorWithWhite:1 alpha:1.0];
        [self.containerView addSubview:right];

        PFImageView *rightimage = [[PFImageView alloc] initWithFrame:CGRectMake(5, 5, 276, 276)];
        [right addSubview:rightimage];
        self.rightfile = rightimage;

        UIView *rightShade = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 276, 276)];
        [rightShade setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
        [right addSubview:rightShade];

        //CGFloat rightPct = 0.75f;
        //UIView *rightBar = [[UIView alloc] initWithFrame:CGRectMake(0, 5 + (1-rightPct)*276, 5, rightPct*276)];
        //[rightBar setBackgroundColor:[UIColor colorWithWhite:0.75 alpha:1.0]];
        //[right addSubview:rightBar];

        self.rightcaption = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 286-30, 286/2)];
        [self.rightcaption setTextAlignment:UITextAlignmentCenter];
        [self.rightcaption setContentMode:UIViewContentModeBottom];
        [self.rightcaption setFont:[UIFont fontWithName:PHOTO_LABEL size:21.0f]];
        [self.rightcaption setBackgroundColor:[UIColor clearColor]];
        [self.rightcaption setTextColor:[UIColor whiteColor]];
        [right addSubview:self.rightcaption];
        
        self.rightnumvotes = [[UILabel alloc] initWithFrame:CGRectMake(15, 286/2+7, 286-30, 14)];
        [self.rightnumvotes setTextAlignment:UITextAlignmentCenter];
        [self.rightnumvotes setFont:[UIFont fontWithName:PHOTO_LABEL size:14.0f]];
        [self.rightnumvotes setBackgroundColor:[UIColor clearColor]];
        [self.rightnumvotes setTextColor:[UIColor whiteColor]];
        [right addSubview:self.rightnumvotes];
        
        
        self.leftcheck = [[UIButton alloc] initWithFrame:CGRectMake(286/2-56/2, 286-65, 55, 55)];;
        [leftcheck setShowsTouchWhenHighlighted:YES];
        [leftcheck setImage:[UIImage imageNamed:@"vote_button_selected.png"] forState:UIControlStateSelected];
        [leftcheck setImage:[UIImage imageNamed:@"vote_button_normal.png"] forState:UIControlStateNormal];
        [leftcheck addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];

        [left addSubview:leftcheck];

        self.rightcheck = [[UIButton alloc] initWithFrame:CGRectMake(286/2-56/2, 286-65, 55, 55)];;
        [rightcheck setShowsTouchWhenHighlighted:YES];
        [rightcheck setImage:[UIImage imageNamed:@"vote_button_selected.png"] forState:UIControlStateSelected];
        [rightcheck setImage:[UIImage imageNamed:@"vote_button_normal.png"] forState:UIControlStateNormal];
        [rightcheck addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [right addSubview:rightcheck];

        
        self.originalRect = self.containerView.frame;
        [self.contentView addSubview:self.containerView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.userInteractionEnabled = YES;
    }
    return self;
}

-(void)buttonTapped:(id)sender{
    
    if ( sender == self.leftcheck ){
        
        self.leftcheck.selected = !self.leftcheck.selected;
        self.rightcheck.enabled = !self.leftcheck.selected;
        
    } else if ( sender == self.rightcheck ){

        self.rightcheck.selected = !self.rightcheck.selected;
        self.leftcheck.enabled = !self.rightcheck.selected;
        
    }
    
}

-(void) translateByX: (CGFloat) offsetval withVelocity:(CGFloat)velocityval{
    CGFloat val = offsetval;
    self.velocity = velocityval;
    if (( self.containerView.frame.origin.x >= 0 && val > 0 ) ||
        ( self.containerView.frame.origin.x < -290 && val < 0 ))
    {
        val /= 4.0;
    }
    
    /*
    // THIS WORKS BUT DISPLAYS JERKY BEHAVIOR IF TRANSLATE BEGINS WHILE 
    // THE VIEW IS ALREADY BEING ANIMATED
    // preserve the previous animation state
    BOOL animationsEnabled = [UIView areAnimationsEnabled];
    
    // kill animations
    [UIView setAnimationsEnabled:NO];
    [self.containerView.layer removeAllAnimations];

    //self.containerView.frame = CGRectOffset(self.containerView.frame, val, 0);
    
    // restore the previous animation state
    [UIView setAnimationsEnabled:animationsEnabled];
    //*/
    
    [UIView animateWithDuration:0
                          delay:0 
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.containerView.frame = CGRectOffset(self.containerView.frame, val, 0);
                     }
                     completion:nil
     ];

    
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
        
    } else if ( val <= -290 ) {
        
        self.originalOffsetX = -290;
        
    } else if (fabsf(self.velocity) > 10 ){
        duration = 290/fabsf(self.velocity);
        if ( duration < 0.3 ) duration = 0.3;
        if ( duration > 1 ) duration = 1;
        if ( self.velocity < 0 ){
            self.originalOffsetX = -290;
        }else {
            self.originalOffsetX = 0;            
        }
    } else {
        if  (fabsf(delta) < 290/2) {
            // do nothing, return to last known page
        } else {
            if ( delta < 0 ) {
                self.originalOffsetX = -290;
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

-(void)killAnimations{
    BOOL animationsEnabled = [UIView areAnimationsEnabled];
    
    // kill animations
    [UIView setAnimationsEnabled:NO];
    [self.containerView.layer removeAllAnimations];

    // restore the previous animation state
    [UIView setAnimationsEnabled:animationsEnabled];

}

- (void)setLeftFile: (PFFile *)left andRightFile: (PFFile *)right{
    if ( !left || !right ) return;
    
    self.leftfile.image = [UIImage imageNamed:@"clear.png"];
    self.leftfile.file = left;
    [self.leftfile loadInBackground];

    self.rightfile.image = [UIImage imageNamed:@"clear.png"];
    self.rightfile.file = right;
    [self.rightfile loadInBackground];
}

- (void)setLeftCaptionText: (NSString *)left andRightCaptionText: (NSString *)right{
    [self.leftcaption setText:left];
    [self.leftcaption sizeToFit];
    [self.leftcaption setFrame:CGRectMake(15, 286/2 - (self.leftcaption.frame.size.height + 28 )/2, 286-30, self.leftcaption.frame.size.height)];
    [self.leftnumvotes setFrame:CGRectMake(15, self.leftcaption.frame.origin.y + self.leftcaption.frame.size.height+7, 286-30, 28)];
    [self.leftnumvotes setText:@"0 votes"];

    [self.rightcaption setText:right];
    [self.rightcaption sizeToFit];
    [self.rightcaption setFrame:CGRectMake(15, 286/2 - (self.rightcaption.frame.size.height + 28 )/2, 286-30, self.rightcaption.frame.size.height)];
    [self.rightnumvotes setFrame:CGRectMake(15, self.rightcaption.frame.origin.y + self.rightcaption.frame.size.height+7, 286-30, 28)];
    [self.rightnumvotes setText:@"0 votes"];
}
@end
