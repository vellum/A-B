
//
//  UIViewController+Transitions.h
//  Labgoo Misc
//
//  Created by Israel Roth on 3/4/12.
//  Copyright (c) 2012 Labgoo LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController(Transitions)

- (void) presentModalViewController:(UIViewController *)modalViewController withPushDirection: (NSString *) direction;
- (void) dismissModalViewControllerWithPushDirection:(NSString *) direction;

@end