//
//  VLMTextButton.m
//  ThisVersusThat
//
//  Created by David Lu on 7/17/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "VLMTextButton.h"
#import "VLMConstants.h"

@implementation VLMTextButton

@synthesize underline;

- (id)initWithFrame:(CGRect)frame andTypeSize:(CGFloat)size andColor:(UIColor *)color andText:(NSString *)text
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.titleLabel.font = [UIFont fontWithName:HELVETICA size:size];
        [self setTitle:text forState:UIControlStateNormal];
        [self setTitleColor:color forState:UIControlStateNormal];
        
        //CGFloat h, s, b, a;
        //[color getHue:&h saturation:&s brightness:&b alpha:&a];
        //[self setTitleColor:[UIColor colorWithHue:h saturation:s brightness:b*2 alpha:1.0] forState:UIControlStateDisabled];
        [self setTitleColor:DISABLED_TEXT_COLOR forState:UIControlStateDisabled];
        [self setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
        [self setShowsTouchWhenHighlighted:YES];
        
        CGRect r = self.titleLabel.frame;
        CGRect t = CGRectMake(r.origin.x, r.origin.y + r.size.height, r.size.width, 4.0f);
        UIView *line = [[UIView alloc] initWithFrame:t];
        [line setBackgroundColor:color];
        [line setUserInteractionEnabled:NO];
        [self addSubview:line];
        self.underline = line;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andTypeSize:(CGFloat)size andColor:(UIColor *)color andText:(NSString *)text andUnderlineHeight:(CGFloat)underlineHeight{
    self = [self initWithFrame:frame andTypeSize:size andColor:color andText:text];
    if( self ){
        CGRect r = self.titleLabel.frame;
        CGRect t = CGRectMake(r.origin.x, r.origin.y + r.size.height, r.size.width, underlineHeight);
        self.underline.frame = t;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [super drawRect:rect];
    
    self.underline.hidden = !self.selected;
    
}
@end
