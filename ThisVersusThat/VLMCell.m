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
#import "VLMUtility.h"

@interface VLMCell()
@property (nonatomic, strong) NSMutableDictionary *outstandingQueries;
@end

@implementation VLMCell

@synthesize containerView;
@synthesize velocity;
@synthesize originalOffsetX;
@synthesize originalRect;

@synthesize objPoll;
@synthesize imageviewLeft;
@synthesize imageviewRight;

@synthesize captionlabelLeft;
@synthesize captionLabelRight;
@synthesize votecountlabelLeft;
@synthesize votecountlabelRight;
@synthesize leftvotecount;
@synthesize rightvotecount;
@synthesize leftcheck;
@synthesize rightcheck;
@synthesize personalvotecountleft;
@synthesize personalvotecountright;
@synthesize outstandingQueries;

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
        self.outstandingQueries = [NSMutableDictionary dictionary];        
        
        UIView *left = [[UIView alloc] initWithFrame:CGRectMake(20-5, 14, 286, 286)];
        left.backgroundColor = [UIColor colorWithWhite:1 alpha:1.0];
        [self.containerView addSubview:left];
        
        PFImageView *leftimage = [[PFImageView alloc] initWithFrame:CGRectMake(5, 5, 276, 276)];
        [left addSubview:leftimage];
        self.imageviewLeft = leftimage;
        
        UIView *leftShade = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 276, 276)];
        [leftShade setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
        [left addSubview:leftShade];
        
        //CGFloat leftPct = 0.25f;
        //UIView *leftBar = [[UIView alloc] initWithFrame:CGRectMake(286-5, 5 + (1-leftPct)*276, 5, leftPct*276)];
        //[leftBar setBackgroundColor:[UIColor colorWithWhite:0.75 alpha:1.0]];
        //[left addSubview:leftBar];
        
        self.captionlabelLeft = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 286-30, 286/2)];
        [self.captionlabelLeft setTextAlignment:UITextAlignmentCenter];
        [self.captionlabelLeft setContentMode:UIViewContentModeBottom];
        [self.captionlabelLeft setFont:[UIFont fontWithName:PHOTO_LABEL size:21.0f]];
        [self.captionlabelLeft setBackgroundColor:[UIColor clearColor]];
        [self.captionlabelLeft setTextColor:[UIColor whiteColor]];
        [left addSubview:self.captionlabelLeft];
        
        self.votecountlabelLeft = [[UILabel alloc] initWithFrame:CGRectMake(15, 286/2+7, 286-30, 14)];
        [self.votecountlabelLeft setTextAlignment:UITextAlignmentCenter];
        [self.votecountlabelLeft setFont:[UIFont fontWithName:PHOTO_LABEL size:14.0f]];
        [self.votecountlabelLeft setBackgroundColor:[UIColor clearColor]];
        [self.votecountlabelLeft setTextColor:[UIColor whiteColor]];
        [left addSubview:self.votecountlabelLeft];


        UIView *right = [[UIView alloc] initWithFrame:CGRectMake(35 + 276 -5, 14, 286, 286)];
        right.backgroundColor = [UIColor colorWithWhite:1 alpha:1.0];
        [self.containerView addSubview:right];

        PFImageView *rightimage = [[PFImageView alloc] initWithFrame:CGRectMake(5, 5, 276, 276)];
        [right addSubview:rightimage];
        self.imageviewRight = rightimage;

        UIView *rightShade = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 276, 276)];
        [rightShade setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
        [right addSubview:rightShade];

        //CGFloat rightPct = 0.75f;
        //UIView *rightBar = [[UIView alloc] initWithFrame:CGRectMake(0, 5 + (1-rightPct)*276, 5, rightPct*276)];
        //[rightBar setBackgroundColor:[UIColor colorWithWhite:0.75 alpha:1.0]];
        //[right addSubview:rightBar];

        self.captionLabelRight = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 286-30, 286/2)];
        [self.captionLabelRight setTextAlignment:UITextAlignmentCenter];
        [self.captionLabelRight setContentMode:UIViewContentModeBottom];
        [self.captionLabelRight setFont:[UIFont fontWithName:PHOTO_LABEL size:21.0f]];
        [self.captionLabelRight setBackgroundColor:[UIColor clearColor]];
        [self.captionLabelRight setTextColor:[UIColor whiteColor]];
        [right addSubview:self.captionLabelRight];
        
        self.votecountlabelRight = [[UILabel alloc] initWithFrame:CGRectMake(15, 286/2+7, 286-30, 14)];
        [self.votecountlabelRight setTextAlignment:UITextAlignmentCenter];
        [self.votecountlabelRight setFont:[UIFont fontWithName:PHOTO_LABEL size:14.0f]];
        [self.votecountlabelRight setBackgroundColor:[UIColor clearColor]];
        [self.votecountlabelRight setTextColor:[UIColor whiteColor]];
        [right addSubview:self.votecountlabelRight];
        
        
        self.leftcheck = [[UIButton alloc] initWithFrame:CGRectMake(286/2-56/2, 286-65, 55, 55)];;
        [leftcheck setShowsTouchWhenHighlighted:YES];
        [leftcheck setImage:[UIImage imageNamed:@"vote_button_selected.png"] forState:UIControlStateSelected];
        [leftcheck setImage:[UIImage imageNamed:@"vote_button_normal.png"] forState:UIControlStateNormal];
        [leftcheck addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [leftcheck setEnabled:NO];
        [left addSubview:leftcheck];

        self.rightcheck = [[UIButton alloc] initWithFrame:CGRectMake(286/2-56/2, 286-65, 55, 55)];;
        [rightcheck setShowsTouchWhenHighlighted:YES];
        [rightcheck setImage:[UIImage imageNamed:@"vote_button_selected.png"] forState:UIControlStateSelected];
        [rightcheck setImage:[UIImage imageNamed:@"vote_button_normal.png"] forState:UIControlStateNormal];
        [rightcheck addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [rightcheck setEnabled:NO];
        [right addSubview:rightcheck];
        
        self.originalRect = self.containerView.frame;
        [self.contentView addSubview:self.containerView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.userInteractionEnabled = YES;
        
        self.personalvotecountleft = -1;
        self.personalvotecountright = -1;
        
    }

    return self;
}

-(void)buttonTapped:(id)sender{
    
    
    if ( sender == self.leftcheck ){
        NSLog(@"left");
        self.leftcheck.selected = !self.leftcheck.selected;
        self.rightcheck.enabled = !self.leftcheck.selected;
        
        PFObject *photoLeft = [self.objPoll objectForKey:@"PhotoLeft"];

        if ( self.leftcheck.selected ){
            self.leftvotecount++;
            
            [VLMUtility likePhotoInBackground:photoLeft forPoll:self.objPoll isLeft:YES block:^(BOOL succeeded, NSError *error){
                if ( error ){
                    // TBD: roll back to previous state (this means we should keep track of the last known state)
                }
            }];
        } else {
            self.leftvotecount--;

            [VLMUtility unlikePhotoInBackground:photoLeft forPoll:self.objPoll isLeft:YES block:^(BOOL succeeded, NSError *error){
                if ( error ){
                    // TBD: roll back to previous state (this means we should keep track of the last known state)
                }
            }];

        }
        NSLog(@"%d", self.leftvotecount);
        self.votecountlabelLeft.text = [NSString stringWithFormat:@"%d votes", leftvotecount];
        
    } else if ( sender == self.rightcheck ){
        NSLog(@"right");
        self.rightcheck.selected = !self.rightcheck.selected;
        self.leftcheck.enabled = !self.rightcheck.selected;
        
        PFObject *photoRight = [self.objPoll objectForKey:@"PhotoRight"];

        if ( self.rightcheck.selected ){
            self.rightvotecount++;
            
            [VLMUtility likePhotoInBackground:photoRight forPoll:self.objPoll isLeft:NO block:^(BOOL succeeded, NSError *error){
                if ( error ){
                    // TBD: roll back to previous state (this means we should keep track of the last known state)
                }
            }];

        } else {
            self.rightvotecount--;
            [VLMUtility unlikePhotoInBackground:photoRight forPoll:self.objPoll isLeft:NO block:^(BOOL succeeded, NSError *error){
                if ( error ){
                    // TBD: roll back to previous state (this means we should keep track of the last known state)
                }
            }];
            
        }
        self.votecountlabelRight.text = [NSString stringWithFormat:@"%d votes", rightvotecount];
        NSLog(@"%d", self.rightvotecount);
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
    //NSLog(@"%f", val);
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

- (void)setPoll:(PFObject *)poll{
    self.objPoll = poll;
    PFObject *photoLeft = [poll objectForKey:@"PhotoLeft"];
    PFObject *photoRight = [poll objectForKey:@"PhotoRight"];
    
    PFFile *left = [photoLeft objectForKey:@"Original"];
    PFFile *right = [photoRight objectForKey:@"Original"];
    
    NSString *leftcaption = [photoLeft objectForKey:@"Caption"];
    NSString *rightcaption = [photoRight objectForKey:@"Caption"];
    [self setLeftFile:left andRightFile:right];
    [self setLeftCaptionText:leftcaption andRightCaptionText:rightcaption];
    
}

- (void)enableButtons{
    if ( self.personalvotecountleft > -1 && self.personalvotecountright > -1 ){
        if ( self.personalvotecountleft > 0 ){
            
            self.leftcheck.enabled = YES;
            self.leftcheck.selected = YES;
            self.rightcheck.enabled = NO;
            self.rightcheck.selected = NO;

        } else if ( self.personalvotecountright > 0 ){

            self.leftcheck.enabled = NO;
            self.leftcheck.selected = NO;
            self.rightcheck.enabled = YES;
            self.rightcheck.selected = YES;
            [self setInitialPage:NO];
            
        } else {
            
            self.leftcheck.enabled = YES;
            self.leftcheck.selected = NO;
            self.rightcheck.enabled = YES;
            self.rightcheck.selected = NO;
            
        }
    }

}

- (void)setLeftFile: (PFFile *)left andRightFile: (PFFile *)right{
    if ( !left || !right ) return;
    
    self.imageviewLeft.image = [UIImage imageNamed:@"clear.png"];
    self.imageviewLeft.file = left;
    [self.imageviewLeft loadInBackground];

    self.imageviewRight.image = [UIImage imageNamed:@"clear.png"];
    self.imageviewRight.file = right;
    [self.imageviewRight loadInBackground];
}

- (void)setLeftCaptionText: (NSString *)left andRightCaptionText: (NSString *)right{
    [self.captionlabelLeft setNumberOfLines:0];
    [self.captionlabelLeft setText:left];
    [self.captionlabelLeft sizeToFit];
    [self.captionlabelLeft setFrame:CGRectMake(15, 286/2 - (self.captionlabelLeft.frame.size.height + 28 )/2, 286-30, self.captionlabelLeft.frame.size.height)];
    [self.votecountlabelLeft setFrame:CGRectMake(15, self.captionlabelLeft.frame.origin.y + self.captionlabelLeft.frame.size.height+7, 286-30, 28)];
    [self.votecountlabelLeft setText:@"..."];

    [self.captionLabelRight setNumberOfLines:0];
    [self.captionLabelRight setText:right];
    [self.captionLabelRight sizeToFit];
    [self.captionLabelRight setFrame:CGRectMake(15, 286/2 - (self.captionLabelRight.frame.size.height + 28 )/2, 286-30, self.captionLabelRight.frame.size.height)];
    [self.votecountlabelRight setFrame:CGRectMake(15, self.captionLabelRight.frame.origin.y + self.captionLabelRight.frame.size.height+7, 286-30, 28)];
    [self.votecountlabelRight setText:@"..."];
}

- (void)setLeftCount:(NSInteger)left andRightCount:(NSInteger)right{
    self.leftvotecount = left;
    self.votecountlabelLeft.text = [NSString stringWithFormat: @"%d votes", left];
    self.rightvotecount = right;
    self.votecountlabelRight.text = [NSString stringWithFormat: @"%d votes", right];
}

- (void)setPersonalLeftCount:(NSInteger)left andPersonalRightCount:(NSInteger)right{
    self.personalvotecountleft = left;
    self.personalvotecountright = right;
    [self enableButtons];
}

- (void)setInitialPage:(BOOL)leftside{
    if ( leftside ){
        self.originalOffsetX = 0;
    } else {
        self.originalOffsetX = -290;
    }
    self.containerView.frame = CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
    self.containerView.frame = CGRectOffset(self.containerView.frame, self.originalOffsetX, 0);
    [self setNeedsLayout];
}

@end
