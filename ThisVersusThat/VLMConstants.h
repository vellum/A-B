//
//  VLMConstants.h
//  ThisVersusThat
//
//  Created by David Lu on 7/17/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#ifndef ThisVersusThat_VLMConstants_h
#define ThisVersusThat_VLMConstants_h

#pragma mark -
#pragma mark Credentials

#define PARSE_APP_ID @"dzGqHDiGEsXfO2jTHGfJUZiceqLy1DAmASkMRpKd"
#define PARSE_CLIENT_KEY @"Wdwk2HHE57VMKhKOXkbKj2zqr1zmaa8cs0u2Nk4R"
#define PARSE_MASTER_KEY @"s1cIGrqWJx67cvx9o98uMB3HUCPR5Pf1pe3PTMhd"
#define FACEBOOK_APP_ID @"259605200818927"
#define FACEBOOK_APP_SECRET @"912dc9f297b731dc2e2ff86688147742"
#define FACEBOOK_APP_NAMESPACE @"thisversusthat"



#pragma mark -
#pragma mark Touch and Gesture

#define DEAD_ZONE CGSizeMake(40.0f, 20.0f)
#define FUCKING_UNKNOWN 0
#define FUCKING_VERTICAL 1
#define FUCKING_HORIZONTAL 2



#pragma mark -
#pragma mark Style and Layout

#define HEADER_CORNER_RADIUS 0.0f
#define STATUSBAR_HEIGHT 20.0f
#define HEADER_HEIGHT 60.0f
#define FOOTER_HEIGHT 50.0f
#define SECTION_HEADER_HEIGHT 80.0f

#define HEADER_TITLE_VERTICAL_OFFSET -4.0f
#define BAR_BUTTON_ITEM_VERTICAL_OFFSET -6.0f
#define NAVIGATION_HEADER_TITLE_SIZE 15.0f



#pragma mark -
#pragma mark Colors

#define DEBUG_BACKGROUND_GRID [UIColor colorWithPatternImage:[UIImage imageNamed:@"column-grid-white_gray@1x.png"]]
#define WINDOW_BGCOLOR [UIColor blackColor]
#define MAIN_VIEW_BGCOLOR [UIColor clearColor]
#define FEED_VIEW_BGCOLOR [UIColor clearColor]
#define FEED_HEADER_BGCOLOR [UIColor colorWithWhite:0.9f alpha:1.0f]
#define FOOTER_BGCOLOR [UIColor colorWithWhite:0.8f alpha:1.0f]
#define FEED_TABLEVIEW_BGCOLOR [UIColor colorWithPatternImage:[UIImage imageNamed:@"subtlenet2.png"]]
//#define FEED_TABLEVIEW_BGCOLOR [UIColor colorWithPatternImage:[UIImage imageNamed:@"column-grid-white_gray@1x.png"]]
#define FEED_SECTION_HEADER_BGCOLOR [UIColor whiteColor]

#define TEXT_COLOR [UIColor colorWithHue:0.87f saturation:0.0f brightness:0.12f alpha:1.0f]
#define FOOTER_TEXT_COLOR [UIColor colorWithWhite:0.2f alpha:1.0f]
#define DISABLED_TEXT_COLOR [UIColor colorWithWhite:0.1f alpha:0.25f]



#pragma mark -
#pragma mark Typefaces

#define SECTION_FONT_BOLD @"Helvetica-Bold"
#define SECTION_FONT_REGULAR @"AmericanTypewriter"
#define FOOTER_FONT @"Helvetica-Bold"
#define HEADER_TITLE_FONT @"Helvetica-Bold"
#define TEXTBUTTON_FONT @"Georgia-Italic"
#define NAVIGATION_HEADER @"Georgia-Italic"
#define PHOTO_LABEL @"AmericanTypewriter"

//#define HELVETICA @"Helvetica-Bold"
//#define TYPEWRITER @"AmericanTypewriter"
//#define GEORGIA @"Georgia-Italic"



#pragma mark -
#pragma mark Lorem Ipsum

// 4 line
#define LOREM_IPSUM @"American apparel squid tumblr single-origin coffee, shoreditch scenester put a bird on it VHS banksy jean shorts yr cliche. .........."

// 3 line
//#define LOREM_IPSUM @"American apparel squid tumblr single-origin coffee, shoreditch scenester put a bird on it VHS banksy "

// 2 line
//#define LOREM_IPSUM @"American apparel squid tumblr single-origin coffee, shoreditch scenester"

// 1 line
//#define LOREM_IPSUM @"American apparel squid tumblr"
//#define LOREM_IPSUM @"Which couch should I buy?"

#endif

