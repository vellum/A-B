//
//  VLMUtility.m
//  ThisVersusThat
//
//  Created by David Lu on 8/1/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "VLMUtility.h"
#import "Parse/Parse.h"
#import "UIImage+ResizeAdditions.h"
#import "UIImage+RoundedCornerAdditions.h"
#import "UIImage+AlphaAdditions.h"
#import "VLMConstants.h"
#import "VLMCache.h"

@implementation VLMUtility

+ (void)processFacebookProfilePictureData:(NSData *)newProfilePictureData {
    if (newProfilePictureData.length == 0) {
        NSLog(@"Profile picture did not download successfully.");
        return;
    }
    
    // The user's Facebook profile picture is cached to disk. Check if the cached profile picture data matches the incoming profile picture. If it does, avoid uploading this data to Parse.
    
    NSURL *cachesDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject]; // iOS Caches directory
    
    NSURL *profilePictureCacheURL = [cachesDirectoryURL URLByAppendingPathComponent:@"FacebookProfilePicture.jpg"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[profilePictureCacheURL path]]) {
        // We have a cached Facebook profile picture
        
        NSData *oldProfilePictureData = [NSData dataWithContentsOfFile:[profilePictureCacheURL path]];
        
        if ([oldProfilePictureData isEqualToData:newProfilePictureData]) {
            NSLog(@"Cached profile picture matches incoming profile picture. Will not update.");
            return;
        }
    }
    
    BOOL cachedToDisk = [[NSFileManager defaultManager] createFileAtPath:[profilePictureCacheURL path] contents:newProfilePictureData attributes:nil];
    NSLog(@"Wrote profile picture to disk cache: %d", cachedToDisk);
    
    UIImage *image = [UIImage imageWithData:newProfilePictureData];
    /*
    NSData *imagedata = UIImageJPEGRepresentation(image, kCGInterpolationMedium);
    NSLog(@"image length: %d", imagedata.length);
    */
    UIImage *mediumImage = [image thumbnailImage:280 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
    UIImage *smallRoundedImage = [image thumbnailImage:64 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationLow];
    
    NSData *mediumImageData = UIImageJPEGRepresentation(mediumImage, 0.5); // using JPEG for larger pictures
    NSData *smallRoundedImageData = UIImagePNGRepresentation(smallRoundedImage);
    
    
    
    if (mediumImageData.length > 0) {
        NSLog(@"Uploading Medium Profile Picture");
        PFFile *fileMediumImage = [PFFile fileWithData:mediumImageData];
        [fileMediumImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                NSLog(@"Uploaded Medium Profile Picture");
                [[PFUser currentUser] setObject:fileMediumImage forKey:@"profilePicMedium"];
                [[PFUser currentUser] saveEventually];
            }
            else{
                NSLog(@"error uploading: %@", [error description]);
            }
        }];
    }else{
        NSLog(@"medium image length: 0");
    }
    
    if (smallRoundedImageData.length > 0) {
        NSLog(@"Uploading Profile Picture Thumbnail");
        PFFile *fileSmallRoundedImage = [PFFile fileWithData:smallRoundedImageData];
        [fileSmallRoundedImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                NSLog(@"Uploaded Profile Picture Thumbnail");
                [[PFUser currentUser] setObject:fileSmallRoundedImage forKey:@"profilePicSmall"];    
                [[PFUser currentUser] saveEventually];
            }
            else{
                NSLog(@"error uploading: %@", [error description]);
            }
        }];
    }else{
        NSLog(@"medium image length: 0");
    }
}

+ (BOOL)userHasValidFacebookData:(PFUser *)user {
    NSString *facebookId = [user objectForKey:kPAPUserFacebookIDKey];
    return (facebookId && facebookId.length > 0);
}

+ (BOOL)userHasProfilePictures:(PFUser *)user {
    PFFile *profilePictureMedium = [user objectForKey:kPAPUserProfilePicMediumKey];
    PFFile *profilePictureSmall = [user objectForKey:kPAPUserProfilePicSmallKey];
    return (profilePictureMedium && profilePictureSmall);
}

+ (void)likePhotoInBackground:(id)photo forPoll:(id)poll isLeft:(BOOL)isphotoleft block:(void (^)(BOOL succeeded, NSError *error))completionBlock{
    
    PFQuery *queryPollExists = [PFQuery queryWithClassName:@"Poll"];
    PFObject *p = (PFObject *)poll;
    [queryPollExists whereKey:@"objectId" equalTo:p.objectId];
    [queryPollExists countObjectsInBackgroundWithBlock:^(int number, NSError *error){
        NSLog(@"count polls matching id: %d", number) ;
        if ( number == 0 && completionBlock) { 
            completionBlock( NO, [NSError errorWithDomain:@"cc.vellum" code:-1000 userInfo:nil] );
            NSArray *keys = [NSArray arrayWithObjects:@"pollid", @"ownerid", nil];
            NSArray *vals = [NSArray arrayWithObjects:p.objectId, [poll objectForKey:@"User"], nil];
            NSDictionary *payload = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
            NSMutableArray *empty = [NSMutableArray arrayWithCapacity:0];
            [[VLMCache sharedCache] setAttributesForPoll:p likersL:empty likersR:empty commenters:empty isLikedByCurrentUserL:NO isLikedByCurrentUserR:NO isCommentedByCurrentUser:NO isDeleted:YES];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"cc.vellum.thisversusthat.notification.userdiddeletepoll" object:payload];

        }
        if ( number == 1 ){
            PFQuery *queryExistingLikes = [PFQuery queryWithClassName:@"Activity"];
            [queryExistingLikes whereKey:@"Poll" equalTo:poll];
            [queryExistingLikes whereKey:@"Type" equalTo:@"like"];
            [queryExistingLikes whereKey:@"FromUser" equalTo:[PFUser currentUser]];
            [queryExistingLikes setCachePolicy:kPFCachePolicyNetworkOnly];
            
            [queryExistingLikes findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
                if (!error) {
                    for (PFObject *activity in activities) {
                        [activity delete];
                    }
                }
                else {
                    NSLog(@"error here");
                    if ( completionBlock ) {
                        completionBlock(NO, error);
                    }
                }
                
                // proceed to creating new like
                PFObject *likeActivity = [PFObject objectWithClassName:@"Activity"];
                [likeActivity setObject:@"like" forKey:@"Type"];
                [likeActivity setObject:[PFUser currentUser] forKey:@"FromUser"];
                [likeActivity setObject:[poll objectForKey:@"User"] forKey:@"ToUser"];
                [likeActivity setObject:photo forKey:@"Photo"];
                [likeActivity setObject:poll forKey:@"Poll"];
                
                PFACL *likeACL = [PFACL ACLWithUser:[PFUser currentUser]];
                [likeACL setPublicReadAccess:YES];
                [likeACL setWriteAccess:YES forUser:[poll objectForKey:@"User"]]; // important! allows poll owner to delete the poll and remove activity
                likeActivity.ACL = likeACL;
                
                PFObject *theleftphoto = [poll objectForKey:@"PhotoLeft"];
                NSString *theleftphotoobjectid = [theleftphoto objectId];
                
                [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (completionBlock) {
                        completionBlock(succeeded,error);
                        
                        PFCachePolicy poly = kPFCachePolicyNetworkOnly;
                        PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
                        [query whereKey:@"Poll" equalTo:poll];
                        [query includeKey:@"FromUser"];
                        [query includeKey:@"ToUser"];
                        [query setCachePolicy:poly];
                        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            @synchronized(self){
                                
                                if ( !error ){
                                    NSMutableArray *likersL = [NSMutableArray array];
                                    NSMutableArray *likersR = [NSMutableArray array];
                                    NSMutableArray *comments = [NSMutableArray array];
                                    BOOL isLikedByCurrentUserL = NO;
                                    BOOL isLikedByCurrentUserR = NO;
                                    BOOL isCommentedByCurrentUser = NO;
                                    
                                    //NSLog(@"%d activities",[objects count]);
                                    
                                    // loop through these mixed results
                                    for (PFObject *activity in objects) {
                                        
                                        //NSLog(@"here");
                                        NSString *userID = [[activity objectForKey:@"FromUser"] objectId];
                                        NSString *cur = [[PFUser currentUser] objectId];
                                        // NSLog(@"%@ / %@", userID, cur);
                                        
                                        // test for likes
                                        if ([[activity objectForKey:@"Type"] isEqualToString:@"like"]){
                                            
                                            // left photo likes
                                            if ( [theleftphotoobjectid isEqualToString:[[activity objectForKey:@"Photo"] objectId]] ){
                                                // add userid to array
                                                [likersL addObject:[activity objectForKey:@"FromUser"]];
                                                
                                                if ( [userID isEqualToString:[[PFUser currentUser] objectId]] ){
                                                    isLikedByCurrentUserL = YES;
                                                }
                                                
                                                // right photo likes
                                            } else {
                                                
                                                // add userid to array
                                                [likersR addObject:[activity objectForKey:@"FromUser"]];
                                                
                                                if ( [userID isEqualToString: cur] ){
                                                    isLikedByCurrentUserR = YES;
                                                }
                                                
                                            }
                                            
                                            
                                            // test for comments    
                                        } else if ([[activity objectForKey:@"Type"] isEqualToString:@"comment"]){
                                            NSLog(@"adding a comment");
                                            [comments addObject:activity];
                                            
                                            if ( [userID isEqualToString:cur] ){
                                                isCommentedByCurrentUser = YES;
                                            }
                                        }
                                        
                                    }
                                    
                                    NSLog(@"[likersL: %d, likersR: %d]", likersL.count, likersR.count);
                                    [[VLMCache sharedCache] setAttributesForPoll:poll likersL:likersL likersR:likersR commenters:comments isLikedByCurrentUserL:isLikedByCurrentUserL isLikedByCurrentUserR:isLikedByCurrentUserR isCommentedByCurrentUser:isCommentedByCurrentUser isDeleted:NO];

                                    NSArray *keys = [NSArray arrayWithObjects:@"pollid", @"ownerid", nil];
                                    NSArray *vals = [NSArray arrayWithObjects:p.objectId, [poll objectForKey:@"User"], nil];
                                    NSDictionary *payload = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
                                    
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"cc.vellum.thisversusthat.notification.userdidlikeorunlike" object:payload];
                                }
                                if ( succeeded ){
                                    [VLMUtility sendLikePushNotification:[poll objectForKey:@"User"] Poll:poll];
                                }
                            
                            }
                        }];
                    }
                }];
            }];
        }
    }];
    
}

+ (void)unlikePhotoInBackground:(id)photo forPoll:(id)poll isLeft:(BOOL)isleftphoto block:(void (^)(BOOL succeeded, NSError *error))completionBlock{

    PFQuery *queryPollExists = [PFQuery queryWithClassName:@"Poll"];
    PFObject *p = (PFObject *)poll;
    
    [queryPollExists whereKey:@"objectId" equalTo:p.objectId];
    [queryPollExists countObjectsInBackgroundWithBlock:^(int number, NSError *error){
        NSLog(@"count polls matching id: %d", number) ;
        if ( number == 0 && completionBlock) { 
            
            completionBlock( NO, [NSError errorWithDomain:@"cc.vellum" code:-1000 userInfo:nil] );

            NSMutableArray *empty = [NSMutableArray arrayWithCapacity:0];
            [[VLMCache sharedCache] setAttributesForPoll:p likersL:empty likersR:empty commenters:empty isLikedByCurrentUserL:NO isLikedByCurrentUserR:NO isCommentedByCurrentUser:NO isDeleted:YES];

            
            NSArray *keys = [NSArray arrayWithObjects:@"pollid", @"ownerid", nil];
            NSArray *vals = [NSArray arrayWithObjects:p.objectId, [poll objectForKey:@"User"], nil];
            NSDictionary *payload = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"cc.vellum.thisversusthat.notification.userdiddeletepoll" object:payload];

        }
        if ( number == 1 ){
            PFQuery *queryExistingLikes = [PFQuery queryWithClassName:@"Activity"];
            [queryExistingLikes whereKey:@"Photo" equalTo:photo];
            [queryExistingLikes whereKey:@"Type" equalTo:@"like"];
            [queryExistingLikes whereKey:@"FromUser" equalTo:[PFUser currentUser]];
            [queryExistingLikes setCachePolicy:kPFCachePolicyNetworkOnly];
            [queryExistingLikes findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
                if (!error) {
                    for (PFObject *activity in activities) {
                        [activity delete];
                    }
                    
                    if (completionBlock) {
                        completionBlock(YES,nil);
                        
                        PFCachePolicy poly = kPFCachePolicyNetworkOnly;
                        PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
                        [query whereKey:@"Poll" equalTo:poll];
                        [query setCachePolicy:poly];
                        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            @synchronized(self){
                                
                                if ( !error ){
                                    NSMutableArray *likersL = [NSMutableArray array];
                                    NSMutableArray *likersR = [NSMutableArray array];
                                    NSMutableArray *comments = [NSMutableArray array];
                                    BOOL isLikedByCurrentUserL = NO;
                                    BOOL isLikedByCurrentUserR = NO;
                                    BOOL isCommentedByCurrentUser = NO;
                                    
                                    PFObject *theleftphoto = [poll objectForKey:@"PhotoLeft"];
                                    NSString *theleftphotoobjectid = [theleftphoto objectId];
                                    
                                    
                                    //NSLog(@"%d activities",[objects count]);
                                    
                                    // loop through these mixed results
                                    for (PFObject *activity in objects) {
                                        
                                        //NSLog(@"here");
                                        NSString *userID = [[activity objectForKey:@"FromUser"] objectId];
                                        NSString *cur = [[PFUser currentUser] objectId];
                                        // NSLog(@"%@ / %@", userID, cur);
                                        
                                        // test for likes
                                        if ([[activity objectForKey:@"Type"] isEqualToString:@"like"]){
                                            
                                            // left photo likes
                                            if ( [theleftphotoobjectid isEqualToString:[[activity objectForKey:@"Photo"] objectId]] ){
                                                // add userid to array
                                                [likersL addObject:[activity objectForKey:@"FromUser"]];
                                                
                                                if ( [userID isEqualToString:[[PFUser currentUser] objectId]] ){
                                                    isLikedByCurrentUserL = YES;
                                                }
                                                
                                                // right photo likes
                                            } else {
                                                
                                                // add userid to array
                                                [likersR addObject:[activity objectForKey:@"FromUser"]];
                                                
                                                if ( [userID isEqualToString: cur] ){
                                                    isLikedByCurrentUserR = YES;
                                                }
                                                
                                            }
                                            
                                            
                                            // test for comments    
                                        } else if ([[activity objectForKey:@"Type"] isEqualToString:@"comment"]){
                                            NSLog(@"adding a comment");
                                            [comments addObject:activity];
                                            
                                            if ( [userID isEqualToString:cur] ){
                                                isCommentedByCurrentUser = YES;
                                            }
                                        }
                                        
                                    }
                                    
                                    
                                    [[VLMCache sharedCache] setAttributesForPoll:poll likersL:likersL likersR:likersR commenters:comments isLikedByCurrentUserL:isLikedByCurrentUserL isLikedByCurrentUserR:isLikedByCurrentUserR isCommentedByCurrentUser:isCommentedByCurrentUser isDeleted:NO];
                                    
                                    
                                    NSArray *keys = [NSArray arrayWithObjects:@"pollid", @"ownerid", nil];
                                    NSArray *vals = [NSArray arrayWithObjects:p.objectId, [poll objectForKey:@"User"], nil];
                                    NSDictionary *payload = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
                                    
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"cc.vellum.thisversusthat.notification.userdidlikeorunlike" object:payload];                                }
                                
                                
                            }
                        }];
                        
                    }
                } else {
                    if (completionBlock) {
                        completionBlock(NO,error);
                    }
                }
            }];  
        }
    }];
    

}


#pragma mark Display Name

+ (NSString *)firstNameForDisplayName:(NSString *)displayName {
    if (!displayName || displayName.length == 0) {
        return @"Someone";
    }
    
    NSArray *displayNameComponents = [displayName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *firstName = [displayNameComponents objectAtIndex:0];
    if (firstName.length > 100) {
        // truncate to 100 so that it fits in a Push payload
        firstName = [firstName substringToIndex:100];
    }
    return firstName;
}


#pragma mark User Following

+ (void)followUserInBackground:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
    //    return;
    }
    
    PFObject *followActivity = [PFObject objectWithClassName:@"Activity"];
    [followActivity setObject:[PFUser currentUser] forKey:@"FromUser"];
    [followActivity setObject:user forKey:@"ToUser"];
    [followActivity setObject:@"follow" forKey:@"Type"];
    
    PFACL *followACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [followACL setPublicReadAccess:YES];
    [followACL setWriteAccess:YES forUser:user];
    followActivity.ACL = followACL;
    
    [followActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        // roll back the change in the cache (cache will issue an nsnotification to update any views looking at this)
        if ( !succeeded || error ){
            [[VLMCache sharedCache] setFollowStatus:NO user:user];
        }

        if (completionBlock) {
            completionBlock(succeeded, error);
        }

        if (succeeded) {
            [VLMUtility sendFollowingPushNotification:user];
        }
    }];
    [[VLMCache sharedCache] setFollowStatus:YES user:user];
}

+ (void)followUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
    //    return;
    }
    
    PFObject *followActivity = [PFObject objectWithClassName:@"Activity"];
    [followActivity setObject:[PFUser currentUser] forKey:@"FromUser"];
    [followActivity setObject:user forKey:@"ToUser"];
    [followActivity setObject:@"follow" forKey:@"Type"];
    
    PFACL *followACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [followACL setPublicReadAccess:YES];
    [followACL setWriteAccess:YES forUser:user];
    followActivity.ACL = followACL;
    
    [followActivity saveEventually:^(BOOL succeeded, NSError *error) {// roll back the change in the cache (cache will issue an nsnotification to update any views looking at this)
        if ( !succeeded || error ){
            [[VLMCache sharedCache] setFollowStatus:NO user:user];
        }
        
        if (completionBlock) {
            completionBlock(succeeded, error);
        }
        
        if (succeeded) {
            [VLMUtility sendFollowingPushNotification:user];
        }
    }];
    [[VLMCache sharedCache] setFollowStatus:YES user:user];
}

+ (void)followUsersEventually:(NSArray *)users block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    for (PFUser *user in users) {
        [VLMUtility followUserEventually:user block:completionBlock];
        [[VLMCache sharedCache] setFollowStatus:YES user:user];
    }
}

+ (void)unfollowUserEventually:(PFUser *)user {
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:@"FromUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"ToUser" equalTo:user];
    [query whereKey:@"Type" equalTo:@"follow"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *followActivities, NSError *error) {
        // While normally there should only be one follow activity returned, we can't guarantee that.
        
        if (!error) {
            for (PFObject *followActivity in followActivities) {
                [followActivity deleteEventually];
            }
        } else {
            [[VLMCache sharedCache] setFollowStatus:YES user:user];
        }
    }];
    [[VLMCache sharedCache] setFollowStatus:NO user:user];
}

+ (void)unfollowUsersEventually:(NSArray *)users {
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:@"FromUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"ToUser" containedIn:users];
    [query whereKey:@"Type" equalTo:@"follow"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        for (PFObject *activity in activities) {
            [activity deleteEventually];
        }
    }];
    for (PFUser *user in users) {
        [[VLMCache sharedCache] setFollowStatus:NO user:user];
    }
}

+ (void)unfollowUserEventually:(PFUser *)user  block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:@"FromUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"ToUser" equalTo:user];
    [query whereKey:@"Type" equalTo:@"follow"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *followActivities, NSError *error) {
        // While normally there should only be one follow activity returned, we can't guarantee that.
        
        if (!error) {
            for (PFObject *followActivity in followActivities) {
                //[followActivity deleteEventually];
                [followActivity deleteInBackgroundWithBlock:completionBlock];// this may get called more than once but it's worth it to have accurate data
            }
         } else {
            completionBlock(error==nil,error);
         }
            

    }];
    [[VLMCache sharedCache] setFollowStatus:NO user:user];
}

#pragma mark Push

+ (void)sendFollowingPushNotification:(PFUser *)user {
    NSString *privateChannelName = [user objectForKey:kPAPUserPrivateChannelKey];
    if (privateChannelName && privateChannelName.length != 0) {
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat:@"%@ followed you on A/B.", [VLMUtility firstNameForDisplayName:[[PFUser currentUser] objectForKey:kPAPUserDisplayNameKey]]], kAPNSAlertKey,
                              kPAPPushPayloadPayloadTypeActivityKey, kPAPPushPayloadPayloadTypeKey,
                              kPAPPushPayloadActivityFollowKey, kPAPPushPayloadActivityTypeKey,
                              [[PFUser currentUser] objectId], kPAPPushPayloadFromUserObjectIdKey,
                              nil];
        PFPush *push = [[PFPush alloc] init];
        [push setChannel:privateChannelName];
        [push setData:data];
        [push sendPushInBackground];
    }
}

+ (void)sendLikePushNotification:(PFUser *)user Poll:(PFObject *)poll{
    if (![[[poll objectForKey:@"User"] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        NSString *privateChannelName = [[poll objectForKey:@"User"] objectForKey:kPAPUserPrivateChannelKey];
        if (privateChannelName && privateChannelName.length != 0) {
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSString stringWithFormat:@"%@ voted on your poll.", [VLMUtility firstNameForDisplayName:[[PFUser currentUser] objectForKey:kPAPUserDisplayNameKey]]], kAPNSAlertKey,
                                  kPAPPushPayloadPayloadTypeActivityKey, kPAPPushPayloadPayloadTypeKey,
                                  kPAPPushPayloadActivityLikeKey, kPAPPushPayloadActivityTypeKey,
                                  [[PFUser currentUser] objectId], kPAPPushPayloadFromUserObjectIdKey,
                                  [poll objectId], kPAPPushPayloadPhotoObjectIdKey,
                                  nil];
            PFPush *push = [[PFPush alloc] init];
            [push setChannel:privateChannelName];
            [push setData:data];
            [push sendPushInBackground];
        }
    }
}


+ (void)sendCommentPushNotification:(PFUser *)user Poll:(PFObject *)poll{
    if (![[[poll objectForKey:@"User"] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        NSString *privateChannelName = [[poll objectForKey:@"User"] objectForKey:kPAPUserPrivateChannelKey];
        if (privateChannelName && privateChannelName.length != 0) {
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSString stringWithFormat:@"%@ commented on your poll.", [VLMUtility firstNameForDisplayName:[[PFUser currentUser] objectForKey:kPAPUserDisplayNameKey]]], kAPNSAlertKey,
                                  kPAPPushPayloadPayloadTypeActivityKey, kPAPPushPayloadPayloadTypeKey,
                                  kPAPPushPayloadActivityCommentKey, kPAPPushPayloadActivityTypeKey,
                                  [[PFUser currentUser] objectId], kPAPPushPayloadFromUserObjectIdKey,
                                  [poll objectId], kPAPPushPayloadPhotoObjectIdKey,
                                  nil];
            PFPush *push = [[PFPush alloc] init];
            [push setChannel:privateChannelName];
            [push setData:data];
            [push sendPushInBackground];
        }
    }
    
}


@end
