//
//  VLMAddButtonController.h
//  ThisVersusThat
//
//  Created by David Lu on 7/23/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VLMMainViewController.h"

@interface VLMAddButtonController : UIViewController{
    UIButton *button;
    VLMMainViewController *mvc;
}

@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) VLMMainViewController *mvc;

- (id)initWithParentController:(VLMMainViewController *)controller;
- (void)show;
- (void)hide;

@end
