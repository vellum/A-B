//
//  ExampleCell.h
//  EGOImageLoadingDemo
//
//  Created by Shaun Harrison on 10/19/09.
//  Copyright 2009 enormego. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EGOImageView;
@interface VLMResultCell : UITableViewCell {
@private
	EGOImageView *imageView;
    UILabel *label;
}
- (void)setItemPhoto:(NSString*)flickrPhoto;
- (void)setItemText:(NSString *)text;
@end
