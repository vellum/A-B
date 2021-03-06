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
#import "VLMPopModalDelegate.h"

@interface VLMCell()
@property (nonatomic, strong) UIView *commentholder;
@property (nonatomic, strong) UILabel *commentcountlabel;
@property (nonatomic, strong) UIButton *commentbutton;
@property (nonatomic, strong) UILabel *deletionfound;
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
@synthesize tv;

@synthesize commentholder;
@synthesize commentcountlabel;
@synthesize commentbutton;
@synthesize delegate;

@synthesize deletionfound;

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

        self.commentholder = [[UIView alloc] initWithFrame:CGRectMake(15, 286+15+7, 55.0f, 28.0f)];
        //[commentholder setBackgroundColor:[UIColor colorWithRed:139.0f/255.0f green:197.0f/255.0f blue:62.0f/255.0f alpha:1.0f]];
        [commentholder setBackgroundColor:[UIColor colorWithRed:51.0f/255.0f green:153.0f/255.0f blue:0.0f alpha:1.0f]];
        //[commentholder.layer setCornerRadius:2.0f];
        [self.contentView addSubview:commentholder];
        
        UIImageView *commentballoon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"balloon@2x.png"]];
        [commentballoon setFrame:CGRectMake(10, commentholder.frame.size.height/2.0f - 5, 10, 11)];
        [commentholder addSubview:commentballoon];
        
        [commentholder.layer setCornerRadius:3.0f];

        self.commentcountlabel = [[UILabel alloc] initWithFrame:CGRectMake(23, 0, 55-19, 28)];
        [self.commentcountlabel setFont:[UIFont fontWithName:PHOTO_LABEL size:13.0f]];
        [self.commentcountlabel setTextColor:[UIColor whiteColor]];
        [self.commentcountlabel setBackgroundColor:[UIColor clearColor]];
        [self.commentcountlabel setText:@"0"];
        [commentholder addSubview:commentcountlabel];
        
        self.commentbutton = [[UIButton alloc] initWithFrame:commentholder.frame];
        [commentbutton.layer setCornerRadius:2.0f];
        [commentbutton.layer setMasksToBounds:YES];
        [self.commentbutton setBackgroundImage:[UIImage imageNamed:@"clear.png"] forState:UIControlStateNormal];
        [self.commentbutton setBackgroundImage:[UIImage imageNamed:@"clear50.png"] forState:UIControlStateHighlighted];
        [self.contentView addSubview:commentbutton];
        
        [self.commentbutton addTarget:self action:@selector(commentbuttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *gah = [[UILabel alloc] initWithFrame:CGRectMake(15, 14, 286, 42)];
        [gah setFont:[UIFont fontWithName:PHOTO_LABEL size:13.0f]];
        [gah setTextAlignment:UITextAlignmentCenter];
        [gah setBackgroundColor:[UIColor yellowColor]];
        [gah setTextColor:TEXT_COLOR];
        [gah setText:@"This item was deleted by its user."];
        [gah setUserInteractionEnabled:NO];
        [gah setHidden:YES];
        [self.contentView addSubview:gah];
        self.deletionfound = gah;
        


    }

    return self;
}
- (void)rollback{
    if (!self.objPoll)return;
    NSNumber *ll = [[VLMCache sharedCache] likeCountForPollLeft:self.objPoll];
    NSNumber *rr = [[VLMCache sharedCache] likeCountForPollRight:self.objPoll];
    BOOL llv = [[VLMCache sharedCache] isPollLikedByCurrentUserLeft:self.objPoll];
    BOOL rrv = [[VLMCache sharedCache] isPollLikedByCurrentUserRight:self.objPoll];
    int newpersonalcountleft = (llv) ? 1:0;
    int newpersonalcountright = (rrv) ? 1:0;
    [self setLeftCount:[ll intValue] andRightCount:[rr intValue]];
    [self setPersonalLeftCount:newpersonalcountleft andPersonalRightCount:newpersonalcountright];
    [self updatecommentfield];

}
-(void)buttonTapped:(id)sender{
    
    if ( ![PFUser currentUser] ) return;
    if (!self.objPoll)return;

    AppDelegate *del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    BOOL isParseReachable = [del isParseReachable];

    if ( sender == self.leftcheck ){
        //NSLog(@"left");
        self.leftcheck.selected = !self.leftcheck.selected;
        self.rightcheck.enabled = !self.leftcheck.selected;
        
        PFObject *photoLeft = [self.objPoll objectForKey:@"PhotoLeft"];

        if ( self.leftcheck.selected ){
            self.leftvotecount++;
            if ( isParseReachable ){
                
                [VLMUtility likePhotoInBackground:photoLeft forPoll:self.objPoll isLeft:YES block:^(BOOL succeeded, NSError *error){
                    if ( error ){
                        if ( [[error domain] isEqualToString:@"cc.vellum"] )
                        {
                            [self setPollDeleted];
                        }
                        //NSLog(@"error. attempting to roll back");
                        // TBD: roll back to previous state (this means we should keep track of the last known state)
                        [self rollback];
                    } else {
                        [self updatecommentfield];
                    }
                }];
            }
        } else {
            self.leftvotecount--;
            if ( isParseReachable ){

                [VLMUtility unlikePhotoInBackground:photoLeft forPoll:self.objPoll isLeft:YES block:^(BOOL succeeded, NSError *error){
                    if ( error ){
                        if ( [[error domain] isEqualToString:@"cc.vellum"] )
                        {
                            [self setPollDeleted];
                        }
                        //NSLog(@"error. attempting to roll back");
                        // TBD: roll back to previous state (this means we should keep track of the last known state)
                        [self rollback];
                    } else {
                        [self updatecommentfield];
                    }
                }];
                
            }

        }
        self.votecountlabelLeft.text = [NSString stringWithFormat: @"%d vote%@", leftvotecount, leftvotecount != 1 ? @"s" : @""];
        
    } else if ( sender == self.rightcheck ){
        //NSLog(@"right");
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
                    } else {
                        [self updatecommentfield];
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
                    } else {
                        [self updatecommentfield];
                    }
                }];

            }
        }
        self.votecountlabelRight.text = [NSString stringWithFormat: @"%d vote%@", rightvotecount, rightvotecount != 1 ? @"s" : @""];

        //NSLog(@"%d", self.rightvotecount);
    }
    

    if ( !isParseReachable ){
        [self performSelector:@selector(rollback) withObject:self afterDelay:1.0f];
    }
    
    
    [self updatecommentfield];
}

- (void)updatecommentfield{
    if (!self.objPoll) return;
    int commentcount = [[[VLMCache sharedCache] commentCountForPoll:self.objPoll] intValue];
    BOOL isvoted = [[VLMCache sharedCache] isPollCommentedByCurrentUser:self.objPoll];
    
    [self setCommentCount:commentcount commentedByCurrentUser:isvoted];
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
    ////NSLog(@"%f", val);
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
    
    NSString *uppercaseLeft = [left uppercaseString];
    NSString *processedLeft = ([left isEqualToString:uppercaseLeft]) ? left : [left capitalizedString];

    NSString *uppercaseRight = [right uppercaseString];
    NSString *processedRight = ([right isEqualToString:uppercaseRight]) ? right : [right capitalizedString];
    
    
    [self.captionlabelLeft setNumberOfLines:0];
    [self.captionlabelLeft setText:processedLeft];
    [self.captionlabelLeft sizeToFit];
    [self.captionlabelLeft setFrame:CGRectMake(15, 286/2 - (self.captionlabelLeft.frame.size.height + 28 )/2+14, 286-30, self.captionlabelLeft.frame.size.height)];
    [self.votecountlabelLeft setFrame:CGRectMake(15, self.captionlabelLeft.frame.origin.y + self.captionlabelLeft.frame.size.height+7, 286-30, 28)];
    [self.votecountlabelLeft setText:@"..."];

    [self.captionLabelRight setNumberOfLines:0];
    [self.captionLabelRight setText:processedRight];
    [self.captionLabelRight sizeToFit];
    [self.captionLabelRight setFrame:CGRectMake(15, 286/2 - (self.captionLabelRight.frame.size.height + 28 )/2+14, 286-30, self.captionLabelRight.frame.size.height)];
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
    [self.deletionfound setHidden: YES];
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
    
    //self.votecountlabelLeft.hidden = !isVisible;
    //self.votecountlabelRight.hidden = !isVisible;
    
    self.leftcheck.hidden = !isVisible;
    self.rightcheck.hidden = !isVisible;
    self.commentholder.hidden = !isVisible;
    if ( isVisible ) [self setNeedsDisplay];
}
- (NSString *)pollID{
    if ( !self.objPoll ) return nil;
    return [objPoll objectId];
}

- (void)setCommentCount:(int)val commentedByCurrentUser:(BOOL)isCommentedByCurrentUser{
    
    //NSLog(@"setcommentcount: %d, %d", val, isCommentedByCurrentUser?1:0);
    
    CGRect f = self.commentcountlabel.frame;
    NSString *s;
    if ( self.leftcheck.selected || self.rightcheck.selected ){
        if ( isCommentedByCurrentUser ){
            s = [NSString stringWithFormat:@"%d  \u2192",val];
            [commentholder setBackgroundColor:[UIColor colorWithWhite:0.85f alpha:1.0f]];
        } else {
            s = [NSString stringWithFormat:@"%d    Care to say why?  \u2192",val];
            [commentholder setBackgroundColor:[UIColor colorWithRed:51.0f/255.0f green:153.0f/255.0f blue:0.0f alpha:1.0f]];
            //[commentholder setBackgroundColor:[UIColor colorWithRed:139.0f/255.0f green:197.0f/255.0f blue:62.0f/255.0f alpha:1.0f]];

        }
        
    } else {
        s = [NSString stringWithFormat:@"%d  \u2192",val];
        [commentholder setBackgroundColor:[UIColor colorWithWhite:0.85f alpha:1.0f]];
    }
        
    [self.commentcountlabel setNumberOfLines:0];
    [self.commentcountlabel setFrame:CGRectZero];
    [self.commentcountlabel setText:s];
    [self.commentcountlabel sizeToFit];
    [self.commentcountlabel setFrame:CGRectMake(f.origin.x, f.origin.y, self.commentcountlabel.frame.size.width, f.size.height)];
        
    f = self.commentholder.frame;
    CGFloat measuredwidth = 32 + commentcountlabel.frame.size.width - 5;
    //if ( measuredwidth < 45 ) measuredwidth = 45;
    [self.commentholder setAutoresizesSubviews:NO];
    [self.commentholder setFrame:CGRectMake(15 + 286 - measuredwidth, f.origin.y, measuredwidth, f.size.height)];
    [self.commentbutton setFrame:commentholder.frame];
    //[self.commentbutton setFrame:CGRectMake(commentholder.frame.origin.x-3, commentholder.frame.origin.y-3, commentholder.frame.size.width+6, commentholder.frame.size.height+6)];
}

- (void)commentbuttonTapped:(id)sender {

    if ( ![PFUser currentUser] ) return;
    
    if ( self.delegate && self.objPoll ) {
        [delegate popPollDetailAndScrollToComments:self.objPoll];
    }

}

- (void)setPollDeleted{
    [self.deletionfound setHidden: NO];
    self.leftcheck.enabled = NO;
    self.leftcheck.selected = NO;
    self.rightcheck.enabled = NO;
    self.rightcheck.selected = NO;
    [self setContentVisible:NO];
}
@end
