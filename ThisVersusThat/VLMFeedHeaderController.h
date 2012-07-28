//
//  VLMFeedHeaderViewController.h
//  ThisVersusThat
//
//  Created by David Lu on 7/17/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VLMFeedHeaderController : UIViewController{
    CGFloat offsetY;
    CGRect rect;
}

- (id)initWithTitle:(NSString *)title;
- (void)pushVerticallyBy:(CGFloat) offsetYVal;


@property (nonatomic) CGFloat offsetY;
@property (nonatomic) CGRect rect;

@end
