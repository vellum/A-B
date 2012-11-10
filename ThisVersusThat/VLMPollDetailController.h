//
//  VLMPollDetailController.h
//  ThisVersusThat
//
//  Created by David Lu on 8/7/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Parse/Parse.h"
#import "VLMFeedHeaderDelegate.h"

@interface VLMPollDetailController : PFQueryTableViewController<UITextViewDelegate, VLMSectionDelegate, UIActionSheetDelegate, MKMapViewDelegate>{
    PFObject *poll;
}

@property (strong, nonatomic) PFObject *poll;

- (id)initWithObject:(PFObject *)obj isRoot:(BOOL)isRoot;
- (void)scrollToComments;
- (void)scrollToCommentsAndPopKeyboard;
- (void)handleMapTap:(id)sender;
@end
