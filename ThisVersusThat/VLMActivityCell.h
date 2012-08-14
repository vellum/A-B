//
//  VLMActivityCell.h
//  ThisVersusThat
//
//  Created by David Lu on 8/12/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "VLMCommentCell.h"

@interface VLMActivityCell : VLMCommentCell
- (void)setComment:(NSString *)commenttext andQuote:(NSString*)quotetext;
- (void)clearLeftAndRight;
- (void)setLeftFile:(PFFile *)file;
- (void)setRightFile:(PFFile *)file;
- (void)setTriangleDirection:(BOOL)isLeft;
-(void)setTime:(NSDate*)d;
@end
