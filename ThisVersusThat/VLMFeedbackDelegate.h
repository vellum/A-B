//
//  VLMFeedbackDelegate.h
//  ThisVersusThat
//
//  Created by David Lu on 5/27/13.
//
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"

@protocol VLMFeedbackDelegate <NSObject>
- (void)feedbackTapped:(PFObject *)obj;
@end
