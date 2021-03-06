//
//  VLMCommentCell.m
//  ThisVersusThat
//
//  Created by David Lu on 8/8/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "VLMCommentCell.h"
#import "VLMConstants.h"
#import "TTTTimeIntervalFormatter.h"

static TTTTimeIntervalFormatter *timeFormatter;
@interface VLMCommentCell ()
@property (nonatomic, strong) UILabel *timestamp;
@end

@implementation VLMCommentCell

@synthesize imageview;
@synthesize userlabel;
@synthesize commentlabel;
@synthesize back;
@synthesize timestamp;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (!timeFormatter) {
        timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
    }
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self setAutoresizesSubviews:NO];
    [self.contentView setAutoresizesSubviews:NO];
    self.contentView.clipsToBounds = YES;
    
    CGFloat x = 20;
    CGFloat y = 0;
    CGFloat w = 40 * 7;
    self.back = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, 1)];
    [back setBackgroundColor:[UIColor clearColor]];
    [back setAutoresizesSubviews:NO];
    
    [self.contentView addSubview:self.back];
    
    self.imageview = [[PFImageView alloc] initWithFrame:CGRectMake(3, 3, 25, 25)];
    self.userlabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 3, w, 14)];
    [userlabel setFont:[UIFont fontWithName:@"AmericanTypewriter-Bold" size:13.0f]];
    [userlabel setBackgroundColor:[UIColor clearColor]];
    [userlabel setTextColor:TEXT_COLOR];
    
    self.commentlabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 18, 237, 100)];
    [commentlabel setFont:[UIFont fontWithName:@"AmericanTypewriter" size:13.0f]];
    [commentlabel setNumberOfLines:0];
    [commentlabel setBackgroundColor:[UIColor clearColor]];
    
    self.timestamp = [[UILabel alloc] initWithFrame:CGRectMake(35, 42, 237, 28)];
    [timestamp setFont:[UIFont fontWithName:@"AmericanTypewriter" size:13.0f]];
    [timestamp setNumberOfLines:0];
    [timestamp setBackgroundColor:[UIColor clearColor]];
    [timestamp setTextColor:[UIColor colorWithWhite:0.2f alpha:0.5f]];
    
    [back addSubview:imageview];
    [back addSubview:userlabel];
    [back addSubview:commentlabel];
    [back addSubview:timestamp];
    
    return self;
}

- (void)setFile:(PFFile *)file{
    [self.imageview setFile:file];
    [self.imageview loadInBackground];
}

- (void)setUser:(NSString *)username{
    [self.userlabel setText:username];
}

- (void)setComment:(NSString *)commenttext{
    [self.commentlabel setFrame:CGRectMake(35, 18, 237, 100)];
    [self.commentlabel setNumberOfLines:0];
    [self.commentlabel setText:commenttext];
    [self.commentlabel sizeToFit];
    
    //CGFloat x = 20;
    //CGFloat y = 0;
    //CGFloat w = 40 * 7;

    //[back setFrame:CGRectMake(x, y, w, commentlabel.frame.size.height + 20)];
}

- (void)setUserColor:(UIColor *)color{
    [self.userlabel setTextColor:color];
}

- (void)setCommentColor:(UIColor *)color{
    [self.commentlabel setTextColor:color];
}

+ (CGFloat)heightForDescriptionText:(NSString *)text{
    CGSize expectedLabelSize = [text sizeWithFont:[UIFont fontWithName:@"AmericanTypewriter" size:13] constrainedToSize:CGSizeMake(40*7-3-20-5-5, 49) lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat cellh = expectedLabelSize.height + 18;
    cellh = ceilf(cellh/7)*7  + 28;
    return cellh;
}

-(void)setTime:(NSDate*)d{
    [timestamp setFrame:CGRectMake(35, self.commentlabel.frame.origin.y + self.commentlabel.frame.size.height + 2, 200, 100)];
    [timestamp setNumberOfLines:0];
    [timestamp setText:[timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:d]];
    [timestamp sizeToFit];
}

@end
