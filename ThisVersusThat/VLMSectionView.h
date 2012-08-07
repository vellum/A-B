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
@protocol VLMFeedHeaderDelegate;

@interface VLMSectionView : UIView{
    UILabel *headerLabel;
    UILabel *detailLabel;
    UIButton *clearbutton;
    UIButton *clearbutton2;
    UIButton *clearbutton3;
    NSInteger section;
    id <VLMFeedHeaderDelegate> delegate;
}


@property (nonatomic, strong) id <VLMFeedHeaderDelegate> delegate;
@property (nonatomic) NSInteger section;
@property (nonatomic, strong) PFImageView *profileImageView;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *clearbutton;
@property (nonatomic, strong) UIButton *clearbutton2;
@property (nonatomic, strong) UIButton *clearbutton3;

- (id)initWithFrame:(CGRect)frame andUserName:(NSString *)username andQuestion:(NSString *)text;
- (void)setUserName:(NSString *)username andQuestion:(NSString *)text; 
- (void)setFile:(PFFile*)file;
@end
