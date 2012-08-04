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

@interface VLMSectionView : UIView{
}

@property (nonatomic, strong) PFImageView *profileImageView;

- (id)initWithFrame:(CGRect)frame andUserName:(NSString *)username andQuestion:(NSString *)text;
- (void)setFile:(PFFile*)file;
@end
