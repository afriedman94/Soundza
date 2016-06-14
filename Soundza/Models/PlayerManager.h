//
//  PlayerManager.h
//  
//
//  Created by Andrew Friedman on 4/24/15.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "SDTrack.h"

@protocol PlayerManagerDelegate <NSObject>
@optional
-(void)updateProgressViewWithProgress:(CGFloat)progress timeLeft:(NSString *)time;
-(void)itemDidFinishPlaying;
@end

@interface PlayerManager : NSObject

@property (strong, nonatomic) NSString *clientId;

@property (strong, nonatomic) NSMutableArray *queue;
@property (strong, nonatomic) NSMutableArray *playlist;
@property (strong, nonatomic) SDTrack *currentTrack;
@property (assign, nonatomic) BOOL playingFromPlaylist;
@property (assign, nonatomic) BOOL playingFromSearch;
@property (nonatomic) int currentPlaylistIndex;
@property (strong, nonatomic) NSString *playlistName;
@property (assign ,nonatomic) BOOL replayIsOn;
@property (assign, nonatomic) BOOL shuffleIsOn;


@property (nonatomic) int currentSearchIndex;

@property (strong, nonatomic) NSMutableDictionary *dicForInfoCenter;

@property (weak, nonatomic) id delegate;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic, assign) BOOL playerIsPlaying; 
+(PlayerManager *)sharedManager;
-(void)playTrack:(SDTrack *)track;
-(void)togglePlayPause:(UIButton *)sender;
-(void)playLastTrackFromPlaylist;
-(void)playNextTrackFromPlaylist;
-(void)clearPlayer;

-(void)updateShuffleIfNeeded;

-(void)playNext;
-(void)playNextInQueue;
-(void)enqueueTrack:(SDTrack *)track;
-(void)clearQueue;

-(void)playPlaylistTracks:(NSMutableArray *)tracks beginingAtIndex:(NSInteger)index;

-(void)playTrackOnce:(SDTrack *)track trackIndex:(NSInteger)index;

@end
