//
//  VLMAddViewController.h
//  ThisVersusThat
//
//  Created by David Lu on 7/24/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIPlaceHolderTextView;

@interface VLMAddViewController : UIViewController<UIGestureRecognizerDelegate, UITextViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    UIView *containerView;
    CGFloat originalOffsetX;
    CGRect originalRect;
    CGFloat velocity;

    UIView *lefttile;
    UIView *righttile;
    
    UIImageView *leftimage;
    UIImageView *rightimage;
    
    UITextField *leftcaption;
    UITextField *rightcaption;
    
    UIButton *leftcam;
    UIButton *rightcam;
    
}

@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UIView *lefttile;
@property (strong, nonatomic) UIView *righttile;
@property (strong, nonatomic) UITextField *leftcaption;
@property (strong, nonatomic) UITextField *rightcaption;
@property (strong, nonatomic) UIButton *leftcam;
@property (strong, nonatomic) UIButton *rightcam;
@property (strong, nonatomic) UIImageView *leftimage;
@property (strong, nonatomic) UIImageView *rightimage;

@property (nonatomic) CGFloat velocity;
@property (nonatomic) CGFloat originalOffsetX;
@property (nonatomic) CGRect originalRect;


-(void) translateByX: (CGFloat) offsetval withVelocity: (CGFloat) velocityval;
-(void) resetAnimated:(BOOL)anim;
-(void) killAnimations;

- (void)cancel:(id)sender;
- (void)handleGenericTap:(id)sender;

@end
