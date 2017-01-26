//
//  SDSoundCloudAPI.m
//  Soundza
//
//  Created by Andrew Friedman on 8/27/15.
//  Copyright (c) 2015 Andrew Friedman. All rights reserved.
//

#import "SDSoundCloudAPI.h"
#import <SCAPI.h>
#import "SDTrack.h"
#import "PlaylistManager.h"

NSString *const ClientID = @"oUfBJBYyA6QXy8mDthCcMzoas4CL3Qag";

@implementation SDSoundCloudAPI


+(SDSoundCloudAPI *)sharedManager {
    
    static dispatch_once_t _once;
    static SDSoundCloudAPI *sharedManager = nil;
    dispatch_once(&_once, ^{
        sharedManager = [[SDSoundCloudAPI alloc] init];
    });
    return sharedManager;
}

+ (void)getTracksWithSearch:(NSString *)search withCompletion:(void(^)(NSMutableArray *tracks, BOOL error))completion;
{
    
    NSString *appendedInput = [search stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    search = [NSString stringWithFormat:@"https://api.soundcloud.com/tracks?client_id=%@&q=%@&limit=50&format=json",ClientID, appendedInput];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:search parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSMutableArray *responseArray = [responseObject mutableCopy];
        NSMutableIndexSet *indexesToDelete = [NSMutableIndexSet indexSet];
        NSUInteger currentIndex = 0;
        for (NSDictionary *track in responseArray) {
            if ([track objectForKey:@"streamable"] == [NSNumber numberWithBool:false]) {
                [indexesToDelete addIndex:currentIndex];
            }
            currentIndex++;
        }
        [responseArray removeObjectsAtIndexes:indexesToDelete];
        completion((NSMutableArray *) responseArray, (BOOL) NO);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
  
}

-(void)getTracksForGenre:(NSString *)genre withCompletion:(void(^)(NSArray *tracks, BOOL error))completion;
{
    
    NSString *appendedInput = [genre stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSString *appendInput2 = [appendedInput stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    NSString *path = [NSString stringWithFormat:@"https://api.soundcloud.com/tracks?genres=%@&limit=50&client_id=%@",appendInput2, ClientID];
    
    
    //Used the shared operation manager to prevent crashing. This allows the operation to be canceled at any time. Prevents crashes from popping/dismissing view controllers during an async request. It may be best to use the shared operation manager for all of my operations, but for now it is only needed for getting tracks for genre.
    self.operationManager = [AFHTTPRequestOperationManager manager];
    [self.operationManager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSMutableArray *responseArray = [responseObject mutableCopy];
        NSMutableIndexSet *indexesToDelete = [NSMutableIndexSet indexSet];
        NSUInteger currentIndex = 0;
        for (NSDictionary *track in responseArray) {
            if ([track objectForKey:@"streamable"] == [NSNumber numberWithBool:false]) {
                [indexesToDelete addIndex:currentIndex];
            }
            currentIndex++;
        }
        [responseArray removeObjectsAtIndexes:indexesToDelete];
        
        if (completion) {
            completion((NSArray *) responseArray, (BOOL) NO);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (completion) {
        }
    }];
}

-(void)parseTracks:(NSArray *)tracks withCompletion:(void(^)(NSArray *parsedTracks))compltion;
{
    NSMutableArray *result = [[NSMutableArray alloc]init];
    for (NSDictionary *trk in tracks) {
        SDTrack *track = [[SDTrack alloc]initWithTrack:trk];
        
        //check if this track is already saved to the current playlist
        RLMArray *savedTracks = [PlaylistManager sharedManager].playlist.tracks;
        for (RLMTrack *t in savedTracks) {
            if ([track.titleString isEqualToString:t.titleString] && [track.usernameString isEqualToString:t.usernameString])
            {
                track.isSaved = YES;
            }
        }

        
        [result addObject:track];
    }
    
    if (compltion) {
        compltion(result);
    }
}

+(NSArray *)listOfGenres
{
    NSArray *listOfGenres = [[NSArray alloc]initWithObjects:
                             @"Alternative Rock",
                             @"Ambient",
                             @"Classical",
                             @"Country",
                             @"Dance",
                             @"Deep House",
                             @"Disco",
                             @"Drum & Bass",
                             @"Dubstep",
                             @"Electronic",
                             @"Folk",
                             @"Hip Hop",
                             @"House",
                             @"Indie",
                             @"Jazz",
                             @"Latin",
                             @"Metal",
                             @"Piano",
                             @"Pop",
                             @"R&B",
                             @"Rap",
                             @"Reggae",
                             @"Rock",
                             @"Techno",
                             @"Trance",
                             @"Trap",
                             @"Trip Hop",
                             @"World",
                             nil];
    return listOfGenres;
}


@end
