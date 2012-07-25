//
//  VLMMainViewController.h
//  ThisVersusThat
//
//  Created by David Lu on 7/23/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

@class VLMFooterController;
@class VLMFeedViewController;
@class VLMAddButtonController;

@interface VLMMainViewController : UIViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>{
    VLMFeedViewController *feedViewController;
    VLMFooterController *footerViewController;
    VLMAddButtonController *addButtonController;
}

@property (strong, nonatomic) VLMFeedViewController *feedViewController;
@property (strong, nonatomic) VLMFooterController *footerViewController;
@property (strong, nonatomic) VLMAddButtonController *addButtonController;

- (void)presentLogin;
- (void)presentSignUp;
- (void)showLoggedInState;
- (void)presentAdd;

@end
