//
//  VLMUtility.h
//  ThisVersusThat
//
//  Created by David Lu on 8/1/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"

@interface VLMUtility : NSObject
+ (void)processFacebookProfilePictureData:(NSData *)data;
+ (BOOL)userHasValidFacebookData:(PFUser *)user;
+ (BOOL)userHasProfilePictures:(PFUser *)user;

+ (void)likePhotoInBackground:(id)photo forPoll:(id)poll isLeft:(BOOL)isleftphoto block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)unlikePhotoInBackground:(id)photo forPoll:(id)poll isLeft:(BOOL)isleftphoto block:(void (^)(BOOL succeeded, NSError *error))completionBlock;

+ (NSString *)firstNameForDisplayName:(NSString *)displayName;

+ (void)followUserInBackground:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)followUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)followUsersEventually:(NSArray *)users block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)unfollowUserEventually:(PFUser *)user;
+ (void)unfollowUsersEventually:(NSArray *)users;
+ (void)unfollowUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock;

+ (void)sendFollowingPushNotification:(PFUser *)user;
+ (void)sendCommentPushNotification:(PFUser *)user Poll:(PFObject *)poll;

@end
