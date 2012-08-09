//
//  VLMCommentCell.m
//  ThisVersusThat
//
//  Created by David Lu on 8/8/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "VLMCommentCell.h"
#import "VLMConstants.h"

@interface VLMCommentCell ()
@property (nonatomic, strong) PFImageView* imageview;
@property (nonatomic, strong) UILabel* userlabel;
@property (nonatomic, strong) UILabel* commentlabel;
@property (nonatomic, strong) UIView* back;
@end

@implementation VLMCommentCell

@synthesize imageview;
@synthesize userlabel;
@synthesize commentlabel;
@synthesize back;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    CGFloat x = 20;
    CGFloat y = 0;
    CGFloat w = 40 * 7;
    self.back = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, self.frame.size.height)];
    [back setBackgroundColor:[UIColor whiteColor]];
    [back setAutoresizesSubviews:NO];
    
    [self.contentView addSubview:self.back];
    
    self.imageview = [[PFImageView alloc] initWithFrame:CGRectMake(3, 3, 25, 25)];
    self.userlabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 3, w, 14)];
    [userlabel setFont:[UIFont fontWithName:@"AmericanTypewriter-Bold" size:13.0f]];
    [userlabel setBackgroundColor:[UIColor clearColor]];
    [userlabel setTextColor:TEXT_COLOR];
    
    self.commentlabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 18, w-3-20-5-5, 49)];
    [commentlabel setFont:[UIFont fontWithName:@"AmericanTypewriter" size:13.0f]];
    [commentlabel setNumberOfLines:0];
    [commentlabel setBackgroundColor:[UIColor clearColor]];
    
    [back addSubview:imageview];
    [back addSubview:userlabel];
    [back addSubview:commentlabel];
    
    return self;
}

- (void)setFile:(PFFile *)file{
    [self.imageview setFile:file];
}

- (void)setUser:(NSString *)username{
    [self.userlabel setText:username];
}

- (void)setComment:(NSString *)commenttext{
    [self.commentlabel setText:commenttext];
    [self.commentlabel sizeToFit];
    CGFloat x = 20;
    CGFloat y = 0;
    CGFloat w = 40 * 7;

    [back setFrame:CGRectMake(x, y, w, commentlabel.frame.size.height + 20)];
}


@end
