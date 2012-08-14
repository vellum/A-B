//
//  ActivityNavButton.h
//  ThisVersusThat
//
//  Created by David Lu on 8/13/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityNavButton : UIButton

- (id)initWithFrame:(CGRect)frame andTypeSize:(CGFloat)size andColor:(UIColor *)color highlightColor:(UIColor*)highlightcolor disabledColor:(UIColor*)disabledcolor andText:(NSString *)text;

- (void)highlight:(id)sender;

- (void)unhighlight:(id)sender;
- (void)showLine:(BOOL)show;
@end
