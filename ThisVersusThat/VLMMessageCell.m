//
//  VLMMessageCell.m
//  ThisVersusThat
//
//  Created by David Lu on 4/13/13.
//
//

#import "VLMMessageCell.h"
#import "VLMConstants.h"

@implementation VLMMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self.contentView setBackgroundColor:[UIColor whiteColor]];

        UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        [bg setBackgroundColor:[UIColor colorWithWhite:0.95f alpha:1.0f]];
        [self.contentView addSubview:bg];
        square = bg;
        
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.center = CGPointMake(30, 30);
        [spinner stopAnimating];
		[self.contentView addSubview:spinner];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [titleLabel setFont:[UIFont fontWithName:HEADER_TITLE_FONT size:13.0f]];
        [titleLabel setTextColor:[UIColor colorWithWhite:0.2f alpha:1.0f]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setText:@""];
        [titleLabel setFrame:CGRectMake(65, 0, 240-75, 60)];
        [self.contentView addSubview:titleLabel];
        label = titleLabel;
        self.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)showSpinner{
    [spinner setHidden:NO];
    [spinner startAnimating];
    [square setHidden:NO];
    [label setFrame:CGRectMake(65, 0, self.contentView.frame.size.width-75, 60)];
    [label setTextAlignment:NSTextAlignmentLeft];
}

- (void)hideSpinner{
    [spinner setHidden:YES];
    [spinner stopAnimating];
    [square setHidden:YES];
    
    [label setFrame:CGRectMake(5, 0, self.contentView.frame.size.width-10, 60)];
    [label setTextAlignment:NSTextAlignmentCenter];
}

- (void)setItemText:(NSString *)text{
    NSLog(@"settingitemtext: %@", text);
    [label setText:text];
    [label setHidden:NO];
}

@end
