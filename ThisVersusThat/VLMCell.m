//
//  VLMCellCell.m
//  ThisVersusThat
//
//  Created by David Lu on 7/18/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "VLMCell.h"
#import "VLMCache.h"
#import "VLMConstants.h"
#import <QuartzCore/QuartzCore.h>
#import "Parse/Parse.h"
#import "VLMUtility.h"
#import "VLMFeedTableViewController.h"
#import "AppDelegate.h"

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
@synthesize leftcheck;
@synthesize rightcheck;

@synthesize leftvotecount;
@synthesize rightvotecount;
@synthesize personalvotecountleft;
@synthesize personalvotecountright;
@synthesize outstandingQueries;
@synthesize tv;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setAutoresizesSubviews:NO];

        // Initialization code
        self.originalOffsetX = 0.0f;
        self.backgroundColor = [UIColor clearColor];
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 592.0f, 301.0f)];
        self.containerView.clipsToBounds = YES;
        self.velocity = 0;
        self.leftvotecount = 0;
        self.rightvotecount = 0;
        self.outstandingQueries = [NSMutableDictionary dictionary];        
        
        UIView *left = [[UIView alloc] initWithFrame:CGRectMake(20-5, 14, 286, 286)];
        left.backgroundColor = [UIColor colorWithWhite:1 alpha:1.0];
        [self.containerView addSubview:left];
        
        PFImageView *leftimage = [[PFImageView alloc] initWithFrame:CGRectMake(5, 5, 276, 276)];
        [leftimage setBackgroundColor:[UIColor lightGrayColor]];
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
        [rightimage setBackgroundColor:[UIColor lightGrayColor]];
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
        
        
        self.leftcheck = [[UIButton alloc] initWithFrame:CGRectMake(286/2-59/2, 286-65-14, 59, 59)];;
        [leftcheck setShowsTouchWhenHighlighted:YES];
        [leftcheck setImage:[UIImage imageNamed:@"vote_button_selected.png"] forState:UIControlStateSelected];
        [leftcheck setImage:[UIImage imageNamed:@"vote_button_normal.png"] forState:UIControlStateNormal];
        [leftcheck setImage:[UIImage imageNamed:@"vote_button_disabled"] forState:UIControlStateDisabled];
        [leftcheck addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [leftcheck setEnabled:NO];
        [left addSubview:leftcheck];

        self.rightcheck = [[UIButton alloc] initWithFrame:CGRectMake(286/2-59/2, 286-65-14, 59, 59)];;
        [rightcheck setShowsTouchWhenHighlighted:YES];
        [rightcheck setImage:[UIImage imageNamed:@"vote_button_selected.png"] forState:UIControlStateSelected];
        [rightcheck setImage:[UIImage imageNamed:@"vote_button_normal.png"] forState:UIControlStateNormal];
        [rightcheck setImage:[UIImage imageNamed:@"vote_button_disabled"] forState:UIControlStateDisabled];
        [rightcheck addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [rightcheck setEnabled:NO];
        [right addSubview:rightcheck];
        
        self.originalRect = self.containerView.frame;
        [self.contentView addSubview:self.containerView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.userInteractionEnabled = YES;
        
        self.personalvotecountleft = -1;
        self.personalvotecountright = -1;
        
        /*
        UIImageView *commentballoon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"balloon@2x.png"]];
        [commentballoon setFrame:CGRectMake(25+1, 25, 9.5, 10.5)];
        [self.contentView addSubview:commentballoon];
         */
    }

    return self;
}
- (void)rollback{
    NSNumber *ll = [[VLMCache sharedCache] likeCountForPollLeft:self.objPoll];
    NSNumber *rr = [[VLMCache sharedCache] likeCountForPollRight:self.objPoll];
    BOOL llv = [[VLMCache sharedCache] isPollLikedByCurrentUserLeft:self.objPoll];
    BOOL rrv = [[VLMCache sharedCache] isPollLikedByCurrentUserRight:self.objPoll];
    int newpersonalcountleft = (llv) ? 1:0;
    int newpersonalcountright = (rrv) ? 1:0;
    [self setLeftCount:[ll intValue] andRightCount:[rr intValue]];
    [self setPersonalLeftCount:newpersonalcountleft andPersonalRightCount:newpersonalcountright];

}
-(void)buttonTapped:(id)sender{
    
    if ( ![PFUser currentUser] ) return;
    AppDelegate *del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    BOOL isParseReachable = [del isParseReachable];

    if ( sender == self.leftcheck ){
        NSLog(@"left");
        self.leftcheck.selected = !self.leftcheck.selected;
        self.rightcheck.enabled = !self.leftcheck.selected;
        
        PFObject *photoLeft = [self.objPoll objectForKey:@"PhotoLeft"];

        if ( self.leftcheck.selected ){
            self.leftvotecount++;
            if ( isParseReachable ){
                
                [VLMUtility likePhotoInBackground:photoLeft forPoll:self.objPoll isLeft:YES block:^(BOOL succeeded, NSError *error){
                    if ( error ){
                        NSLog(@"error. attempting to roll back");
                        // TBD: roll back to previous state (this means we should keep track of the last known state)
                        [self rollback];
                    }
                }];
            }
        } else {
            self.leftvotecount--;
            if ( isParseReachable ){

                [VLMUtility unlikePhotoInBackground:photoLeft forPoll:self.objPoll isLeft:YES block:^(BOOL succeeded, NSError *error){
                    if ( error ){
                        NSLog(@"error. attempting to roll back");
                        // TBD: roll back to previous state (this means we should keep track of the last known state)
                        [self rollback];
                    }
                }];
                
            }

        }
        self.votecountlabelLeft.text = [NSString stringWithFormat: @"%d vote%@", leftvotecount, leftvotecount != 1 ? @"s" : @""];
        
    } else if ( sender == self.rightcheck ){
        NSLog(@"right");
        self.rightcheck.selected = !self.rightcheck.selected;
        self.leftcheck.enabled = !self.rightcheck.selected;
        
        PFObject *photoRight = [self.objPoll objectForKey:@"PhotoRight"];

        if ( self.rightcheck.selected ){
            self.rightvotecount++;
            
            if ( isParseReachable ){
                [VLMUtility likePhotoInBackground:photoRight forPoll:self.objPoll isLeft:NO block:^(BOOL succeeded, NSError *error){
                    if ( error ){
                        // TBD: roll back to previous state (this means we should keep track of the last known state)
                        [self rollback];
                    }
                }];
            }

        } else {
            self.rightvotecount--;
            if ( isParseReachable ){
                [VLMUtility unlikePhotoInBackground:photoRight forPoll:self.objPoll isLeft:NO block:^(BOOL succeeded, NSError *error){
                    if ( error ){
                        // TBD: roll back to previous state (this means we should keep track of the last known state)
                        [self rollback];
                    }
                }];

            }
        }
        self.votecountlabelRight.text = [NSString stringWithFormat: @"%d vote%@", rightvotecount, rightvotecount != 1 ? @"s" : @""];

        NSLog(@"%d", self.rightvotecount);
    }
    

    if ( !isParseReachable ){
        [self performSelector:@selector(rollback) withObject:self afterDelay:1.0f];
    }
    
}

-(void)translateByX: (CGFloat) offsetval withVelocity:(CGFloat)velocityval{
    self.contentView.clipsToBounds = NO;

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

-(void)resetAnimated:(BOOL)anim{


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
    
    if ( self.tv && self.objPoll ){
        if ( self.originalOffsetX == 0 ){
            [self.tv setDirection:YES ForPoll:self.objPoll];
        }
        else {
            [self.tv setDirection:NO ForPoll:self.objPoll];
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
                self.contentView.clipsToBounds = YES;

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
    
    self.leftvotecount = 0;
    self.rightvotecount = 0;
    self.votecountlabelLeft.text = @"...";
    self.votecountlabelRight.text = @"...";
    self.leftcheck.enabled = NO;
    self.rightcheck.enabled = NO;

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
            
        } else {
            
            self.leftcheck.enabled = YES;
            self.leftcheck.selected = NO;
            self.rightcheck.enabled = YES;
            self.rightcheck.selected = NO;
            
        }
    }
    else {
        
        self.leftcheck.enabled = NO;
        self.leftcheck.selected = NO;
        self.rightcheck.enabled = NO;
        self.rightcheck.selected = NO;
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
    self.votecountlabelLeft.text = [NSString stringWithFormat: @"%d vote%@", left, left != 1 ? @"s" : @""];
    self.rightvotecount = right;
    self.votecountlabelRight.text = [NSString stringWithFormat: @"%d vote%@", right, right != 1 ? @"s" : @""];
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
    self.contentView.clipsToBounds = YES;
    //[self setNeedsLayout];
}

- (void)resetCell{
    [self.votecountlabelLeft setText:@"..."];
    [self.votecountlabelRight setText:@"..."];
    [self setLeftCaptionText:@"" andRightCaptionText:@""];
    [self setLeftCount:-1 andRightCount:-1];
    [self setPersonalLeftCount:-1 andPersonalRightCount:-1];
    [self setInitialPage:YES];
}

- (void)setContentVisible:(BOOL)isVisible{
    //self.imageviewLeft.hidden = !isVisible;
    //self.imageviewRight.hidden = !isVisible;
    //self.captionlabelLeft.hidden = !isVisible;
    //self.captionLabelRight.hidden = !isVisible;
    self.votecountlabelLeft.hidden = !isVisible;
    self.votecountlabelRight.hidden = !isVisible;
    self.leftcheck.hidden = !isVisible;
    self.rightcheck.hidden = !isVisible;
    if ( isVisible ) [self setNeedsDisplay];
}


@end
