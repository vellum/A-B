//
//  VLMAddViewController.m
//  ThisVersusThat
//
//  Created by David Lu on 7/24/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "VLMAddViewController.h"
#import "VLMConstants.h"
#import "UINavigationBar+Fat.h"
#import "UIBarButtonItem+Fat.h"
#import "UIPlaceholderTextView.h"
#import <QuartzCore/QuartzCore.h>

@interface VLMAddViewController ()

@end

@implementation VLMAddViewController

@synthesize containerView;
@synthesize originalOffsetX;
@synthesize originalRect;
@synthesize velocity;
@synthesize lefttile;
@synthesize righttile;
@synthesize leftcaption;
@synthesize rightcaption;

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
    
    [self setuptoolbar];
    [self setuptaprecognizer];
    [self setupquestion];
    [self setupimages];
}

#pragma mark -
#pragma mark UI Setup

- (void)setuptoolbar {

    [self setTitle:@"Add Poll"];
	[self.view setBackgroundColor:FEED_TABLEVIEW_BGCOLOR];
    
    NSDictionary *dick = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIColor clearColor], UITextAttributeTextShadowColor,
                          
                          [UIColor colorWithWhite:0.2f alpha:1.0f], UITextAttributeTextColor, 
                          [UIFont fontWithName:@"AmericanTypewriter" size:13.0f], UITextAttributeFont, 
                          nil];
    
    UIBarButtonItem *cancelbutton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    [cancelbutton setTitleTextAttributes:dick forState:UIControlStateNormal];
    [cancelbutton setTitlePositionAdjustment:UIOffsetMake(0.0f, BAR_BUTTON_ITEM_VERTICAL_OFFSET) forBarMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *donebutton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(cancel:)];
    [donebutton setTitleTextAttributes:dick forState:UIControlStateNormal];
    [donebutton setTitlePositionAdjustment:UIOffsetMake(0.0f, BAR_BUTTON_ITEM_VERTICAL_OFFSET) forBarMetrics:UIBarMetricsDefault];
    [donebutton setEnabled:NO];
    
    [self.navigationItem setLeftBarButtonItem:cancelbutton];
    [self.navigationItem setRightBarButtonItem:donebutton];
}

- (void)setuptaprecognizer {
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGenericTap:)];
    [tgr setDelegate:self];
    [self.view addGestureRecognizer:tgr];
}

- (void)setupquestion{
    UIView *questionholder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 14*6)];
    UIPlaceHolderTextView *question = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(5, 5, self.view.frame.size.width-10, 14*6-10)];
    [question setKeyboardType:UIKeyboardTypeAlphabet];
    [question setBackgroundColor:[UIColor whiteColor]];
    [question setPlaceholder:@"Which couch should I buy?"];
    [question setFont:[UIFont fontWithName:@"AmericanTypewriter" size:14.0f]];
    [question setReturnKeyType: UIReturnKeyDone];
    [question setDelegate:self];
    
    [questionholder addSubview:question];
    [questionholder setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:questionholder];
}

- (void)setupimages{

    self.originalOffsetX = 0.0f;
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 6*14, 640.0f, 294.0f)];
    self.velocity = 0;
    
    UIView *left = [[UIView alloc] initWithFrame:CGRectMake(20, 14-5, 276, 276)];
    left.backgroundColor = [UIColor colorWithWhite:1 alpha:1.0];
    [self.containerView addSubview:left];
    
    UIImageView *leftimage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo_placeholder.png"]];
    [leftimage setFrame:CGRectMake(5, 5, 266, 266)];
    [left addSubview:leftimage];
    self.lefttile = left;
    
    UIView *leftShade = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 266, 266)];
    [leftShade setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    [left addSubview:leftShade];
    
    UIView *right = [[UIView alloc] initWithFrame:CGRectMake(20 + 276+1, 14-5, 276, 276)];
    right.backgroundColor = [UIColor colorWithWhite:1 alpha:1.0];
    [self.containerView addSubview:right];
    self.righttile = right;
    
    UIImageView *rightimage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo_placeholder.png"]];
    [rightimage setFrame:CGRectMake(5, 5, 266, 266)];
    [right addSubview:rightimage];
    
    UIView *rightShade = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 266, 266)];
    [rightShade setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    [right addSubview:rightShade];
    
    [self.view addSubview:self.containerView];
    
    // swipe-a-dooodle
    UIPanGestureRecognizer *pgr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [pgr setDelegate:self];
    [self.containerView addGestureRecognizer:pgr];
    self.originalRect = self.containerView.frame;
    
    UIPlaceHolderTextView *captionLeft = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(5, 5, 266, 14*4)];
    [captionLeft setKeyboardType:UIKeyboardTypeAlphabet];
    [captionLeft setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    [captionLeft setTextColor:[UIColor whiteColor]];
    [captionLeft setPlaceholderColor:[UIColor colorWithWhite:1.0f alpha:0.5]];
    [captionLeft setPlaceholder:@"Untitled"];
    [captionLeft setFont:[UIFont fontWithName:@"AmericanTypewriter" size:14.0f]];
    [captionLeft setReturnKeyType: UIReturnKeyDone];
    [captionLeft setDelegate:self];
    self.leftcaption = captionLeft;
    
    [left addSubview:captionLeft];
    
    UIPlaceHolderTextView *captionRight = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(5, 5, 266, 14*4)];
    [captionRight setKeyboardType:UIKeyboardTypeAlphabet];
    [captionRight setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    [captionRight setTextColor:[UIColor whiteColor]];
    [captionRight setPlaceholder:@"Untitled"];
    [captionRight setPlaceholderColor:[UIColor colorWithWhite:1.0f alpha:0.5]];
    [captionRight setFont:[UIFont fontWithName:@"AmericanTypewriter" size:14.0f]];
    [captionRight setReturnKeyType: UIReturnKeyDone];
    [captionRight setDelegate:self];
    self.rightcaption = captionRight;
    [right addSubview:captionRight];
    
    UIButton *leftcam = [[UIButton alloc] initWithFrame:CGRectMake(10, 4, 50, 50)];;
    [leftcam setShowsTouchWhenHighlighted:YES];
    [leftcam setImage:[UIImage imageNamed:@"leica.png"] forState:UIControlStateNormal];
    [left addSubview:leftcam];

    //UIButton *rightcam = [[UIButton alloc] initWithFrame:CGRectMake(10, 4, 44, 44)];;
    //[rightcam setShowsTouchWhenHighlighted:YES];
    //[rightcam setImage:[UIImage imageNamed:@"leica.png"] forState:UIControlStateNormal];
    //[right addSubview:rightcam];

}

#pragma mark -
#pragma mark TextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    /*
    if ( textView == self.leftcaption || textView == self.rightcaption ){
        if ( textView.text.length > 50 ){
            return NO;
        } else {
            return YES;
        }
    }
    */
    if([text isEqualToString:@"\n"]) {
        [self.view endEditing:YES];
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark GestureDelegate

- (BOOL)gestureRecognizerShouldBegin:(UITapGestureRecognizer *)gestureRecognizer
{
    return YES;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
}

#pragma mark -
#pragma mark event handlers

- (void)handleGenericTap:(id)sender{
    [self.view endEditing:YES];
}

-(void) handlePan:(id)sender{
    
    // cast sender to uipangesturerecognizer
    UIPanGestureRecognizer *pgr = ( UIPanGestureRecognizer *)sender;

    BOOL registerDeltas = NO;
    // look at the pan gesture's internal state
    switch (pgr.state) {
            
        case UIGestureRecognizerStateBegan:
            [pgr setTranslation:CGPointZero inView:self.view];
            break;
            
        case UIGestureRecognizerStateEnded:
            [self resetAnimated:YES];
            break;
            
        case UIGestureRecognizerStateChanged:
            registerDeltas = YES;
            break;
            
        case UIGestureRecognizerStateCancelled:
        default:
            break;
    }

    if ( registerDeltas ){
        CGPoint delta = [pgr translationInView:self.view];
        [pgr setTranslation:CGPointZero inView:self.view];
        
        CGPoint vel = [pgr velocityInView:self.view];
        [self translateByX:delta.x withVelocity:vel.x];
        NSLog( @"dx:%f", delta.x );

    }
        
    
}

- (void)cancel:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}

-(void) translateByX: (CGFloat) offsetval withVelocity:(CGFloat)velocityval{
    CGFloat val = offsetval;
    self.velocity = velocityval;
    if (( self.containerView.frame.origin.x >= 0 && val > 0 ) ||
        ( self.containerView.frame.origin.x < -275 && val < 0 ))
    {
        val /= 4.0;
    }
    
    [UIView animateWithDuration:0
                          delay:0 
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.containerView.frame = CGRectOffset(self.containerView.frame, val, 0);
                     }
                     completion:nil
     ];
    
    NSLog(@"%f", val);
}

-(void) resetAnimated:(BOOL)anim{
    
    
    CGFloat val = self.containerView.frame.origin.x;
    CGFloat delta = self.containerView.frame.origin.x - self.originalOffsetX;
    CGFloat duration = 0.5;
    UIViewAnimationCurve curve = UIViewAnimationOptionCurveEaseOut;
    if ( val >= 0 ) {
        
        self.originalOffsetX = 0;
        
    } else if ( val <= -275 ) {
        
        self.originalOffsetX = -275;
        
    } else if (fabsf(self.velocity) > 10 ){
        duration = 275/fabsf(self.velocity);
        if ( duration < 0.3 ) duration = 0.3;
        if ( duration > 1 ) duration = 1;
        if ( self.velocity < 0 ){
            self.originalOffsetX = -275;
        }else {
            self.originalOffsetX = 0;            
        }
    } else {
        if  (fabsf(delta) < 275/2) {
            // do nothing, return to last known page
        } else {
            if ( delta < 0 ) {
                self.originalOffsetX = -275;
            }
            else if ( delta > 0 ) {
                self.originalOffsetX = 0;
            }
        }
    }
    [UIView animateWithDuration:duration
                          delay:0 
                        options:curve|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.containerView.frame = CGRectOffset(self.originalRect, self.originalOffsetX, 0.0f);
                     }
                     completion:nil
     ];
}

-(void)killAnimations{
    BOOL animationsEnabled = [UIView areAnimationsEnabled];
    
    // kill animations
    [UIView setAnimationsEnabled:NO];
    [self.containerView.layer removeAllAnimations];
    
    // restore the previous animation state
    [UIView setAnimationsEnabled:animationsEnabled];
    
}

#pragma mark -
#pragma mark Boilerplate

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
