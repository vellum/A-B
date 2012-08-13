//
//  ActivityViewController.h
//  ThisVersusThat
//
//  Created by David Lu on 8/11/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <Parse/Parse.h>
#import "VLMGenericTapDelegate.h"
@interface ActivityViewController : PFQueryTableViewController<VLMGenericTapDelegate>
- (id)initWithPopDelegate:(id)popmodaldelegate;
-(void)enable:(BOOL)enabled;
@end
