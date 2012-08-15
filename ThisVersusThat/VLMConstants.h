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

#define PARSE_APP_ID @"7Maq4hXcHLO4m1ywRQeLnxoxxlQnPimxUlvn7skb"
#define PARSE_CLIENT_KEY @"63FEATKxAda51PXpBcuJdCeWy4BG3YcOLeT64Lan"
#define PARSE_MASTER_KEY @"MDBbOirQ5I7Ut5Olz5NCY0CI2xLcm7F5SskL9yzi"
#define FACEBOOK_APP_ID @"193845217412320"
#define FACEBOOK_APP_SECRET @"b2271424ca6ba22e500956bbc4f91704"
#define FACEBOOK_APP_NAMESPACE @""

#define POLL_CLASS_KEY @"Poll"
#define POLL_QUESTION_KEY @"Question"
#define POLL_LEFT_THUMB_KEY @"LeftThumbnail"
#define POLL_LEFT_PHOTO_KEY @"LeftPhoto"
#define POLL_LEFT_PHOTO_CAPTION_KEY @"LeftCaption"
#define POLL_RIGHT_THUMB_KEY @"RightThumbnail"
#define POLL_RIGHT_PHOTO_KEY @"RightPhoto"
#define POLL_RIGHT_PHOTO_CAPTION_KEY @"RightCaption"
#define POLL_USER_KEY @"User"


// Field keys
#define kPAPUserDisplayNameKey @"displayName"
#define kPAPUserFacebookIDKey @"facebookId"
#define kPAPUserPhotoIDKey @"photoId"
#define kPAPUserProfilePicSmallKey @"profilePictureSmall"
#define kPAPUserProfilePicMediumKey @"profilePictureMedium"
#define kPAPUserAlreadyAutoFollowedFacebookFriendsKey @"userAlreadyAutoFollowedFacebookFriends"
#define kPAPUserPrivateChannelKey @"channel"

// Class key
#define kPAPActivityClassKey @"Activity"

// Field keys
#define kPAPActivityTypeKey @"type"
#define kPAPActivityFromUserKey @"fromUser"
#define kPAPActivityToUserKey @"toUser"
#define kPAPActivityContentKey @"content"
#define kPAPActivityPhotoKey @"photo"

// Type values
#define kPAPActivityTypeLike @"like"
#define kPAPActivityTypeFollow @"follow"
#define kPAPActivityTypeComment @"comment"
#define kPAPActivityTypeJoined @"joined"

#pragma mark -
#pragma mark Touch and Gesture

#define DEAD_ZONE CGSizeMake(50.0f, 20.0f)
#define FUCKING_UNKNOWN 0
#define FUCKING_VERTICAL 1
#define FUCKING_HORIZONTAL 2



#pragma mark -
#pragma mark Style and Layout

#define HEADER_CORNER_RADIUS 0.0f
#define STATUSBAR_HEIGHT 20.0f
#define HEADER_HEIGHT 60.0f
#define FOOTER_HEIGHT 60.0f
#define SECTION_HEADER_HEIGHT 80.0f

#define HEADER_TITLE_VERTICAL_OFFSET -4.0f
#define BAR_BUTTON_ITEM_VERTICAL_OFFSET -6.0f

#define NAVIGATION_HEADER_TITLE_SIZE 15.0f


#pragma mark -
#pragma mark Colors

#define DEBUG_BACKGROUND_GRID [UIColor colorWithPatternImage:[UIImage imageNamed:@"debuggrid.png"]]
#define BLACK_LINEN [UIColor colorWithPatternImage:[UIImage imageNamed:@"skewed_print.png"]]

#define WINDOW_BGCOLOR [UIColor colorWithPatternImage:[UIImage imageNamed:@"subtlenet2.png"]]
#define MAIN_VIEW_BGCOLOR [UIColor clearColor]
#define FEED_VIEW_BGCOLOR [UIColor clearColor]
#define FEED_HEADER_BGCOLOR [UIColor colorWithWhite:0.9f alpha:1.0f]
#define NAVIGATION_HEADER_BACKGROUND_IMAGE [UIImage imageNamed:@"gray_header_background.png"]
#define FOOTER_BGCOLOR [UIColor colorWithWhite:0.9f alpha:1.0f]
#define FEED_TABLEVIEW_BGCOLOR [UIColor colorWithPatternImage:[UIImage imageNamed:@"subtlenet2.png"]]
#define FEED_SECTION_HEADER_BGCOLOR [UIColor whiteColor]

#define TEXT_COLOR [UIColor colorWithHue:0.87f saturation:0.0f brightness:0.12f alpha:1.0f]
#define FOOTER_TEXT_COLOR [UIColor colorWithWhite:0.2f alpha:1.0f]
#define DISABLED_TEXT_COLOR [UIColor colorWithWhite:0.1f alpha:0.25f]



#pragma mark -
#pragma mark Typefaces

#define HEADER_TITLE_FONT @"AmericanTypewriter"
#define NAVIGATION_HEADER @"AmericanTypewriter"
#define SECTION_FONT_BOLD @"AmericanTypewriter-Bold"
#define SECTION_FONT_REGULAR @"AmericanTypewriter"
#define FOOTER_FONT @"AmericanTypewriter"
#define TEXTBUTTON_FONT @"HelveticaNeue-Bold"
#define PHOTO_LABEL @"AmericanTypewriter"





/*
#define SECTION_FONT_BOLD @"Helvetica-Bold"
#define SECTION_FONT_REGULAR @"AmericanTypewriter"
#define FOOTER_FONT @"Helvetica-Bold"
//#define HEADER_TITLE_FONT @"Helvetica-Bold"
#define HEADER_TITLE_FONT @"AmericanTypewriter"
#define TEXTBUTTON_FONT @"Georgia-Italic"
#define NAVIGATION_HEADER @"Georgia-Italic"
#define PHOTO_LABEL @"AmericanTypewriter"
*/

//#define HELVETICA @"Helvetica-Bold"
//#define TYPEWRITER @"AmericanTypewriter"
//#define GEORGIA @"Georgia-Italic"



#pragma mark -
#pragma mark Lorem Ipsum

// 4 line
//#define LOREM_IPSUM @"American apparel squid tumblr single-origin coffee, shoreditch scenester put a bird on it VHS banksy jean shorts yr cliche. .........."

// 3 line
//#define LOREM_IPSUM @"American apparel squid tumblr single-origin coffee, shoreditch scenester put a bird on it VHS banksy "

// 2 line
//#define LOREM_IPSUM @"American apparel squid tumblr single-origin coffee, shoreditch scenester"

// 1 line
//#define LOREM_IPSUM @"American apparel squid tumblr"
#define LOREM_IPSUM @"Which couch should I buy?"

#endif

