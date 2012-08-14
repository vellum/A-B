//
//  VLMActivityCell.m
//  ThisVersusThat
//
//  Created by David Lu on 8/12/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "VLMActivityCell.h"
#import "VLMConstants.h"
#import "Parse/Parse.h"

@interface VLMActivityCell()
@property (nonatomic, strong) UILabel *quote;
@property (nonatomic, strong) UIView *blockquoteborder;
@property (nonatomic, strong) PFImageView *left;
@property (nonatomic, strong) PFImageView *right;
@property (nonatomic, strong) UIImageView *triangle;
@end

@implementation VLMActivityCell
@synthesize quote;
@synthesize blockquoteborder;
@synthesize left;
@synthesize right;
@synthesize triangle;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self setAutoresizesSubviews:NO];
    [self.contentView setAutoresizesSubviews:NO];
    self.contentView.clipsToBounds = YES;
    
    CGFloat x = 20;
    CGFloat y = 7;
    CGFloat w = 40 * 7;
    self.back = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, 1)];
    [back setBackgroundColor:[UIColor clearColor]];
    [back setAutoresizesSubviews:NO];
    
    [self.contentView addSubview:self.back];
    
    self.imageview = [[PFImageView alloc] initWithFrame:CGRectMake(3, 3, 25, 25)];
    self.userlabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 3, w, 14)];
    [userlabel setFont:[UIFont fontWithName:@"AmericanTypewriter-Bold" size:13.0f]];
    [userlabel setBackgroundColor:[UIColor clearColor]];
    [userlabel setTextColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
    
    self.commentlabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 21, 200, 100)];
    [commentlabel setFont:[UIFont fontWithName:@"AmericanTypewriter" size:13.0f]];
    [commentlabel setNumberOfLines:0];
    [commentlabel setBackgroundColor:[UIColor clearColor]];
    [commentlabel setTextColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];

    self.quote = [[UILabel alloc] initWithFrame:CGRectMake(40, 18-14, 200, 100)];
    [quote setFont:[UIFont fontWithName:@"AmericanTypewriter" size:13.0f]];
    [quote setNumberOfLines:0];
    [quote setBackgroundColor:[UIColor clearColor]];
    [quote setTextColor:[UIColor colorWithWhite:0.5f alpha:1.0f]];
    
    self.blockquoteborder = [[UIView alloc] initWithFrame:CGRectMake(0, 5, 2, 25)];
    [blockquoteborder setBackgroundColor:[UIColor clearColor]];

    self.left = [[PFImageView alloc] initWithFrame:CGRectMake(180, 3, 25, 25)];
    self.right = [[PFImageView alloc] initWithFrame:CGRectMake(215, 3, 25, 25)];

    self.triangle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"triangle.png"]];
    [self.triangle setFrame:CGRectMake(210 + 3, 50, 9, 9)];
    [back addSubview:self.triangle];
    [back addSubview:imageview];
    [back addSubview:left];
    [back addSubview:right];
    [back addSubview:userlabel];
    [back addSubview:commentlabel];
    [back addSubview:quote];
    [back addSubview:blockquoteborder];
    
    [self.contentView setClipsToBounds:YES];
    return self;
}

- (void)setComment:(NSString *)commenttext{
    [self.commentlabel setFrame:CGRectMake(35, 18, 200, 100)];
    [self.commentlabel setNumberOfLines:0];
    [self.commentlabel setText:commenttext];
    [self.commentlabel sizeToFit];
    [blockquoteborder setBackgroundColor:[UIColor clearColor]];
    [self.quote setText:@""];
}

- (void)setComment:(NSString *)commenttext andQuote:(NSString*)quotetext {
    [self.commentlabel setFrame:CGRectMake(35, 18, 200, 100)];
    [self.commentlabel setNumberOfLines:0];
    [self.commentlabel setText:commenttext];
    [self.commentlabel sizeToFit];
    
    [self.quote setFrame:CGRectMake(35+10, 49, 200, 100)];
    [self.quote setNumberOfLines:0];
    [self.quote setText:quotetext];
    [self.quote sizeToFit];
    [blockquoteborder setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.25f]];
    [blockquoteborder setFrame:CGRectMake(35, quote.frame.origin.y, 1.5, quote.frame.size.height)];
}
- (void)clearLeftAndRight{
    [self.left setHidden:YES];
    [self.right setHidden:YES];
    [self.triangle setHidden:YES];
}
- (void)setLeftFile:(PFFile *)file{
    [self.left setImage:[UIImage imageNamed:@"clear.png"]];
    [self.left setBackgroundColor:[UIColor darkGrayColor]];
    [self.left setHidden:NO];
    [self.left setFile:file];
    [self.left loadInBackground];
}
- (void)setRightFile:(PFFile *)file{
    [self.right setImage:[UIImage imageNamed:@"clear.png"]];
    [self.right setBackgroundColor:[UIColor darkGrayColor]];
    [self.right setHidden:NO];
    [self.right setFile:file];
    [self.right loadInBackground];
}
- (void)setTriangleDirection:(BOOL)isLeft{
    [self.triangle setHidden:NO];
    if ( isLeft ){
        [self.triangle setFrame:CGRectMake(180 + 7, 35-4, 9, 9)];

    } else {
        [self.triangle setFrame:CGRectMake(215 + 7, 35-4, 9, 9)];

    }
}

+ (CGFloat)heightForDescriptionText:(NSString *)text{
    CGSize expectedLabelSize = [text sizeWithFont:[UIFont fontWithName:@"AmericanTypewriter" size:13] constrainedToSize:CGSizeMake(200, 49) lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat cellh = expectedLabelSize.height + 18;
    cellh = ceilf(cellh/7)*7  + 28+7;
    return cellh;
    
}

@end
