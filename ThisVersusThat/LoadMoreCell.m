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

@interface LoadMoreCell()
@property (nonatomic, strong) VLMTextButton *button;
@end

@implementation LoadMoreCell
@synthesize tv;
@synthesize button;

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
        self.button = loadmore;
    }
    return self;
}

- (void)reset:(BOOL)hasMoreItems{
    if ( hasMoreItems ){
        [button setTitle:@"load more..." forState:UIControlStateNormal];
        [button setSelected:YES];
        [button setEnabled:YES];
        [[button underline] setHidden:NO];
    } else {
        [button setTitle:@"all items loaded." forState:UIControlStateDisabled];
        [[button underline] setHidden:YES];
        [button setEnabled:NO];
    }
}

- (void)press:(id)sender{
    if ( self.tv ){
        [button setTitle:@"loading..." forState:UIControlStateNormal];
        [button setSelected:NO];
        [button setEnabled:NO];
        [[button underline] setHidden:YES];
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
