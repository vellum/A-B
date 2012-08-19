//
//  FollowCell.m
//  ThisVersusThat
//
//  Created by David Lu on 8/18/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//
#import <Parse/Parse.h>
#import "FollowCell.h"
@interface FollowCell()
@property (nonatomic, strong) PFImageView *icon;
@property (nonatomic, strong) UILabel *label;
@end

@implementation FollowCell
@synthesize icon;
@synthesize label;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        UIView *whitefield = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 4*14)];
        [whitefield setBackgroundColor:[UIColor whiteColor]];
        // Initialization code
        label = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 40*5, 4*14)];
        [label setFont:[UIFont fontWithName:@"AmericanTypewriter" size:13.0f]];
        [label setBackgroundColor:[UIColor clearColor]];
        self.icon = [[PFImageView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 4*14-10, 4*14-10)];
         
         [self.contentView addSubview:whitefield];
         [whitefield addSubview:icon];
        [whitefield addSubview:label];
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setFile:(PFFile *)file{
    [self.icon setImage:[UIImage imageNamed:@"clear.png"]];
    [self.icon setBackgroundColor:[UIColor lightGrayColor]];
    if (!file) {
        return;
    }

    [self.icon setFile:file];
    [self.icon loadInBackground];
}

- (void)setText:(NSString *)text{
    [self.label setText: text];
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
