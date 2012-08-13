//
//  VLMSectionView.m
//  ThisVersusThat
//
//  Created by David Lu on 7/17/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "VLMSectionView.h"
#import "VLMConstants.h"
#import "Parse/Parse.h"
#import "VLMFeedHeaderDelegate.h"

@implementation VLMSectionView

@synthesize profileImageView;
@synthesize headerLabel;
@synthesize detailLabel;
@synthesize clearbutton;
@synthesize clearbutton2;
@synthesize clearbutton3;
@synthesize delegate;
@synthesize section;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    return self;
}

-(id) initWithFrame:(CGRect)frame andUserName:(NSString *)username andQuestion:(NSString *)text
{
    self = [super initWithFrame:frame];
    if ( self ){
        [self setAutoresizesSubviews:NO];

        // avatar
        self.profileImageView = [[PFImageView alloc] initWithFrame:CGRectMake(7.0f, 13.0f, 27.0f, 27.0f)];
        [self.profileImageView setBackgroundColor:[UIColor lightGrayColor]];

        // create the label objects
        self.headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [headerLabel setBackgroundColor:[UIColor clearColor]];
        [headerLabel setFont:[UIFont fontWithName:SECTION_FONT_BOLD size:14.0f]];
        [headerLabel setFrame:CGRectMake( 44.0f-3, 7.0f, 250.f, 22.0f )];
        [headerLabel setText:username];
        [headerLabel setTextColor:TEXT_COLOR];
        
        self.detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [detailLabel setLineBreakMode:UILineBreakModeWordWrap];
        [detailLabel setMinimumFontSize:10.0f];
        [detailLabel setNumberOfLines:0];
        [detailLabel setFont:[UIFont fontWithName:SECTION_FONT_REGULAR size:14.0f]];
        [detailLabel setBackgroundColor:[UIColor clearColor]];
        [detailLabel setTextColor:TEXT_COLOR];
        [detailLabel setText:text];
        [detailLabel setFrame:CGRectMake( 44.0f-3, 27.0f, 270.f, 0.0f )];
        
        // new size for label
        CGSize maximumLabelSize = CGSizeMake(275,100);
        CGSize expectedLabelSize = [text sizeWithFont:detailLabel.font constrainedToSize:maximumLabelSize lineBreakMode:detailLabel.lineBreakMode];   
        CGRect newFrame = detailLabel.frame;
        newFrame.size.height = expectedLabelSize.height;
        [detailLabel setFrame:newFrame];

        // new size for view
        frame.size.height = newFrame.size.height + newFrame.origin.y + 5;

        [self setFrame:frame];
        [self setBackgroundColor:FEED_SECTION_HEADER_BGCOLOR];
        [self setAutoresizesSubviews:NO];
        [self addSubview:self.profileImageView];
        [self addSubview:headerLabel];
        [self addSubview:detailLabel];
        
        self.clearbutton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, frame.size.height)];
        [clearbutton setBackgroundColor:[UIColor clearColor]];
        [clearbutton addTarget:self action:@selector(handleTapUser:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clearbutton];

        self.clearbutton2 = [[UIButton alloc] initWithFrame:CGRectMake(50, 0, frame.size.width-50, frame.size.height)];
        [clearbutton2 setBackgroundColor:[UIColor clearColor]];
        [clearbutton2 addTarget:self action:@selector(handleTapPoll:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clearbutton2];

        
        /*
        self.clearbutton = [[UIButton alloc] initWithFrame:self.profileImageView.frame];
        [clearbutton setBackgroundColor:[UIColor clearColor]];
        [clearbutton addTarget:self action:@selector(handleTap:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clearbutton];

        
        [headerLabel sizeToFit];
        [headerLabel setFrame:CGRectMake( 44.0f-3, 7.0f, headerLabel.frame.size.width, 22.0f )];

        self.clearbutton2 = [[UIButton alloc] initWithFrame:headerLabel.frame];
        [clearbutton2 setBackgroundColor:[UIColor clearColor]];
        [clearbutton2 addTarget:self action:@selector(handleTap:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clearbutton2];
        
        [detailLabel sizeToFit];
        [detailLabel setFrame:CGRectMake( 44.0f-3, 27.0f, detailLabel.frame.size.width, detailLabel.frame.size.height )];

        self.clearbutton3 = [[UIButton alloc] initWithFrame:detailLabel.frame];
        [clearbutton3 setBackgroundColor:[UIColor clearColor]];
        [clearbutton3 addTarget:self action:@selector(handleTap2:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clearbutton3];
         */
    }
    return self;
}

- (void)setUserName:(NSString *)username andQuestion:(NSString *)text{
    
    // create the label objects
    [self.headerLabel setFrame:CGRectZero];
    [headerLabel setBackgroundColor:[UIColor clearColor]];
    [headerLabel setFont:[UIFont fontWithName:SECTION_FONT_BOLD size:14.0f]];
    [headerLabel setFrame:CGRectMake( 44.0f-3, 7.0f, 250.f, 22.0f )];
    [headerLabel setText:username];
    [headerLabel setTextColor:TEXT_COLOR];
    
    [self.detailLabel setFrame:CGRectZero];
    [detailLabel setLineBreakMode:UILineBreakModeWordWrap];
    [detailLabel setMinimumFontSize:10.0f];
    [detailLabel setNumberOfLines:0];
    [detailLabel setFont:[UIFont fontWithName:SECTION_FONT_REGULAR size:14.0f]];
    [detailLabel setBackgroundColor:[UIColor clearColor]];
    [detailLabel setTextColor:TEXT_COLOR];
    [detailLabel setText:text];
    [detailLabel setFrame:CGRectMake( 44.0f-3, 27.0f, 270.f, 0.0f )];
    
    // new size for label
    CGSize maximumLabelSize = CGSizeMake(275,100);
    CGSize expectedLabelSize = [text sizeWithFont:detailLabel.font constrainedToSize:maximumLabelSize lineBreakMode:detailLabel.lineBreakMode];   
    CGRect newFrame = detailLabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    [detailLabel setFrame:newFrame];
    
    // new size for view
    CGRect f = self.frame;
    f.size.height = newFrame.size.height + newFrame.origin.y + 5;
    
    [self setFrame:f];
    
    [headerLabel sizeToFit];
    [headerLabel setFrame:CGRectMake( 44.0f-3, 7.0f, headerLabel.frame.size.width, 22.0f )];
    
    [detailLabel sizeToFit];
    [detailLabel setFrame:CGRectMake( 44.0f-3, 27.0f, detailLabel.frame.size.width, detailLabel.frame.size.height )];
    
    //[clearbutton3 setFrame:detailLabel.frame];
    
    //[clearbutton setFrame:CGRectMake(0, 0, f.size.width/2, f.size.height)];
    //[clearbutton2 setFrame:CGRectMake(f.size.width/2, 0, f.size.width/2, f.size.height)];
    
}

- (void)setFile:(PFFile *)file {
    if (!file) {
        return;
    }
    
    self.profileImageView.image = [UIImage imageNamed:@"clearbutton.png"];
    self.profileImageView.file = file;
    [self.profileImageView loadInBackground];
    
}

-(void)handleTapUser:(id)sender{
    if ( ![PFUser currentUser] ) return;
    if ( !self.delegate ) return;
    [delegate didTapUser:self.section];
}

-(void)handleTapPoll:(id)sender{
    if ( ![PFUser currentUser] ) return;
    if ( !self.delegate ) return;
    [delegate didTapPoll:self.section];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
