//
//  VLMCache.h
//  ThisVersusThat
//
//  Created by David Lu on 8/2/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"

@interface VLMCache : NSObject

+ (id)sharedCache;


- (void)clear;

- (void)setAttributesForPoll:(PFObject *)poll likersL:(NSArray *)likersLeft likersR:(NSArray *)likersRight commenters:(NSArray *)commenters isLikedByCurrentUserL:(BOOL)likedByCurrentUserLeft isLikedByCurrentUserR:(BOOL)likedByCurrentUserRight;

- (NSDictionary *)attributesForPoll:(PFObject *)poll;

- (void)setAttributes:(NSDictionary *)attributes forPoll:(PFObject *)poll;

- (void)setAttributes:(NSDictionary *)attributes forUser:(PFUser *)user;

- (NSString *)keyForPoll:(PFObject *)poll;

- (NSString *)keyForUser:(PFUser *)user;

- (NSNumber *)likeCountForPollLeft:(PFObject *)poll;

- (NSNumber *)likeCountForPollRight:(PFObject *)poll;

- (BOOL)isPollLikedByCurrentUserLeft:(PFObject *)poll;

- (BOOL)isPollLikedByCurrentUserRight:(PFObject *)poll;

- (NSDictionary *)attributesForPoll:(PFObject *)poll;
/*
- (void)setAttributesForPhoto:(PFObject *)photo likers:(NSArray *)likers commenters:(NSArray *)commenters likedByCurrentUser:(BOOL)likedByCurrentUser;


- (NSDictionary *)attributesForPhoto:(PFObject *)photo;

- (NSNumber *)likeCountForPhoto:(PFObject *)photo;
- (NSArray *)likersForPhoto:(PFObject *)photo;

- (NSNumber *)commentCountForPhoto:(PFObject *)photo;
- (NSArray *)commentersForPhoto:(PFObject *)photo;
- (void)setPhotoIsLikedByCurrentUser:(PFObject *)photo liked:(BOOL)liked;
- (BOOL)isPhotoLikedByCurrentUser:(PFObject *)photo;
- (void)incrementLikerCountForPhoto:(PFObject *)photo;
- (void)decrementLikerCountForPhoto:(PFObject *)photo;
- (void)incrementCommentCountForPhoto:(PFObject *)photo;
- (void)decrementCommentCountForPhoto:(PFObject *)photo;

- (NSDictionary *)attributesForUser:(PFUser *)user;
- (NSNumber *)photoCountForUser:(PFUser *)user;
- (BOOL)followStatusForUser:(PFUser *)user;
- (void)setPhotoCount:(NSNumber *)count user:(PFUser *)user;
- (void)setFollowStatus:(BOOL)following user:(PFUser *)user;

- (void)setFacebookFriends:(NSArray *)friends;
- (NSArray *)facebookFriends;
*/
@end
