//
//  VLMFooterController.h
//  ThisVersusThat
//
//  Created by David Lu on 7/17/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
@class VLMMainViewController;

@interface VLMFooterController : UIViewController<UIActionSheetDelegate, PF_FBRequestDelegate> {
    UIButton *feedbutton;
    UIButton *addbutton;
    VLMMainViewController *mainviewcontroller;
}

@property (strong, nonatomic) UIButton *feedbutton;
@property (strong, nonatomic) UIButton *addbutton;
@property (strong, nonatomic) VLMMainViewController *mainviewcontroller;

- (id)initWithMainViewController:(VLMMainViewController *)viewcontroller;
- (UIButton*)makeTextButtonWithFrame:(CGRect)frame andTypeSize:(CGFloat)typesize;
- (void)buttonTapped:(id)sender;
@end
