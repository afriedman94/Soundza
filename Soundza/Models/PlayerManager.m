//
//  PlayerManager.m
//  
//
//  Created by Andrew Friedman on 4/24/15.
//
//

#import "PlayerManager.h"
#import <MediaPlayer/MPMediaItem.h>
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaQuery.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "RLMTrack.h"

static NSString *const kSoundCloudClientId = @"376f225bf427445fc4bfb6b99b72e0bf";

@implementation PlayerManager

{
    BOOL _playingFromPlaylist;
    int _playlistIndex;
    
    NSMutableArray * _shuffledArray;
    int currentShufIndex;
}

+(PlayerManager *)sharedManager {
    
    static dispatch_once_t _once;
    static PlayerManager *sharedManager = nil;
    dispatch_once(&_once, ^{
        sharedManager = [[PlayerManager alloc] init];
    });
    return sharedManager;
}

-(void)playTrack:(SDTrack *)track
{
    
    NSString *streamURLSTring = [NSString stringWithFormat:@"%@?client_id=%@", track.streamURLString, kSoundCloudClientId];
    NSURL *streamURL = [NSURL URLWithString:streamURLSTring];
    self.player = [[AVPlayer alloc]initWithURL:streamURL];
    [self.player play];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.player currentItem]];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:.05 target:self selector:@selector(updateProgressView) userInfo:nil repeats:YES];
    self.playerIsPlaying = YES;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"trackPlayed" object:nil];
    
    self.player.allowsExternalPlayback = NO;
    
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    self.dicForInfoCenter = [[NSMutableDictionary alloc]init];
    if (playingInfoCenter) {
        
        int durationAsSeconds = [track.duration intValue]/1000;
       
        [self.dicForInfoCenter removeAllObjects];
        [self.dicForInfoCenter setObject:track.titleString forKey:MPMediaItemPropertyTitle];
        [self.dicForInfoCenter setObject:track.usernameString forKey:MPMediaItemPropertyArtist];
        [self.dicForInfoCenter setObject:[NSNumber numberWithInt:durationAsSeconds]
                                  forKey:MPMediaItemPropertyPlaybackDuration];
        [self.dicForInfoCenter setObject:[NSNumber numberWithInt:1] forKey:MPNowPlayingInfoPropertyPlaybackRate];
        
        
        if (![track.artworkURLString isEqual:[NSNull null]]) {
        NSString *highRes = [track.artworkURLString stringByReplacingOccurrencesOfString:@"large" withString:@"crop"];
        NSURL *artworkURL = [NSURL URLWithString:highRes];
        //download the artwork url and set it as the background of lockscreen when recievied.
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:artworkURL options:kNilOptions
                                                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                                 //size;
                                                             } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                                 
                                                                 if (image == nil) {
                                                                     UIImage *noArtImage = [UIImage imageNamed:@"no-album-art"];
                                                                     MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc]initWithImage:noArtImage];
                                                                     [self.dicForInfoCenter setObject:albumArt forKey:MPMediaItemPropertyArtwork];
                                                                     [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:self.dicForInfoCenter];
                                                                 }
                                                                 else{
                                                                 
                                                                 MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc]initWithImage:image];
                                                                     [self.dicForInfoCenter setObject:albumArt forKey:MPMediaItemPropertyArtwork];
                                                                 [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:self.dicForInfoCenter];
                                                                 }
                                                             }];
        }
        else{
            UIImage *noArtImage = [UIImage imageNamed:@"no-album-art"];
            MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc]initWithImage:noArtImage];
            [self.dicForInfoCenter setObject:albumArt forKey:MPMediaItemPropertyArtwork];
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:self.dicForInfoCenter];
        }
        
    }
}

-(void)togglePlayPause:(UIButton *)sender
{
    BOOL playing = self.playerIsPlaying;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:playing] forKey:@"playerIsPlaying"];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"togglePlayPause" object:nil userInfo:userInfo];
    
    if (self.playerIsPlaying) {
        sender.selected = NO;
        [self.player pause];
        self.playerIsPlaying = NO;
    }
    else{
        sender.selected = YES;
        [self.player play];
        self.playerIsPlaying = YES;
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"updatedPlayer" object:nil userInfo:userInfo];
}

- (void)updateProgressView
{
    if ([self.player currentItem]) {
        float duration = CMTimeGetSeconds(self.player.currentItem.duration);
        float current = CMTimeGetSeconds(self.player.currentTime);
        float progress = (current/duration);
        
        int currentAsInt = (int)floor(current);
        int durationAsInt = (int)floor(duration);
        //Multiply by 1000 to put it in milliseconds for formatter
        int timeLeft = (durationAsInt-currentAsInt)*1000;
        NSString *timeLeftString = [self timeFormatted:timeLeft];
        
        [self.delegate updateProgressViewWithProgress:progress timeLeft:timeLeftString];
    }
}


-(void)itemDidFinishPlaying:(NSNotificationCenter *)notification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"songEnded" object:nil];
    
    [self playNext];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"updatedPlayer" object:nil];
}

-(void)playNext
{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    
    if(self.replayIsOn){
        [self playTrack:self.currentTrack];
    }
    else if (self.queue.count) {
        [self playNextInQueue];
    }
    else {
        if (self.playingFromPlaylist) {
            
            if (self.shuffleIsOn) {
                [self playNextSongShuffled];
            }
            else
                [self playNextTrackFromPlaylist];
        }
        else{
            [self clearPlayer];
        }
    }
}

-(void)clearPlayer
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    self.currentTrack = nil;
    self.player = nil;
    [self.timer invalidate];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"songEnded" object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"updatedPlayer" object:nil];
}


#pragma mark - New Player Methods

-(void)playTrackOnce:(SDTrack *)track trackIndex:(NSInteger)index
{
    self.currentSearchIndex = index;
    self.playingFromSearch = YES;
    self.currentTrack = track;
    self.playingFromPlaylist = NO;
    [self playTrack:self.currentTrack];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"updatedPlayer" object:nil];
}

-(void)playPlaylistTracks:(NSMutableArray *)tracks beginingAtIndex:(NSInteger)index;
{
    self.playingFromSearch = NO;
    self.playingFromPlaylist = YES;
    self.playlist = tracks;
    self.currentPlaylistIndex = index;
    SDTrack *track = tracks[index];
    self.currentTrack = track;
    [self playTrack:track];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"updatedPlayer" object:nil];
    
    [self updateShuffleIfNeeded];
}

-(void)playNextTrackFromPlaylist
{
    //If the playlist has reached the last song of the list, play the first track in the playlist. Else, play the next song in the list.
    if (self.currentPlaylistIndex == self.playlist.count-1) {
        self.currentPlaylistIndex = 0;
        SDTrack *track = self.playlist[self.currentPlaylistIndex];
        self.currentTrack = track;
        [self playTrack:track];
    }
    else {
        self.currentPlaylistIndex++;
        SDTrack *track = self.playlist[self.currentPlaylistIndex];
        self.currentTrack = track;
        [self playTrack:track];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"updatedPlayer" object:nil];
}

-(void)playLastTrackFromPlaylist;
{
    if (self.shuffleIsOn){
        //play last shuffled song
        if (currentShufIndex > 0) {
            NSNumber *shuffledIndex = _shuffledArray[currentShufIndex-1];
            int i = [shuffledIndex intValue];
            SDTrack *track = self.playlist[i];
            [self playTrack:track];
            self.currentTrack = track;
            [[NSNotificationCenter defaultCenter]postNotificationName:@"updatedPlayer" object:nil];
        }
    }
    else{
    self.currentPlaylistIndex--;
    SDTrack *lastTrack = self.playlist[self.currentPlaylistIndex];
    self.currentTrack = lastTrack;
    [self playTrack:self.currentTrack];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"updatedPlayer" object:nil];
    }
}

-(void)playNextInQueue
{
    self.currentTrack = self.queue.firstObject;
    [self.queue removeObjectAtIndex:0];
    [self playTrack:self.currentTrack];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"updatedPlayer" object:nil];
}

-(void)playNextSongShuffled
{
    NSNumber *shuffledIndex = _shuffledArray[currentShufIndex];
    int i = [shuffledIndex intValue];
    SDTrack *track = self.playlist[i];
    [self playTrack:track];
    
    self.currentTrack = track;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"updatedPlayer" object:nil];

    //update the shuffled index
    if (currentShufIndex < self.playlist.count-1)
        currentShufIndex++;
    else
        currentShufIndex = 0;
}

-(void)updateShuffleIfNeeded
{
    if (self.shuffleIsOn) {
        [self shufflePlaylistIndexes];
    }
    else{
        if (_shuffledArray.count) {
            [_shuffledArray removeAllObjects];
        }
    }
}

-(void)shufflePlaylistIndexes
{
    if (self.playlist) {
        
        _shuffledArray = [[NSMutableArray alloc]initWithCapacity:self.playlist.count];
        for (int x = 0; x<self.playlist.count; x++)
        {
            NSNumber *i = [NSNumber numberWithInt:x];
            [_shuffledArray addObject:i];
        }
        
        //shuffle the array
        NSUInteger count = [_shuffledArray count];
        for (NSUInteger i = 0; i < count - 1; ++i) {
            NSInteger remainingCount = count - i;
            NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
            [_shuffledArray exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
        }
        currentShufIndex = 0;
    }
}

-(void)clearQueue
{
    [self.queue removeAllObjects];
}

-(void)enqueueTrack:(SDTrack *)track;
{
    if (!self.queue) {
        self.queue = [[NSMutableArray alloc]init];
    }
    
    if (!self.currentTrack) {
        self.currentTrack = track;
        [self playTrack:self.currentTrack];
    }
    else{
        [self.queue addObject:track];
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"songQueued" object:nil];
}


- (NSString *)timeFormatted:(int)totalSeconds
{
    int temp = (int)totalSeconds / 1000;
    int minutes = (temp / 60);
    int seconds = temp % 60;
    
    if (seconds < 10)
        return [NSString stringWithFormat:@"%i:0%i", minutes, seconds];
    else
        return [NSString stringWithFormat:@"%i:%i", minutes, seconds];
}

@end
