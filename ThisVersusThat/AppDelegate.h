// Copyright 2011 Ping Labs, Inc. All rights reserved.

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import "PopoverView.h"

#ifdef REFLECTOR_ENABLED
#import "OPPresentatorWindow.h"
#endif

@class VLMMainViewController;
@class VLMSearchViewController;
@protocol VLMSearchViewControllerDelegate;


@interface AppDelegate : NSObject <UIApplicationDelegate, PopoverViewDelegate, UITableViewDelegate, UITableViewDataSource> {
    VLMMainViewController *mainViewController;
}

#ifdef REFLECTOR_ENABLED
@property (strong, nonatomic) OPPresentatorWindow *window;

#else
@property (strong, nonatomic) UIWindow *window;

#endif

@property (strong, nonatomic) VLMMainViewController *mainViewController;
@property (strong,nonatomic) id<VLMSearchViewControllerDelegate>searchDelegate;

- (void)subscribeFinished:(NSNumber *)result error:(NSError *)error;
- (void)showHUD:(NSString *)text animated:(BOOL)animated;
- (void)showHUD:(NSString *)text;
- (void)showHUDPosting;
- (void)hideHUDPosting;
- (void)updateHUD:(NSString *)text;
- (void)hideHUD;
- (void)showErrorHUD:(NSString *)text;
- (BOOL)isParseReachable;
- (void)showPopover:(NSString *)query delegate:(id)mydelegate;

@end
