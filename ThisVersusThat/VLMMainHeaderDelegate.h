//
//  VLMMainHeaderDelegate.h
//  ThisVersusThat
//
//  Created by David Lu on 8/27/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VLMFeedHeaderController.h"

@protocol VLMMainHeaderDelegate <NSObject>
- (void)didTapLeftButton:(id)sender;
- (void)didToggleFeedType:(int)feedtype;
@end
