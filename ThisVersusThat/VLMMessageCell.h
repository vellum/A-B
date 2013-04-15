//
//  VLMMessageCell.h
//  ThisVersusThat
//
//  Created by David Lu on 4/13/13.
//
//

#import <UIKit/UIKit.h>

@interface VLMMessageCell : UITableViewCell{
@private
    UILabel *label;
    UIActivityIndicatorView *spinner;
    UIView *square;
}
- (void)showSpinner;
- (void)hideSpinner;
- (void)setItemText:(NSString *)text;
@end
