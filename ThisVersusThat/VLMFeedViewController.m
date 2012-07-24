//
//  VLMFeedViewController.m
//  ThisVersusThat
//
//  Created by David Lu on 7/17/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "VLMFeedViewController.h"
#import "VLMConstants.h"
#import "VLMCell.h"

@interface VLMFeedViewController ()

@end

@implementation VLMFeedViewController

@synthesize headerViewController;
@synthesize tableViewController;
@synthesize recognizedPanDirection;
@synthesize selectedCell;

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
    [self.view setAutoresizesSubviews:NO];
    [self.view setBackgroundColor:FEED_VIEW_BGCOLOR];
    
    // window dimensions
    CGFloat winh = [[UIScreen mainScreen] bounds].size.height;
    CGFloat winw = [[UIScreen mainScreen] bounds].size.width;
    CGRect cr = CGRectMake(0.0f, 0.0f, winw, winh - FOOTER_HEIGHT - STATUSBAR_HEIGHT);
    [self.view setFrame:cr];
    
    // - - - - - C O N T R O L L E R S - - - - - 
    
    // header view controller
    VLMFeedHeaderController *hc = [[VLMFeedHeaderController alloc] init];
    self.headerViewController = hc;
    
    // feed view controller
	VLMFeedTableViewController *fvc = [[VLMFeedTableViewController alloc] initWithHeader:hc];
    self.tableViewController = fvc;
    
    // add child views
    [self.view addSubview:hc.view];
    [self.view addSubview:fvc.view];
    
     // - - - - - - G E S T U R E - - - - - -
     
     // set up a pan gesture recognizer to distinguish horizontal pans from vertical ones
     UIPanGestureRecognizer *pgr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
     [pgr setDelegate:self];
     [self.view addGestureRecognizer:pgr];
     [self.view setExclusiveTouch:YES];
     
     // look for the factory installed pangesturerecognizer in uiscrollview
     // ask it to require our pan recognizer to fail before registering scrollview touches
     for (UIGestureRecognizer* gr in self.tableViewController.view.gestureRecognizers) {
         if ( [gr isKindOfClass:[UIPanGestureRecognizer class]] ){
             [gr requireGestureRecognizerToFail:pgr];
         }
     }
    
    // the default recognized state is unknown
    self.recognizedPanDirection = FUCKING_UNKNOWN;
}

// lightweight analysis on detected pan gestures
-(void) handlePan:(id)sender{
    
    // cast sender to uipangesturerecognizer
    UIPanGestureRecognizer *pgr = ( UIPanGestureRecognizer *)sender;
    
    // cast our uiview to uiscrollview
    UIScrollView *scrollview = (UIScrollView *) self.tableViewController.view;
    
    // look at the pan gesture's internal state
    switch (pgr.state) {
            
            // when the pan starts, make sure the scrollview is enabled
            // and reset the recognized pan direction to unknown
        case UIGestureRecognizerStateBegan:
            self.recognizedPanDirection = FUCKING_UNKNOWN;
            scrollview.scrollEnabled = YES;
            //NSLog(@"pan began");
            break;
            
            // when the pan ends, make sure we reset the state
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            
            if ( self.recognizedPanDirection == FUCKING_HORIZONTAL && selectedCell != nil)
            {
                // reset cell
                [(VLMCell *)selectedCell resetAnimated:YES];
            }
            self.recognizedPanDirection = FUCKING_UNKNOWN;
            scrollview.scrollEnabled = YES;
            //NSLog(@"pan ended");
            
            // do nothing otherwise
        default:
            break;
    }
    
    // pan direction unknown
    if ( self.recognizedPanDirection == FUCKING_UNKNOWN ) {
        
        // accumulated translation from start point
        CGPoint p = [pgr translationInView:self.view];
        
        // establish a deadzone of 50 x 24
        // this is a generous allowance for which we ignore wiggly movement
        CGSize deadzone = DEAD_ZONE;
        
        // vertical pans will cancel this gesture recognizer 
        // and let the scrollview's recognizer to take over
        if ( p.y > deadzone.height/2 || p.y < -deadzone.height/2 ) {
            
            // set the recognized direction
            self.recognizedPanDirection = FUCKING_VERTICAL;
            
            // find the pan gesture recognizer in the scrollview
            // and set its translation value to zero
            // this means that we scroll based on fresh data (not accumulated translation data)
            for (UIGestureRecognizer* gr in self.tableViewController.view.gestureRecognizers) {
                if ( [gr isKindOfClass:[UIPanGestureRecognizer class]] )
                {
                    UIPanGestureRecognizer *tvpgr = (UIPanGestureRecognizer *)gr;
                    [tvpgr setTranslation:CGPointZero inView:self.tableViewController.view];
                }
            }
            
            // cancel the recognizer and restart it for capturing the next pan
            // the current pan will continue, but the scrollview will handle it
            pgr.enabled = NO;
            pgr.enabled = YES;
            
            // a little debugging
            //NSLog(@"recognized vertical pan");
        } 
        else if ( p.x > deadzone.width/2 || p.x < -deadzone.width/2 ) {
            
            // horizontal pan resets the translation point 
            // so that translationinview: reports a delta from last event
            self.recognizedPanDirection = FUCKING_HORIZONTAL;
            [pgr setTranslation:CGPointZero inView:self.view];
            
            // disable the scrollview
            scrollview.scrollEnabled = NO;
            
            // extract the selected cell from the tableview 
            // (we're going to perform horizontal swipes on it)
            UITableView *tv = (UITableView *)self.tableViewController.view;
            CGPoint location = [pgr locationInView:tv];
            NSIndexPath *path = [tv indexPathForRowAtPoint:location];
            UITableViewCell *cell  = [tv cellForRowAtIndexPath:path];
            self.selectedCell = cell;
            //NSLog(@"recognized horizontal pan");
        }
    }
    
    // now handle horizontal pan, if one has been detected
    if ( self.recognizedPanDirection == FUCKING_HORIZONTAL ) {
        
        CGPoint delta = [pgr translationInView:self.view];
        [pgr setTranslation:CGPointZero inView:self.view];
        
        if ( self.selectedCell != nil ){
            VLMCell *c = (VLMCell *) self.selectedCell;
            CGPoint velocity = [pgr velocityInView:self.view];
            [c translateByX:delta.x withVelocity:velocity.x];
            
        }
        //NSLog( @"dx:%f", delta.x );
        
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    // currently, our gesture recognizer is always on for the feed
    // we probably want to turn off gesturerecco if we're not dealing with votable rows
    return YES;
}

// recognize gestures at same time as scrollview
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
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

-(void)updatelayout{
    [self.tableViewController updatelayout];
}
@end
