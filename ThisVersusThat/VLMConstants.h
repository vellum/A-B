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
#define VOTE_THRESHOLD_X 125

#define FUCKING_UNKNOWN 0
#define FUCKING_VERTICAL 1
#define FUCKING_HORIZONTAL 2


#pragma mark -
#pragma mark Style and Layout

#define HEADER_CORNER_RADIUS 0.0f
#define STATUSBAR_HEIGHT 20.0f
#define HEADER_HEIGHT 50.0f
#define FOOTER_HEIGHT 50.0f
#define SECTION_HEADER_HEIGHT 80.0f

#define BORDER_COLOR [UIColor colorWithHue:313/360 saturation:0.12 brightness:0.59 alpha:.15]
#define BORDER_WIDTH 1.0f

#define HEADER_TEXT_COLOR [UIColor colorWithWhite:1.0 alpha:0.9]

#define BACKGROUND_COLOR [UIColor colorWithPatternImage:[UIImage imageNamed:@"subtlenet2.png"]]
//#define BACKGROUND_COLOR [UIColor colorWithPatternImage:[UIImage imageNamed:@"column-grid-white_gray@1x.png"]]
#define HEAD_BACKGROUND [UIColor colorWithPatternImage:[UIImage imageNamed:@"txture.png"]]

#define TEXT_COLOR [UIColor colorWithHue:0.87f saturation:0 brightness:0.12 alpha:1.0]
#define TEXT_MIDCOLOR [UIColor colorWithHue:0.87f saturation:0.12f brightness:0.2 alpha:1.0]
#define DISABLED_TEXT_COLOR [UIColor colorWithWhite:0.1f alpha:0.25f]

#define FOOTER_TEXT_COLOR [UIColor colorWithWhite:0.2f alpha:1.0f]

#pragma mark -
#pragma mark Typefaces

#define HELVETICA @"Helvetica-Bold"
#define TYPEWRITER @"AmericanTypewriter"
#define GEORGIA @"Georgia-Italic"

//#define LOREM_IPSUM @"American apparel squid tumblr single-origin coffee, shoreditch scenester put a bird on it VHS banksy jean shorts yr cliche. .........."
//#define LOREM_IPSUM @"American apparel squid tumblr single-origin coffee, shoreditch scenester"
//#define LOREM_IPSUM @"American apparel squid tumblr"
#define LOREM_IPSUM @"Which couch should I buy?"

#endif

