//
//  VLMSectionView.m
//  ThisVersusThat
//
//  Created by David Lu on 7/17/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "VLMSectionView.h"
#import "TTTTimeIntervalFormatter.h"
#import "VLMConstants.h"
#import "Parse/Parse.h"
#import "VLMFeedHeaderDelegate.h"

static TTTTimeIntervalFormatter *timeFormatter;

@implementation VLMSectionView

@synthesize profileImageView;
@synthesize headerLabel;
@synthesize detailLabel;
@synthesize clearbutton;
@synthesize clearbutton2;
@synthesize clearbutton3;
@synthesize delegate;
@synthesize section;
@synthesize timestamp;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!timeFormatter) {
        timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
    }

    return self;
}

-(id) initWithFrame:(CGRect)frame andUserName:(NSString *)username andQuestion:(NSString *)text
{
    self = [super initWithFrame:frame];
    if ( self ){
        if (!timeFormatter) {
            timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
            timeFormatter.usesAbbreviatedCalendarUnits = YES;
        }
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

        self.timestamp = [[UILabel alloc] initWithFrame:CGRectMake(self.headerLabel.frame.origin.x, self.headerLabel.frame.origin.y, frame.size.width-headerLabel.frame.origin.x-10, headerLabel.frame.size.height)];
        [timestamp setTextAlignment:UITextAlignmentRight];
        [timestamp setBackgroundColor:[UIColor clearColor]];
        [timestamp setFont:[UIFont fontWithName:@"AmericanTypewriter" size:12.0f]];
        [timestamp setTextColor:[UIColor colorWithWhite:0.2 alpha:0.5]];

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
        [self addSubview:timestamp];
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
    
    [clearbutton setFrame:CGRectMake(0, 0, 50, f.size.height)];
    [clearbutton2 setFrame:CGRectMake(50, 0, f.size.width-50, f.size.height)];
    
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

-(void)setTime:(NSDate*)d{
    NSString *f = [timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:d];
    f = [f stringByReplacingOccurrencesOfString:@" years ago" withString:@"y"];
    f = [f stringByReplacingOccurrencesOfString:@" year ago" withString:@"y"];
    f = [f stringByReplacingOccurrencesOfString:@" months ago" withString:@"mo"];
    f = [f stringByReplacingOccurrencesOfString:@" month ago" withString:@"mo"];
    f = [f stringByReplacingOccurrencesOfString:@" days ago" withString:@"d"];
    f = [f stringByReplacingOccurrencesOfString:@" day ago" withString:@"d"];
    f = [f stringByReplacingOccurrencesOfString:@" hours ago" withString:@"h"];
    f = [f stringByReplacingOccurrencesOfString:@" hour ago" withString:@"h"];
    f = [f stringByReplacingOccurrencesOfString:@" minutes ago" withString:@"m"];
    f = [f stringByReplacingOccurrencesOfString:@" minute ago" withString:@"m"];
    f = [f stringByReplacingOccurrencesOfString:@" seconds ago" withString:@"s"];
    f = [f stringByReplacingOccurrencesOfString:@" second ago" withString:@"s"];
    [timestamp setText:f];
//    [timestamp setText:];
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
