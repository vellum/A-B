//
//  VLMSearchViewController.h
//  ThisVersusThat
//
//  Created by David Lu on 4/13/13.
//
//

#import <UIKit/UIKit.h>

@protocol VLMSearchViewControllerDelegate;

@interface VLMSearchViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    id<VLMSearchViewControllerDelegate> mydelegate;
}

@property (nonatomic, strong) id<VLMSearchViewControllerDelegate> mydelegate;

@end

@protocol VLMSearchViewControllerDelegate
- (void)searchViewControllerFinished:(VLMSearchViewController*)viewController;
- (void)didSelectItemWithTitle:(NSString *)title andImageURL:(NSString *)url;
@end