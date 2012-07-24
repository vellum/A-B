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
        UIView *avatarplaceholder = [[UIView alloc] initWithFrame:CGRectMake(5.0f+1, 7.0f+2, 30.0f, 30.0f)];
        [avatarplaceholder setBackgroundColor:[UIColor lightGrayColor]];

        // create the label objects
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.font = [UIFont fontWithName:SECTION_FONT_BOLD size:14.0f];
        headerLabel.frame = CGRectMake( 44.0f, 5.0f, 250.f, 22.0f );
        headerLabel.text =  username;
        headerLabel.textColor = TEXT_COLOR;
        
        UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        detailLabel.lineBreakMode = UILineBreakModeWordWrap;
        detailLabel.minimumFontSize = 10.0f;
        detailLabel.numberOfLines = 0;
        detailLabel.font = [UIFont fontWithName:SECTION_FONT_REGULAR size:14.0f];
        //detailLabel.font = [UIFont fontWithName:TYPEWRITER size:14.0f];
        
        detailLabel.backgroundColor = [UIColor clearColor];
        detailLabel.textColor = TEXT_COLOR;
        
        detailLabel.text = text;
        detailLabel.frame = CGRectMake( 44.0f, 25.0f, 270.f, 0.0f );
        
        //Calculate the expected size based on the font and linebreak mode of your label
        CGSize maximumLabelSize = CGSizeMake(275,100);
        CGSize expectedLabelSize = [text sizeWithFont:detailLabel.font constrainedToSize:maximumLabelSize lineBreakMode:detailLabel.lineBreakMode];   
        
        //adjust the label the the new height.
        CGRect newFrame = detailLabel.frame;
        newFrame.size.height = expectedLabelSize.height;
        detailLabel.frame = newFrame;
        frame.size.height = newFrame.size.height + newFrame.origin.y + 5;
        self.frame = frame;

        /*
        UIView *border = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, BORDER_WIDTH)];
        border.backgroundColor = [UIColor colorWithHue:313/360 saturation:12/100 brightness:59/100 alpha:0.2];
        [self addSubview:border];
         */
        [self setBackgroundColor:[UIColor whiteColor]];
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
