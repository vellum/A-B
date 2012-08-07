//
//  VLMFeedHeaderDelegate.h
//  ThisVersusThat
//
//  Created by David Lu on 8/7/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VLMFeedHeaderDelegate <NSObject>
- (void)didTapUser:(NSInteger)section;
- (void)didTapPoll:(NSInteger)section; 
@end
