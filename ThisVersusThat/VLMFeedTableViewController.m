//
//  VLMFeedTableViewController.m
//  ThisVersusThat
//
//  Created by David Lu on 7/17/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "VLMFeedTableViewController.h"
#import "VLMConstants.h"
#import "AppDelegate.h"
#import "VLMSectionView.h"
#import "VLMCell.h"
#import "Parse/Parse.h"

@implementation VLMFeedTableViewController

@synthesize headerViewController;
@synthesize contentRect;
@synthesize contentOffsetY;

-(id) initWithHeader:(VLMFeedHeaderController *) headerController {
    self = [super initWithStyle:UITableViewStylePlain];
    if ( headerController ) {
        self.headerViewController = headerController;
    }
    return self;
}

- (void)viewDidLoad {
    CGFloat winh = [[UIScreen mainScreen] bounds].size.height;
    CGFloat winw = [[UIScreen mainScreen] bounds].size.width;
    CGFloat footerh = (![PFUser currentUser]) ? FOOTER_HEIGHT : 0;
    CGRect cr = CGRectMake(0.0f, 0.0f, winw, winh-FOOTER_HEIGHT-footerh);

    [self setContentRect:cr];
    [self setContentOffsetY:HEADER_HEIGHT];

    [self.view setAutoresizesSubviews:NO];
    [self.view setBackgroundColor:FEED_TABLEVIEW_BGCOLOR];
    [self.view setFrame: CGRectOffset(self.contentRect, 0.0f, self.contentOffsetY)];
    
    UITableView *tv = (UITableView *)self.view;
    [tv setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tv setDelegate:self];
}

#pragma mark -
#pragma mark tableview data

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // test case: 25 elements, each with one section
	return 25;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // test case: 25 elements, each with one section
    NSString *s = [NSString stringWithFormat:@"%d", section];
	return s;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // the very first section is a special case:
    // it contains an additional variable height cell that we use for our sticky header hack
    if ( section == 0 ) return 2;
    
    // in all other cases, there is one row per section
	return 1;
}

#pragma mark -
#pragma mark tableview heights

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    NSString *text = LOREM_IPSUM;
     CGSize expectedLabelSize = [text sizeWithFont:[UIFont fontWithName:SECTION_FONT_REGULAR size:14] constrainedToSize:CGSizeMake(275, 120) lineBreakMode:UILineBreakModeWordWrap];
    CGFloat h = expectedLabelSize.height + 37.0f;

    // 1 line details
    if ( h < 47.0f ) return 47.0f;   
    
    // 4 line
    if ( h > 14*7 ) return 14*7.5;
    
    // 3 line
    if ( h > 14*6 ) return 14*6.5;
    
    // 2 line
    if ( h > 14*4 ) return 14*5;
    
    return h;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger rownum = [indexPath row];
    NSInteger sectionnum = [indexPath section];

    // for the very first row in the very first section, compute a dynamic height depending
    // on the scroll position
    if ( sectionnum == 0 && rownum == 0 ) {
    
        CGFloat scrollval = tableView.contentOffset.y;
        if ( scrollval < 0 ) scrollval = 0.0f;
        if ( scrollval > HEADER_HEIGHT ) scrollval = HEADER_HEIGHT;
        return scrollval;
    }
    
    // otherwise, row heights are fixed
    return 321;
}

#pragma mark -
#pragma mark tableview sections and rows

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	// identifier
	static NSString *FeedCellIdentifier = @"PollCell";
	
	// get an unused cell from existing pool of tableviewcells
	VLMCell *cell = [tableView dequeueReusableCellWithIdentifier:FeedCellIdentifier];
	
	// if no cell is available create a new one
	if (cell == nil) {
        cell = [[VLMCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FeedCellIdentifier];
	}

    if ( indexPath.section == 0 && indexPath.row == 0 ){
        cell.contentView.hidden = YES;
    } else {
        cell.contentView.hidden = NO;
    }

	return cell;
}

            // for reference:
            // http://stackoverflow.com/questions/1349571/how-to-customize-tableview-section-view-iphone

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CGFloat winw = [[UIScreen mainScreen] bounds].size.width;
    VLMSectionView *customview = [[VLMSectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, winw, 60.0f) andUserName:@"erdogan apparat" andQuestion:LOREM_IPSUM];
    return customview;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}


/*
 loose approximation of tableheader that scrolls out of the way
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    // get the scroll position of the tableview
    CGFloat lookupY = scrollView.contentOffset.y;
    
    // invert the scroll position and use it as a y offset for positioning 
    // our fake header
    CGFloat headerOffsetY = -lookupY;
    if (headerOffsetY > 0 ) headerOffsetY = 0;
    if (headerOffsetY < -HEADER_HEIGHT ) headerOffsetY = -HEADER_HEIGHT;
    [self.headerViewController pushVerticallyBy:headerOffsetY];
    
    // now compute a y offset to apply to the scrollview
    // ( we're pushing this up where the header used to be
    //   or vice versa )
    CGFloat tvOffsetY = HEADER_HEIGHT + headerOffsetY;
    if ( tvOffsetY != self.contentOffsetY )
    {
        //NSLog(@"%f", tvOffsetY);
        CGFloat winh = [[UIScreen mainScreen] bounds].size.height;
        CGFloat winw = [[UIScreen mainScreen] bounds].size.width;

        CGFloat footerh = (![PFUser currentUser]) ? FOOTER_HEIGHT : 0;
        [self.view setFrame: CGRectMake(0, tvOffsetY, winw, winh-tvOffsetY-STATUSBAR_HEIGHT - footerh)];

        // cast scrollview to a tableview
        UITableView *tv = (UITableView *)scrollView;
        
        // store this offset in an ivar
        self.contentOffsetY = tvOffsetY;
        
        // UITableView animates height changes by default
        // override that and make sure we don't animate
        
        // preserve the previous animation state
        BOOL animationsEnabled = [UIView areAnimationsEnabled];
        
        // kill animations
        [UIView setAnimationsEnabled:NO];
        
        // trigger a row height computation on our rows
        [tv beginUpdates];
        [tv endUpdates];
        
        // alternatively we can do
        //[tv reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        
        // restore the previous animation state
        [UIView setAnimationsEnabled:animationsEnabled];

        /*
        //NSLog(@"%f", tvOffsetY);
        if ( lookupY < HEADER_HEIGHT / 2 )
        {
            if( [UIApplication sharedApplication].statusBarHidden ){
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
            }
        }
        else {
            if( ![UIApplication sharedApplication].statusBarHidden ){
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
            }
            
        }
         */
    }
}
-(void)updatelayout{
    CGFloat winh = [[UIScreen mainScreen] bounds].size.height;
    CGFloat winw = [[UIScreen mainScreen] bounds].size.width;
    CGFloat y = self.view.frame.origin.y;
    [self.view setFrame: CGRectMake(0, y, winw, winh-y-STATUSBAR_HEIGHT)];
}

@end
