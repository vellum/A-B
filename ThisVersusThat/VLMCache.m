//
//  VLMCache.m
//  ThisVersusThat
//
//  Created by David Lu on 8/2/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import "VLMCache.h"

@interface VLMCache()
@property (nonatomic, strong) NSCache *cache;
//- (void)setAttributes:(NSDictionary *)attributes forPhoto:(PFObject *)photo;
@end

@implementation VLMCache

@synthesize cache;

            #pragma mark - Cached Photo Attributes
            // keys
            NSString *const kPAPPhotoAttributesIsLikedByCurrentUserKey = @"isLikedByCurrentUser";
            NSString *const kPAPPhotoAttributesLikeCountKey            = @"likeCount";
            NSString *const kPAPPhotoAttributesLikersKey               = @"likers";
            NSString *const kPAPPhotoAttributesCommentCountKey         = @"commentCount";
            NSString *const kPAPPhotoAttributesCommentersKey           = @"commenters";


            #pragma mark - Cached User Attributes
            // keys
            NSString *const kPAPUserAttributesPhotoCountKey                 = @"photoCount";
            NSString *const kPAPUserAttributesIsFollowedByCurrentUserKey    = @"isFollowedByCurrentUser";

            NSString *const kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey    = @"com.parse.Anypic.userDefaults.activityFeedViewController.lastRefresh";
            NSString *const kPAPUserDefaultsCacheFacebookFriendsKey                     = @"com.parse.Anypic.userDefaults.cache.facebookFriends";


#pragma mark - Initialization

+ (id)sharedCache {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

#pragma mark - PAPCache

- (void)clear {
    [self.cache removeAllObjects];
}

- (void)setAttributesForPoll:(PFObject *)poll likersL:(NSArray *)likersLeft likersR:(NSArray *)likersRight commenters:(NSArray *)commenters isLikedByCurrentUserL:(BOOL)likedByCurrentUserLeft isLikedByCurrentUserR:(BOOL)likedByCurrentUserRight{
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithBool:likedByCurrentUserLeft], @"LikedByCurrentUserLeft",
                                [NSNumber numberWithBool:likedByCurrentUserRight], @"LikedByCurrentUserRight",
                                [NSNumber numberWithInt:[likersLeft count]], @"LikerCountLeft",
                                [NSNumber numberWithInt:[likersRight count]], @"LikerCountRight",
                                likersLeft, @"LikersLeft",
                                likersRight, @"LikersRight",
                                [NSNumber numberWithInt:[commenters count]], @"CommenterCount",
                                commenters, @"Commenters",
                                nil];
    
    NSLog(@"%d  %d", [likersLeft count], [likersRight count]);
    [self setAttributes:attributes forPoll:poll];
}

- (NSNumber *)likeCountForPollLeft:(PFObject *)poll{
    NSDictionary *attributes = [self attributesForPoll:poll];
    if (attributes) {
        return [attributes objectForKey:@"LikerCountLeft"];
    }
    
    return [NSNumber numberWithInt:0];
}

- (NSNumber *)likeCountForPollRight:(PFObject *)poll{
    NSDictionary *attributes = [self attributesForPoll:poll];
    if (attributes) {
        return [attributes objectForKey:@"LikerCountRight"];
    }
    
    return [NSNumber numberWithInt:0];
}

- (BOOL)isPollLikedByCurrentUserLeft:(PFObject *)poll{
    NSDictionary *attributes = [self attributesForPoll:poll];
    if (attributes) {
        return [[attributes objectForKey:@"LikedByCurrentUserLeft"] boolValue];
    }
    
    return NO;
}

- (BOOL)isPollLikedByCurrentUserRight:(PFObject *)poll{
    NSDictionary *attributes = [self attributesForPoll:poll];
    if (attributes) {
        return [[attributes objectForKey:@"LikedByCurrentUserRight"] boolValue];
    }
    
    return NO;
}


- (NSDictionary *)attributesForPoll:(PFObject *)poll{
    NSString *key = [self keyForPoll:poll];
    return [self.cache objectForKey:key];
}

- (void)setAttributes:(NSDictionary *)attributes forPoll:(PFObject *)poll {
    NSString *key = [self keyForPoll:poll];
    [self.cache setObject:attributes forKey:key];
}

- (void)setAttributes:(NSDictionary *)attributes forUser:(PFUser *)user {
    NSString *key = [self keyForUser:user];
    [self.cache setObject:attributes forKey:key];    
}

- (NSString *)keyForPoll:(PFObject *)poll {
    return [NSString stringWithFormat:@"poll_%@", [poll objectId]];
}

- (NSString *)keyForUser:(PFUser *)user {
    return [NSString stringWithFormat:@"user_%@", [user objectId]];
}


/*
- (void)setAttributesForPhoto:(PFObject *)photo likers:(NSArray *)likers commenters:(NSArray *)commenters likedByCurrentUser:(BOOL)likedByCurrentUser {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithBool:likedByCurrentUser],kPAPPhotoAttributesIsLikedByCurrentUserKey,
                                [NSNumber numberWithInt:[likers count]],kPAPPhotoAttributesLikeCountKey,
                                likers,kPAPPhotoAttributesLikersKey,
                                [NSNumber numberWithInt:[commenters count]],kPAPPhotoAttributesCommentCountKey,
                                commenters,kPAPPhotoAttributesCommentersKey,
                                nil];
    [self setAttributes:attributes forPhoto:photo];
}

- (NSDictionary *)attributesForPhoto:(PFObject *)photo {
    NSString *key = [self keyForPhoto:photo];
    return [self.cache objectForKey:key];
}

- (NSNumber *)likeCountForPhoto:(PFObject *)photo {
    NSDictionary *attributes = [self attributesForPhoto:photo];
    if (attributes) {
        return [attributes objectForKey:kPAPPhotoAttributesLikeCountKey];
    }
    
    return [NSNumber numberWithInt:0];
}

- (NSNumber *)commentCountForPhoto:(PFObject *)photo {
    NSDictionary *attributes = [self attributesForPhoto:photo];
    if (attributes) {
        return [attributes objectForKey:kPAPPhotoAttributesCommentCountKey];
    }
    
    return [NSNumber numberWithInt:0];
}

- (NSArray *)likersForPhoto:(PFObject *)photo {
    NSDictionary *attributes = [self attributesForPhoto:photo];
    if (attributes) {
        return [attributes objectForKey:kPAPPhotoAttributesLikersKey];
    }
    
    return [NSArray array];
}

- (NSArray *)commentersForPhoto:(PFObject *)photo {
    NSDictionary *attributes = [self attributesForPhoto:photo];
    if (attributes) {
        return [attributes objectForKey:kPAPPhotoAttributesCommentersKey];
    }
    
    return [NSArray array];
}

- (void)setPhotoIsLikedByCurrentUser:(PFObject *)photo liked:(BOOL)liked {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForPhoto:photo]];
    [attributes setObject:[NSNumber numberWithBool:liked] forKey:kPAPPhotoAttributesIsLikedByCurrentUserKey];
    [self setAttributes:attributes forPhoto:photo];
}

- (BOOL)isPhotoLikedByCurrentUser:(PFObject *)photo {
    NSDictionary *attributes = [self attributesForPhoto:photo];
    if (attributes) {
        return [[attributes objectForKey:kPAPPhotoAttributesIsLikedByCurrentUserKey] boolValue];
    }
    
    return NO;
}

- (void)incrementLikerCountForPhoto:(PFObject *)photo {
    NSNumber *likerCount = [NSNumber numberWithInt:[[self likeCountForPhoto:photo] intValue] + 1];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForPhoto:photo]];
    [attributes setObject:likerCount forKey:kPAPPhotoAttributesLikeCountKey];
    [self setAttributes:attributes forPhoto:photo];
}

- (void)decrementLikerCountForPhoto:(PFObject *)photo {
    NSNumber *likerCount = [NSNumber numberWithInt:[[self likeCountForPhoto:photo] intValue] - 1];
    if ([likerCount intValue] < 0) {
        return;
    }
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForPhoto:photo]];
    [attributes setObject:likerCount forKey:kPAPPhotoAttributesLikeCountKey];
    [self setAttributes:attributes forPhoto:photo];
}

- (void)incrementCommentCountForPhoto:(PFObject *)photo {
    NSNumber *commentCount = [NSNumber numberWithInt:[[self commentCountForPhoto:photo] intValue] + 1];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForPhoto:photo]];
    [attributes setObject:commentCount forKey:kPAPPhotoAttributesCommentCountKey];
    [self setAttributes:attributes forPhoto:photo];
}

- (void)decrementCommentCountForPhoto:(PFObject *)photo {
    NSNumber *commentCount = [NSNumber numberWithInt:[[self commentCountForPhoto:photo] intValue] - 1];
    if ([commentCount intValue] < 0) {
        return;
    }
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForPhoto:photo]];
    [attributes setObject:commentCount forKey:kPAPPhotoAttributesCommentCountKey];
    [self setAttributes:attributes forPhoto:photo];
}

- (void)setAttributesForUser:(PFUser *)user photoCount:(NSNumber *)count followedByCurrentUser:(BOOL)following {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                count,kPAPUserAttributesPhotoCountKey,
                                [NSNumber numberWithBool:following],kPAPUserAttributesIsFollowedByCurrentUserKey,
                                nil];
    [self setAttributes:attributes forUser:user];
}

- (NSDictionary *)attributesForUser:(PFUser *)user {
    NSString *key = [self keyForUser:user];
    return [self.cache objectForKey:key];
}

- (NSNumber *)photoCountForUser:(PFUser *)user {
    NSDictionary *attributes = [self attributesForUser:user];
    if (attributes) {
        NSNumber *photoCount = [attributes objectForKey:kPAPUserAttributesPhotoCountKey];
        if (photoCount) {
            return photoCount;
        }
    }
    
    return [NSNumber numberWithInt:0];
}

- (BOOL)followStatusForUser:(PFUser *)user {
    NSDictionary *attributes = [self attributesForUser:user];
    if (attributes) {
        NSNumber *followStatus = [attributes objectForKey:kPAPUserAttributesIsFollowedByCurrentUserKey];
        if (followStatus) {
            return [followStatus boolValue];
        }
    }
    
    return NO;
}

- (void)setPhotoCount:(NSNumber *)count user:(PFUser *)user {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForUser:user]];
    [attributes setObject:count forKey:kPAPUserAttributesPhotoCountKey];
    [self setAttributes:attributes forUser:user];
}

- (void)setFollowStatus:(BOOL)following user:(PFUser *)user {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForUser:user]];
    [attributes setObject:[NSNumber numberWithBool:following] forKey:kPAPUserAttributesIsFollowedByCurrentUserKey];
    [self setAttributes:attributes forUser:user];
}

- (void)setFacebookFriends:(NSArray *)friends {
    NSString *key = kPAPUserDefaultsCacheFacebookFriendsKey;
    [self.cache setObject:friends forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:friends forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)facebookFriends {
    NSString *key = kPAPUserDefaultsCacheFacebookFriendsKey;
    if ([self.cache objectForKey:key]) {
        return [self.cache objectForKey:key];
    }
    
    NSArray *friends = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if (friends) {
        [self.cache setObject:friends forKey:key];
    }
    
    return friends;
}


#pragma mark - ()

- (void)setAttributes:(NSDictionary *)attributes forPhoto:(PFObject *)photo {
    NSString *key = [self keyForPhoto:photo];
    [self.cache setObject:attributes forKey:key];
}

- (void)setAttributes:(NSDictionary *)attributes forUser:(PFUser *)user {
    NSString *key = [self keyForUser:user];
    [self.cache setObject:attributes forKey:key];    
}

- (NSString *)keyForPhoto:(PFObject *)photo {
    return [NSString stringWithFormat:@"photo_%@", [photo objectId]];
}

- (NSString *)keyForUser:(PFUser *)user {
    return [NSString stringWithFormat:@"user_%@", [user objectId]];
}
 
 */

@end
