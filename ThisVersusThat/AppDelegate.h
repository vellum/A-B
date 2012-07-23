// Copyright 2011 Ping Labs, Inc. All rights reserved.

#import <UIKit/UIKit.h>

@class VLMFooterController;
@class VLMFeedViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    VLMFeedViewController *feedViewController;
    VLMFooterController *footerViewController;
}

@property (nonatomic) IBOutlet UIWindow *window;
@property (strong, nonatomic) VLMFeedViewController *feedViewController;
@property (strong, nonatomic) VLMFooterController *footerViewController;

- (void)subscribeFinished:(NSNumber *)result error:(NSError *)error;

@end
