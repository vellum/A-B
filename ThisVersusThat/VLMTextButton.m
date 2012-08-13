//
//  VLMTextButton.m
//  ThisVersusThat
//
//  Created by David Lu on 7/17/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "VLMTextButton.h"
#import "VLMConstants.h"
@interface VLMTextButton()
@property (nonatomic, strong) UIColor *col;
@end

@implementation VLMTextButton

@synthesize underline;
@synthesize col;

- (id)initWithFrame:(CGRect)frame andTypeSize:(CGFloat)size andColor:(UIColor *)color disabledColor:(UIColor*)disabledcolor andText:(NSString *)text
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setAutoresizesSubviews:NO];

        // Initialization code
        self.titleLabel.font = [UIFont fontWithName:@"AmericanTypewriter" size:size];
        [self setTitle:text forState:UIControlStateNormal];
        [self setTitleColor:color forState:UIControlStateNormal];
        
        [self setTitleColor:disabledcolor forState:UIControlStateDisabled];
        [self setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
        [self setShowsTouchWhenHighlighted:NO];
        
        CGRect r = self.titleLabel.frame;
        CGRect t = CGRectMake(r.origin.x, r.origin.y + r.size.height, r.size.width, 1.5f);
        UIView *line = [[UIView alloc] initWithFrame:t];
        [line setBackgroundColor:color];
        [line setUserInteractionEnabled:NO];
        [self addSubview:line];
        self.underline = line;
        
        [self addTarget:self action:@selector(highlight:) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(unhighlight:) forControlEvents:UIControlEventTouchCancel|UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
        [self setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        
        self.col = color;
    }
    return self;
}
- (void)highlight:(id)sender{
    [self setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.underline setBackgroundColor:[UIColor lightGrayColor]];
}
- (void)unhighlight:(id)sender{
    [self setTitleColor:col forState:UIControlStateNormal];
    [self.underline setBackgroundColor:col];
}

@end
