// Copyright 2011 Ping Labs, Inc. All rights reserved.

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

@class VLMMainViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    VLMMainViewController *mainViewController;
}

@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (strong, nonatomic) VLMMainViewController *mainViewController;

- (void)subscribeFinished:(NSNumber *)result error:(NSError *)error;
- (void)showHUD:(NSString *)text animated:(BOOL)animated;
- (void)showHUD:(NSString *)text;
- (void)updateHUD:(NSString *)text;
- (void)hideHUD;
@end
