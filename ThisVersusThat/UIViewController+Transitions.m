//
//  UiViewController+Transitions.m
//  Labgoo Misc
//
//  Created by Israel Roth on 3/4/12.
//  Copyright (c) 2012 Labgoo LTD. All rights reserved.
//
//http://srooltheknife.blogspot.com/2012/03/custom-transition-animation-for-modal.html

#import "UIViewController+Transitions.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIViewController(Transitions)

- (void) presentModalViewController:(UIViewController *)modalViewController withPushDirection: (NSString *) direction {
    
    [CATransaction begin];
    
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionPush;
    transition.subtype = direction;
    transition.duration = 0.25f;
    transition.fillMode = kCAFillModeForwards;
    transition.removedOnCompletion = YES;
    
    [[UIApplication sharedApplication].keyWindow.layer addAnimation:transition forKey:@"transition"];        
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [CATransaction setCompletionBlock: ^ {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(transition.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^ {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];        
        });
    }];
    
    [self presentModalViewController:modalViewController animated:NO];
    
    [CATransaction commit];
    
}

- (void) dismissModalViewControllerWithPushDirection:(NSString *) direction {
    
    [CATransaction begin];
    
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionPush;
    transition.subtype = direction;
    transition.duration = 0.25f;
    transition.fillMode = kCAFillModeForwards;
    transition.removedOnCompletion = YES;
    
    [[UIApplication sharedApplication].keyWindow.layer addAnimation:transition forKey:@"transition"];        
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [CATransaction setCompletionBlock: ^ {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(transition.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^ {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];        
        });
    }];
    
    [self dismissModalViewControllerAnimated:NO];
    
    [CATransaction commit];
    
}

@end
