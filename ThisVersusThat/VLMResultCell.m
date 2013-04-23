//
//  ExampleCell.m
//  EGOImageLoadingDemo
//
//  Created by Shaun Harrison on 10/19/09.
//  Copyright 2009 enormego. All rights reserved.
//


#import "VLMResultCell.h"
#import "EGOImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "VLMConstants.h"

@implementation VLMResultCell
@synthesize egoImageView;
@synthesize label;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		self.egoImageView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"placeholder.png"]];
        [self.egoImageView setFrame:CGRectMake(0, 0, 59, 59)];
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
		[self.contentView addSubview:self.egoImageView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [titleLabel setFont:[UIFont fontWithName:HEADER_TITLE_FONT size:13.0f]];
        [titleLabel setTextColor:[UIColor colorWithWhite:0.2f alpha:1.0f]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setText:@""];
        [titleLabel setFrame:CGRectMake(65, 0, self.contentView.frame.size.width-75, 60)];
        [self.contentView addSubview:titleLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        label = titleLabel;
	}
	
    return self;
}

- (void)setItemPhoto:(NSString*)flickrPhoto {
    [self.egoImageView setContentMode:UIViewContentModeScaleAspectFit];
	self.egoImageView.imageURL = [NSURL URLWithString:flickrPhoto];
}

- (void)setItemText:(NSString *)text{
    [self.label setText:[text capitalizedString]];
    [self.label setFrame:CGRectMake(65, 0, self.contentView.frame.size.width-75, 60)];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	[super willMoveToSuperview:newSuperview];
	
	if(!newSuperview) {
		[self.egoImageView cancelImageLoad];
	}
}

- (void)dealloc {
}


@end
