//
//  VLMFooterController.h
//  ThisVersusThat
//
//  Created by David Lu on 7/17/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VLMFooterController : UIViewController {
    UIButton *feedbutton;
    UIButton *addbutton;
}
@property (strong, nonatomic) UIButton *feedbutton;
@property (strong, nonatomic) UIButton *addbutton;
- (UIButton*)makeTextButtonWithFrame:(CGRect)frame andTypeSize:(CGFloat)typesize;
@end
