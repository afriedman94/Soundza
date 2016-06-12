//
//  SDSettingsNotificationManager.m
//  Soundza
//
//  Created by Andrew Friedman on 6/8/16.
//  Copyright © 2016 Andrew Friedman. All rights reserved.
//

#import "SDSettingsManager.h"
#import "RLMPLaylist.h"
#import "RLMTrack.h"

static NSString *const kCogAlertTapped = @"AlertTapped1";
static NSString *const kRateTapped = @"RateTapped1";
static NSString *const kRateTappedDate = @"RateTappedDate1";

@implementation SDSettingsManager

#pragma mark - Settings Cog Notification

+(BOOL)settingsNotificationActive {
    
    //If the user has more than two or more playlists and saved more than 7 tracks saved. Lets try to get them to rate the app or remove ads.
    int playlistCount  = [RLMPlaylist allObjects].count;
    int trackCount = [RLMTrack allObjects].count;
    if (![self userHasTappedNotification] && playlistCount >= 2 && trackCount > 7) {
        return true;
    }
    else return false;
}
+(BOOL)userHasTappedNotification;
{
    return [[NSUserDefaults standardUserDefaults]boolForKey:kCogAlertTapped];
}

+(void)setNotificationHidden:(BOOL)hidden
{
    [[NSUserDefaults standardUserDefaults]setBool:hidden forKey:kCogAlertTapped];
    [[NSUserDefaults standardUserDefaults]synchronize];
}


#pragma mark - Rating

+(BOOL)userHasRatedApp
{
   return [[NSUserDefaults standardUserDefaults]boolForKey:kRateTapped];
}

+(void)userTappedRateInStore
{
    if (![self userHasRatedApp]) {
        NSDate *now = [NSDate date];
        [[NSUserDefaults standardUserDefaults]setObject:now forKey:kRateTappedDate];
        [[NSUserDefaults standardUserDefaults]setBool:true forKey:kRateTapped];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"RatedApp" object:nil];
    }
}

+(BOOL)shouldHideAdsForRating {
    
    NSDate *timeUserRatedApp = [[NSUserDefaults standardUserDefaults]objectForKey:kRateTappedDate];
    double timeSinceRating = [timeUserRatedApp timeIntervalSinceNow];
    double fiveDays = 432000.0;
    if ([self userHasRatedApp] && timeSinceRating >= -fiveDays) {
        return true;
    }
    else return false;
}

@end