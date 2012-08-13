//
//  VLMCommentCell.h
//  ThisVersusThat
//
//  Created by David Lu on 8/8/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <Parse/Parse.h>

@interface VLMCommentCell : PFTableViewCell{
    
    PFImageView* imageview;
    UILabel* userlabel;
    UILabel* commentlabel;
    UIView* back;

}
@property (nonatomic, strong) PFImageView* imageview;
@property (nonatomic, strong) UILabel* userlabel;
@property (nonatomic, strong) UILabel* commentlabel;
@property (nonatomic, strong) UIView* back;

- (void)setFile:(PFFile *)file;
- (void)setUser:(NSString *)username;
- (void)setComment:(NSString *)commenttext;
- (void)setUserColor:(UIColor *)color;
- (void)setCommentColor:(UIColor *)color;

+ (CGFloat)heightForDescriptionText:(NSString *)text;
@end
