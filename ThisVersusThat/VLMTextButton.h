//
//  VLMTextButton.h
//  ThisVersusThat
//
//  Created by David Lu on 7/17/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VLMTextButton : UIButton {
    UIView *underline;
}

@property (strong, nonatomic) UIView *underline;

- (id)initWithFrame:(CGRect)frame andTypeSize:(CGFloat)size andColor:(UIColor *)color disabledColor:(UIColor*)disabledcolor andText:(NSString *)text;

@end
