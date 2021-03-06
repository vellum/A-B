//
//  ActivityNavButton.m
//  ThisVersusThat
//
//  Created by David Lu on 8/13/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityNavButton.h"
#import "VLMConstants.h"

@interface ActivityNavButton()
@property (nonatomic, strong) UIView *underline;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIColor *enabledColor;
@property (nonatomic, strong) UIColor *disabledColor;
@property (nonatomic, strong) UIColor *highlightColor;
@end

@implementation ActivityNavButton
@synthesize label;
@synthesize underline;
@synthesize disabledColor;
@synthesize enabledColor;
@synthesize highlightColor;

- (id)initWithFrame:(CGRect)frame andTypeSize:(CGFloat)size andColor:(UIColor *)color highlightColor:(UIColor*)highlightcolor disabledColor:(UIColor*)disabledcolor andText:(NSString *)text andImageView:(UIImageView *)iconview
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setAutoresizesSubviews:NO];
        
        CGFloat xpos = 40;//( iconview ) ? 40 : 0;

        // Initialization code
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(xpos, 0, frame.size.width, frame.size.height)];
        self.label.font = [UIFont fontWithName:@"AmericanTypewriter" size:size];
        self.label.textColor = color;
        [self.label setBackgroundColor:[UIColor clearColor]];
        
        [self.label setText:text];
        [self addSubview:label];
        
        if ( iconview ){
            [self addSubview:iconview];
            [iconview setBackgroundColor:[UIColor lightGrayColor]];
            [iconview setFrame:CGRectMake(0, 14, 28, 28)];
        }
        
        CGRect r = self.label.frame;
        CGRect t = CGRectMake(0, r.origin.y + r.size.height, r.size.width, 1.0f);
        UIView *line = [[UIView alloc] initWithFrame:t];
        [line setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.075f]];
        [line setUserInteractionEnabled:NO];

        [self addSubview:line];
        self.underline = line;
        
        [self addTarget:self action:@selector(highlight:) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(unhighlight:) forControlEvents:UIControlEventTouchCancel|UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchDragExit];

        self.enabledColor = color;
        self.disabledColor = disabledcolor;
        self.highlightColor = highlightcolor;
    }
    return self;
}


- (void)highlight:(id)sender{
    label.textColor = self.highlightColor;
    //[self.underline setBackgroundColor:self.highlightColor];
}

- (void)unhighlight:(id)sender{
    self.label.textColor = enabledColor;
    //[self.underline setBackgroundColor:enabledColor];
}

- (void)showLine:(BOOL)show{
    self.underline.hidden = !show;
}
@end
