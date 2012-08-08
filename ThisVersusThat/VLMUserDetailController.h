//
//  VLMUserDetailController.h
//  ThisVersusThat
//
//  Created by David Lu on 8/7/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

@interface VLMUserDetailController : UIViewController{
    PFUser *user;
}

@property (strong, nonatomic) PFUser *user;

- (id)initWithObject:(PFUser *)obj;

@end
