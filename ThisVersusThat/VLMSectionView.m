//
//  VLMSectionView.m
//  ThisVersusThat
//
//  Created by David Lu on 7/17/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "VLMSectionView.h"
#import "VLMConstants.h"

@implementation VLMSectionView

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
        UIView *avatarplaceholder = [[UIView alloc] initWithFrame:CGRectMake(7.0f, 13.0f, 27.0f, 27.0f)];
        [avatarplaceholder setBackgroundColor:[UIColor lightGrayColor]];

        // create the label objects
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [headerLabel setBackgroundColor:[UIColor clearColor]];
        [headerLabel setFont:[UIFont fontWithName:SECTION_FONT_BOLD size:14.0f]];
        [headerLabel setFrame:CGRectMake( 44.0f-3, 7.0f, 250.f, 22.0f )];
        [headerLabel setText:username];
        [headerLabel setTextColor:TEXT_COLOR];
        
        UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
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
        //[self setBackgroundColor:DEBUG_BACKGROUND_GRID];
        [self setAutoresizesSubviews:NO];
        [self addSubview:avatarplaceholder];
        [self addSubview:headerLabel];
        [self addSubview:detailLabel];
    }
    return self;
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
