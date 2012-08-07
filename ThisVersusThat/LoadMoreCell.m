//
//  LoadMoreCell.m
//  ThisVersusThat
//
//  Created by David Lu on 8/6/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "LoadMoreCell.h"
#import "VLMTextButton.h"
#import "VLMFeedTableViewController.h"


@implementation LoadMoreCell
@synthesize tv;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.contentView.backgroundColor = [UIColor clearColor];
        
        VLMTextButton *loadmore = [[VLMTextButton alloc] initWithFrame:CGRectMake(15, 0, 286, 60) andTypeSize:13.0f andColor:[UIColor blackColor] andText:@"load more..."  andUnderlineHeight:1.5f];
        [loadmore setBackgroundColor:[UIColor clearColor]];
        [loadmore setBackgroundImage:[UIImage imageNamed:@"gray_header_background.png"] forState:UIControlStateHighlighted];
        [self.contentView addSubview:loadmore];
        [loadmore addTarget:self action:@selector(press:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)press:(id)sender{
    if ( self.tv ){
        [self.tv loadNextPage];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    //[super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)translateByX: (CGFloat) offsetval withVelocity: (CGFloat) velocityval{}
- (void)resetAnimated:(BOOL)anim{}
- (void)killAnimations{}
- (void)setInitialPage:(BOOL)leftside{}

@end
