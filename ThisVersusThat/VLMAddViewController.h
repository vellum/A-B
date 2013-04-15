//
//  VLMAddViewController.h
//  ThisVersusThat
//
//  Created by David Lu on 7/24/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/PF_FBRequest.h"
#import "PopoverView.h"
#import "VLMSearchViewController.h"
#import "EGOImageView.h"

@class UIPlaceHolderTextView;


@interface VLMAddViewController : UIViewController<UIGestureRecognizerDelegate, UITextViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, VLMSearchViewControllerDelegate, EGOImageViewDelegate, PF_FBRequestDelegate>{

    id<VLMSearchViewControllerDelegate> mydelegate;

}
@property (nonatomic, strong) id<VLMSearchViewControllerDelegate> mydelegate;

- (void) translateByX: (CGFloat) offsetval withVelocity: (CGFloat) velocityval;
- (void) resetAnimated:(BOOL)anim;
- (void) killAnimations;
- (void)cancel:(id)sender;
- (void)handleGenericTap:(id)sender;
@end
