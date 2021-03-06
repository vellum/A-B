//
//  UIPlaceholderTextView.h
//  ThisVersusThat
//
//  Created by David Lu on 7/25/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface UIPlaceHolderTextView : UITextView {
    NSString *placeholder;
    UIColor *placeholderColor;
    UILabel *placeHolderLabel;
}

@property (nonatomic) UILabel *placeHolderLabel;
@property (nonatomic) NSString *placeholder;
@property (nonatomic) UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;

@end