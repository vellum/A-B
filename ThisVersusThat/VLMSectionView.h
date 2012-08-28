//
//  VLMSectionView.h
//  ThisVersusThat
//
//  Created by David Lu on 7/17/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PFImageView;
@class PFFile;
@protocol VLMSectionDelegate;

@interface VLMSectionView : UIView{
    UILabel *headerLabel;
    UILabel *detailLabel;
    UIButton *clearbutton;
    UIButton *clearbutton2;
    UIButton *clearbutton3;
    UILabel *timestamp;
    NSInteger section;
    id <VLMSectionDelegate> delegate;
}


@property (nonatomic, strong) id <VLMSectionDelegate> delegate;
@property (nonatomic) NSInteger section;
@property (nonatomic, strong) PFImageView *profileImageView;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *clearbutton;
@property (nonatomic, strong) UIButton *clearbutton2;
@property (nonatomic, strong) UIButton *clearbutton3;

@property (nonatomic, strong) UILabel *timestamp;

- (id)initWithFrame:(CGRect)frame andUserName:(NSString *)username andQuestion:(NSString *)text;
- (void)setUserName:(NSString *)username andQuestion:(NSString *)text; 
- (void)setFile:(PFFile*)file;

- (void)setTime:(NSDate*)d;
- (void)setDetailButtonEnabled:(BOOL)enabled;
- (void)reset;
@end
