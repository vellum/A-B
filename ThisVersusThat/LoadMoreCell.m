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
#import "VLMGenericTapDelegate.h"

@interface LoadMoreCell()
@property (nonatomic, strong) VLMTextButton *button;
@property (nonatomic, strong) id <VLMGenericTapDelegate> tapdelegate;
@end

@implementation LoadMoreCell
@synthesize button;
@synthesize tapdelegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier color:(UIColor*)color disabledcolor:(UIColor*)disabledcolor
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.contentView.backgroundColor = [UIColor clearColor];
        
        VLMTextButton *loadmore = [[VLMTextButton alloc] initWithFrame:CGRectMake(15, 0, 286, 60) andTypeSize:13.0f andColor:color disabledColor:disabledcolor andText:@"load more..."];
        [loadmore setBackgroundColor:[UIColor clearColor]];
        //[loadmore setBackgroundImage:[UIImage imageNamed:@"gray_header_background.png"] forState:UIControlStateHighlighted];
        [self.contentView addSubview:loadmore];
        [loadmore addTarget:self action:@selector(press:) forControlEvents:UIControlEventTouchUpInside];
        self.button = loadmore;
    }
    return self;

}

- (id)initWithFrame:(CGRect)frame style:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier color:(UIColor*)color disabledcolor:(UIColor*)disabledcolor{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.contentView.backgroundColor = [UIColor clearColor];
        
        VLMTextButton *loadmore = [[VLMTextButton alloc] initWithFrame:frame andTypeSize:13.0f andColor:color disabledColor:disabledcolor andText:@"load more..."];
        [loadmore setBackgroundColor:[UIColor clearColor]];
        [loadmore setBackgroundImage:[UIImage imageNamed:@"gray_header_background.png"] forState:UIControlStateHighlighted];
        [self.contentView addSubview:loadmore];
        [loadmore addTarget:self action:@selector(press:) forControlEvents:UIControlEventTouchUpInside];
        self.button = loadmore;
    }
    return self;
}


- (void)reset:(BOOL)hasMoreItems isLoading:(BOOL)loading{
    if ( loading ){
        [button setTitle:@"loading..." forState:UIControlStateDisabled];
        [button setEnabled:NO];
        [[button underline] setHidden:YES];
        [button setNeedsDisplay];
        return;
    }
    if ( hasMoreItems ){
        //[button setSelected:YES];
        [button setTitle:@"load more..." forState:UIControlStateNormal];
        [button setEnabled:YES];
        [[button underline] setHidden:NO];
    } else {
        [button setTitle:@"all items loaded." forState:UIControlStateDisabled];
        [button setEnabled:NO];
        [[button underline] setHidden:YES];
    }
    [button setNeedsDisplay];
}

- (void)press:(id)sender{
    NSLog(@"pressed loadmore");
    if ( tapdelegate ){
        
        NSLog(@"tapdelegate exists");
        [button setTitle:@"loading..." forState:UIControlStateNormal];
        [button setSelected:NO];
        [button setEnabled:NO];
        [[button underline] setHidden:YES];
        [tapdelegate didTap:self];
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
- (void)setTextColor:(UIColor *)textColor{
    [self.button setTitleColor:textColor forState:UIControlStateNormal];
    [self.button setFrame:CGRectMake(20, 0, self.frame.size.width-40-20 - 20, self.frame.size.height)];
}
- (void)setDelegate:(id)delegate{
    self.tapdelegate = delegate;
}
@end
