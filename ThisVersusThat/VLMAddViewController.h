//
//  VLMAddViewController.h
//  ThisVersusThat
//
//  Created by David Lu on 7/24/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/PF_FBRequest.h"

@class UIPlaceHolderTextView;

@interface VLMAddViewController : UIViewController<UIGestureRecognizerDelegate, UITextViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PF_FBRequestDelegate>

- (void) translateByX: (CGFloat) offsetval withVelocity: (CGFloat) velocityval;
- (void) resetAnimated:(BOOL)anim;
- (void) killAnimations;
- (void)cancel:(id)sender;
- (void)handleGenericTap:(id)sender;

@end
