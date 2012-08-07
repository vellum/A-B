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
            
            
            // TURN THIS OFF TEMPORARILY
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
        
        // proceed to creating new like
        PFObject *likeActivity = [PFObject objectWithClassName:@"Activity"];
        [likeActivity setObject:@"like" forKey:@"Type"];
        [likeActivity setObject:[PFUser currentUser] forKey:@"FromUser"];
        [likeActivity setObject:[poll objectForKey:@"User"] forKey:@"ToUser"];
        [likeActivity setObject:photo forKey:@"Photo"];
        [likeActivity setObject:poll forKey:@"Poll"];
        
        PFACL *likeACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [likeACL setPublicReadAccess:YES];
        likeActivity.ACL = likeACL;
        
        [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (completionBlock) {
                completionBlock(succeeded,error);

                PFCachePolicy poly = kPFCachePolicyNetworkOnly;
                PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
                [query whereKey:@"Poll" equalTo:poll];
                [query setCachePolicy:poly];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    @synchronized(self){
                        
                        if ( !error ){
                            NSMutableArray *likersL = [NSMutableArray array];
                            NSMutableArray *likersR = [NSMutableArray array];
                            NSMutableArray *commenters = [NSMutableArray array];
                            BOOL isLikedByCurrentUserL = NO;
                            BOOL isLikedByCurrentUserR = NO;
                            
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
                                    if (isphotoleft){
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
                                    
                                }
                            }
                            
                            
                            [[VLMCache sharedCache] setAttributesForPoll:poll likersL:likersL likersR:likersR commenters:commenters isLikedByCurrentUserL:isLikedByCurrentUserL isLikedByCurrentUserR:isLikedByCurrentUserR];
                        }
                        
                        
					}
                }];
            }
        }];
     }];
}

+ (void)unlikePhotoInBackground:(id)photo forPoll:(id)poll isLeft:(BOOL)isleftphoto block:(void (^)(BOOL succeeded, NSError *error))completionBlock{

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
                            NSMutableArray *commenters = [NSMutableArray array];
                            BOOL isLikedByCurrentUserL = NO;
                            BOOL isLikedByCurrentUserR = NO;
                            
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
                                    if (isleftphoto){
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
                                    
                                }
                            }
                            
                            
                            [[VLMCache sharedCache] setAttributesForPoll:poll likersL:likersL likersR:likersR commenters:commenters isLikedByCurrentUserL:isLikedByCurrentUserL isLikedByCurrentUserR:isLikedByCurrentUserR];
                        }
                        
                        
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

@end
