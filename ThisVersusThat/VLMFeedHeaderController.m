//
//  VLMFeedHeaderViewController.m
//  ThisVersusThat
//
//  Created by David Lu on 7/17/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "VLMFeedHeaderController.h"
#import "VLMConstants.h"
#import "VLMTextButton.h"
#import <QuartzCore/QuartzCore.h>
@interface VLMFeedHeaderController ()

@end

@implementation VLMFeedHeaderController

@synthesize rect;
@synthesize offsetY;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // dimensions
    CGFloat winw = [[UIScreen mainScreen] bounds].size.width;
    CGRect contentrect = CGRectMake(0.0f, 0.0f, winw, HEADER_HEIGHT+HEADER_CORNER_RADIUS);
    self.rect = contentrect;
    self.offsetY = 0.0f;
    //[[self view] setFrame:contentrect];
    [[self view] setFrame:CGRectOffset(self.rect, 0.0f, self.offsetY)];
    
    // set background
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"skewed_print.png"]]];
    
    
    [self view].layer.cornerRadius = HEADER_CORNER_RADIUS;
    [self view].layer.masksToBounds = YES;

    //self.view.layer.cornerRadius = 5.0;

    /*
     CGFloat buttonwidth = 75.0f;

     // all polls
    VLMTextButton *all = [[VLMTextButton alloc] 
                          //initWithFrame:CGRectMake(winw/2 - buttonwidth, 10.0f, buttonwidth, HEADER_HEIGHT-10.0f)
                          initWithFrame:CGRectMake(winw/2 - buttonwidth/2, 10.0f, buttonwidth, HEADER_HEIGHT-10.0f)
                         andTypeSize:18.0f 
                         andColor:HEADER_TEXT_COLOR 
                         andText:@"All Polls"];
    [all setSelected:YES];
    [[self view] addSubview:all];
*/
    /*
    VLMTextButton *mine = [[VLMTextButton alloc] 
                         initWithFrame:CGRectMake(winw/2, 10.0f, buttonwidth, HEADER_HEIGHT-10.0f)
                         andTypeSize:14.0f 
                         andColor:HEADER_TEXT_COLOR 
                         andText:@"Just Mine"];
    [mine setSelected:NO];
    [mine setEnabled:NO];
    [[self view] addSubview:mine];
    */
}


- (UIButton*)makeTextButtonWithFrame:(CGRect)frame
{
    UIButton *fb = [[UIButton alloc] initWithFrame:frame];
    fb.titleLabel.font = [UIFont fontWithName:HELVETICA size:14.0f];
    UIColor *titlecolor = TEXT_COLOR;
    [fb setTitleColor:titlecolor forState:UIControlStateNormal];
    [fb setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [fb setShowsTouchWhenHighlighted:YES];
    return fb;
}

- (void)pushVerticallyBy:(CGFloat) offsetYVal{
    self.offsetY = offsetYVal;
    [[self view] setFrame:CGRectOffset(self.rect, 0.0f, self.offsetY)];
    //[self.view setNeedsDisplay];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
