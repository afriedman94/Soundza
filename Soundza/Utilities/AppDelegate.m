//
//  AppDelegate.m
//  Soundza
//
//  Created by Andrew Friedman on 8/27/15.
//  Copyright (c) 2015 Andrew Friedman. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "PlaylistManager.h"
#import "PlayerManager.h"
#import "iRateManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

+(void)initialize {

    [iRateManager setUp];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   
    //Change nav bar tint to orange
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.981 green:0.347 blue:0 alpha:1]];
    
    //Allow the application to receive remote events for audio playback
    NSError *sessionError = nil;
    NSError *activationError = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:&sessionError];
    [[AVAudioSession sharedInstance] setActive: YES error: &activationError];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(interruption:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
    
    //set the player page index to the first.
    NSNumber *one = [NSNumber numberWithInt:0];
    [[NSUserDefaults standardUserDefaults] setObject:one forKey:@"pageIndex"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    //The app has loaded for the first time, create the first playlist and save it.
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        
        [[PlaylistManager sharedManager]createNewPlaylistWithTitle:@"Playlist"];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    RLMPlaylist *firstPlaylist = [[RLMPlaylist objectsWhere:@"isCurrent = YES"]firstObject];
    [PlaylistManager sharedManager].playlist = (RLMPlaylist *)firstPlaylist;
    
    
    return YES;
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeRemoteControl) {
        
        if (event.type == UIEventTypeRemoteControl)
        {
            if (event.subtype == UIEventSubtypeRemoteControlPlay)
            {
                [[PlayerManager sharedManager]togglePlayPause:nil];
            }
            else if (event.subtype == UIEventSubtypeRemoteControlPause)
            {
                [[PlayerManager sharedManager]togglePlayPause:nil];
            }
            else if (event.subtype == UIEventSubtypeRemoteControlNextTrack)
            {
                [[PlayerManager sharedManager]playNext];
            }
            else if (event.subtype == UIEventSubtypeRemoteControlPreviousTrack){
                
                if ([PlayerManager sharedManager].playingFromPlaylist) {
                   [[PlayerManager sharedManager]playLastTrackFromPlaylist];
                }
            }
        }
    }
}

#pragma mark - NSNotification Center 

-(void)interruption:(NSNotification *)note;
{
    NSDictionary *interuptionDict = note.userInfo;
    // get the AVAudioSessionInterruptionTypeKey enum from the dictionary
    NSInteger interuptionType = [[interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    // decide what to do based on interruption type here...
    switch (interuptionType) {
        case AVAudioSessionInterruptionTypeBegan:
            NSLog(@"Audio Session Interruption case started.");
            
            [[PlayerManager sharedManager]togglePlayPause:nil];
            
            break;
            
        case AVAudioSessionInterruptionTypeEnded:
            NSLog(@"Audio Session Interruption case ended.");
            // fork to handling method here...
            // EG:[self handleInterruptionEnded];
            break;
            
        default:
            NSLog(@"Audio Session Interruption Notification case default.");
            break;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
