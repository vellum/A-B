//
//  VLMFooterController.m
//  ThisVersusThat
//
//  Created by David Lu on 7/17/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "VLMFooterController.h"
#import "VLMConstants.h"
#import "VLMTextButton.h"

@interface VLMFooterController ()

@end

@implementation VLMFooterController

@synthesize feedbutton;
@synthesize addbutton;

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
    CGFloat winh = [[UIScreen mainScreen] bounds].size.height;
    CGFloat winw = [[UIScreen mainScreen] bounds].size.width;
    CGRect contentrect = CGRectMake(0.0f, winh - 50, winw, 50);
    [[self view] setFrame:contentrect];
    
    // set background
    [[self view] setBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1.0]];
    
    /*
    // feed button
    VLMTextButton *fb = [[VLMTextButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 65.0f, 50.0f) andTypeSize:13.0f andColor:TEXT_MIDCOLOR andText:@"Feed" andUnderlineHeight:3.0f];
    //[fb setSelected:YES];
    [[self view] addSubview:fb];
    self.feedbutton = fb;
     */
    
    // add button
    /*
     UIImage *addimage = [UIImage imageNamed:@"plus@2x.png"];
     UIButton *ab = [[UIButton alloc] initWithFrame:CGRectMake(winw/2-30.0f, 0.0f, 60.0f, 50.0f)];
     [ab setImage:addimage forState:UIControlStateNormal];
     [ab setImage:addimage forState:UIControlStateHighlighted];
     */
    UIButton *ab = [self makeTextButtonWithFrame:CGRectMake(winw/2-50.0f, 0.0f, 100.0f, FOOTER_HEIGHT) andTypeSize:28.0f];
    [ab setTitle:@"+" forState:UIControlStateNormal];
    [ab setShowsTouchWhenHighlighted:YES];
    CGRect r = ab.titleLabel.frame;
    r.origin.y -= 2;
    ab.titleLabel.frame = r;
    //[ab setSelected:YES];
    [[self view] addSubview:ab];
    self.addbutton = ab;
    
    /*
    UIButton *mb = [self makeTextButtonWithFrame:CGRectMake(winw-56.0f, 0.0f, 56.0f, FOOTER_HEIGHT) andTypeSize:14.0f];
    [mb setTitle:@"..." forState:UIControlStateNormal];
    [mb setShowsTouchWhenHighlighted:YES];
    [self.view addSubview:mb];
    */
    
    //UIView *border = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winw, BORDER_WIDTH)];
    //border.backgroundColor = BORDER_COLOR;
    //[self.view addSubview:border];
    
}


- (UIButton*)makeTextButtonWithFrame:(CGRect)frame andTypeSize:(CGFloat)typesize
{
    UIButton *fb = [[UIButton alloc] initWithFrame:frame];
    fb.titleLabel.font = [UIFont fontWithName:HELVETICA size:typesize];
    [fb setTitleColor:TEXT_MIDCOLOR forState:UIControlStateNormal];
    [fb setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [fb setShowsTouchWhenHighlighted:YES];
    
    return fb;
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
