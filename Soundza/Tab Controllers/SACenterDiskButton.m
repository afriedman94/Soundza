//
//  SACenterDiskButton.m
//  TuneSnap
//
//  Created by Andrew Friedman on 7/21/15.
//  Copyright (c) 2015 Andrew Friedman. All rights reserved.
//

#import "SACenterDiskButton.h"
#import "UIImageView+Rotate.h"
#import "PlayerManager.h"

@implementation SACenterDiskButton

-(id)initWithImage:(UIImage *)image forView:(UIView *)view;
{
    self = [super init];
    if (self) {
        
        //Add observers for when tracks are played/paused/ended for spinning the center button
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(trackPlayedNotification:) name:@"trackPlayed" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playPauseNotification:) name:@"togglePlayPause" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:@"songEnded" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
     
    }
    return  self;
}

#pragma mark - Notification Center

//-(void)applicationWillEnterForeground:(NSNotification *)notification
//{
//    BOOL playerIsPlaying = [PlayerManager sharedManager].playerIsPlaying;
//    
//    if (playerIsPlaying) {
//        [self.view rotate360WithDuration];
//        
//    }
//}
//
//-(void)itemDidFinishPlaying:(NSNotification *)notification
//{
// 
//    [self.imageView stopAllAnimations];
//    
//}
//
//-(void)trackPlayedNotification:(NSNotification *)notification
//{
//    [self.imageView rotate360WithDuration];
//}
//
//-(void)playPauseNotification:(NSNotification *)notification
//{
//    NSNumber *playerIsPlaying = notification.userInfo[@"playerIsPlaying"];
//    
//    if ([playerIsPlaying boolValue]) {
//        
//        
//        [self.imageView stopAllAnimations];
//    }
//    else {
//        
//        [self.imageView rotate360WithDuration];
//    }
//}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
