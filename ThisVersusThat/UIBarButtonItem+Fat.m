//
//  UIBarButtonItem+Fat.m
//  ThisVersusThat
//
//  Created by David Lu on 7/24/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "UIBarButtonItem+Fat.h"
#import "VLMConstants.h"

@implementation UIBarButtonItem (Fat)
- (CGSize)sizeThatFits:(CGSize)size {
    CGSize newSize = CGSizeMake(self.width,HEADER_HEIGHT);
    return newSize;
}

@end
