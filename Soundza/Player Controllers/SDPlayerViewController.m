//
//  SDPlayerViewController.m
//  Soundza
//
//  Created by Andrew Friedman on 8/27/15.
//  Copyright (c) 2015 Andrew Friedman. All rights reserved.
//

#import "SDPlayerViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SDTrack.h"
#import "PlaylistManager.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "SDAdMobConfigurer.h"

@interface SDPlayerViewController () <GADInterstitialDelegate>

@property (strong, nonatomic) IBOutlet UISlider *slider;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *albumArtImageView;
@property (strong, nonatomic) IBOutlet UIButton *playPauseButton;
@property (strong, nonatomic) IBOutlet UIButton *skipButton;
@property (strong, nonatomic) IBOutlet UIButton *playLastButton;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UIButton *replayButton;
@property (strong, nonatomic) IBOutlet UIButton *shuffleButton;

@property (strong, nonatomic) GADInterstitial *interstitialAd;

- (IBAction)playPauseButtonPressed:(id)sender;
- (IBAction)skipButtonPressed:(id)sender;
- (IBAction)playLastButtonPressed:(id)sender;
- (IBAction)sliding:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;
- (IBAction)replayButtonPressed:(id)sender;
- (IBAction)shuffleButtonPressed:(id)sender;
@end

@implementation SDPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [PlayerManager sharedManager].delegate = self;
    
    [self.replayButton setSelected:[PlayerManager sharedManager].replayIsOn];
    [self.shuffleButton setSelected:[PlayerManager sharedManager].shuffleIsOn];
    
    [self.slider setThumbImage:[UIImage imageNamed:@"SliderHandle"] forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedQueueNotification:) name:@"updatedPlayer" object:nil];
    
    [self setDisplayForCurrentTrack];
    
    self.interstitialAd = [self createAndLoadInterstitial];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.playPauseButton.selected = [PlayerManager sharedManager].playerIsPlaying;
    [self setDisplayForCurrentTrack];

}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    [self displayAd];
}

-(void)updatedQueueNotification:(NSNotification *)notification
{
    [self setDisplayForCurrentTrack];
}


#pragma mark - Player Manager Delegate

-(void)updateProgressViewWithProgress:(CGFloat)progress timeLeft:(NSString *)time
{
    self.durationLabel.text = [NSString stringWithFormat:@"-%@", time];
    self.slider.value = progress;
    if (self.slider.value == 1) {
        [self.slider setValue:0.0 animated:YES];
    }
}

- (IBAction)playPauseButtonPressed:(id)sender
{
    [[PlayerManager sharedManager]togglePlayPause:sender];
}

- (IBAction)skipButtonPressed:(id)sender
{
    [[PlayerManager sharedManager]playNext];
}

- (IBAction)playLastButtonPressed:(id)sender
{
    [[PlayerManager sharedManager]playLastTrackFromPlaylist];
}

- (IBAction)sliding:(id)sender
{
    AVPlayer *player = [PlayerManager sharedManager].player;
    if ([sender isKindOfClass:[UISlider class]])
    {
        UISlider* slider = sender;
        
        CMTime playerDuration = player.currentItem.duration;
        if (CMTIME_IS_INVALID(playerDuration)) {
            return;
        }
        
        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration))
        {
            float minValue = [slider minimumValue];
            float maxValue = [slider maximumValue];
            float value = [slider value];
            
            double time = duration * (value - minValue) / (maxValue - minValue);
            
            [player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
        }
    }
}

- (IBAction)saveButtonPressed:(id)sender
{
    [UIView animateWithDuration:0.3/1.5 animations:^{
        self.saveButton.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
        [self.saveButton setImage:[UIImage imageNamed:@"CheckMarkOrange"] forState:UIControlStateNormal];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 animations:^{
            self.saveButton.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                self.saveButton.transform = CGAffineTransformIdentity;
            }];
        }];
    }];
    
    SDTrack *track = [PlayerManager sharedManager].currentTrack;
    track.isSaved = YES;
    [[PlaylistManager sharedManager]saveTrack:track];

}

- (IBAction)replayButtonPressed:(id)sender
{
    [self.replayButton setSelected:!self.replayButton.isSelected];
    [PlayerManager sharedManager].replayIsOn = self.replayButton.isSelected;
}

- (IBAction)shuffleButtonPressed:(id)sender
{
    [self.shuffleButton setSelected:!self.shuffleButton.isSelected];
    [PlayerManager sharedManager].shuffleIsOn = self.shuffleButton.isSelected;
    [[PlayerManager sharedManager]updateShuffleIfNeeded];
}

#pragma mark - Priviate Methods

-(void)setDisplayForCurrentTrack
{
    
    SDTrack *track = [PlayerManager sharedManager].currentTrack;

    
    if (!track) {
        
        [self setDisplayForNoCurrentTrack];
        
    }
    else{
        self.durationLabel.alpha = .9;
        self.skipButton.alpha = .85;
        self.skipButton.enabled = YES;
        self.playPauseButton.alpha = .85;
        self.playPauseButton.enabled = YES;
        
        BOOL playingFromSearch = [PlayerManager sharedManager].playingFromSearch;
        int currentPlaylistIndex = [PlayerManager sharedManager].currentPlaylistIndex;
        double queueCount = [PlayerManager sharedManager].queue.count;
        if (playingFromSearch || currentPlaylistIndex == 0 || queueCount){
            self.playLastButton.alpha = .55;
            self.playLastButton.enabled = NO;
        }
        else{
            self.playLastButton.alpha = .85;
            self.playLastButton.enabled = YES;
        }
        
        self.saveButton.hidden = NO;
        if (track.isSaved) {
            [self.saveButton setImage:[UIImage imageNamed:@"CheckMarkOrange"] forState:UIControlStateNormal];
            self.saveButton.enabled = NO;
        }
        else{
            [self.saveButton setImage:[UIImage imageNamed:@"Plus"] forState:UIControlStateNormal];
            self.saveButton.enabled = YES;
        }

        //Populate the cell with the data recieved from the search.
        self.titleLabel.text = track.titleString;
        self.usernameLabel.text = track.usernameString;
        //Format the tracks duration into a string and set the label.
        int duration = [track.duration intValue];
        NSString *durationString = [self timeFormatted:duration];
        self.durationLabel.text = durationString;
        
        NSString *urlString = track.artworkURLString;
        if (![urlString isEqual:[NSNull null]]) {
            NSString *highRes = [urlString stringByReplacingOccurrencesOfString:@"large" withString:@"crop"];
            NSURL *artURL = [NSURL URLWithString:highRes];
            [self.albumArtImageView sd_setImageWithURL:artURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image == nil) {
                    [self.albumArtImageView setImage:[UIImage imageNamed:@"no-album-art.png"]];
                }
            }];
            
        }
        else
        {
            [self.albumArtImageView setImage:[UIImage imageNamed:@"no-album-art.png"]];
        }
    }
}

-(void)setDisplayForNoCurrentTrack
{
    self.titleLabel.text = @"";
    self.usernameLabel.text = @"";
    self.durationLabel.text = @"0:00";
    self.albumArtImageView.image = nil;
    self.saveButton.hidden = YES;
    

    self.durationLabel.alpha = .55;
    self.skipButton.alpha = .55;
    self.skipButton.enabled = NO;
    self.playPauseButton.alpha = .55;
    self.playPauseButton.enabled = NO;
    self.playLastButton.alpha = .55;
    self.playLastButton.enabled = NO;
    
    [self.slider setValue:0.0 animated:YES];
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


#pragma mark - AdMob

-(void)displayAd {
    SDTrack *track = [PlayerManager sharedManager].currentTrack;
    srandom(time(NULL));
    int r = random() % 8;
    if (track && r == 0 && ![SDAdMobConfigurer adsShouldHide] && [self.interstitialAd isReady]) {
            [self.interstitialAd presentFromRootViewController:self];
    }
}

-(void)interstitialDidDismissScreen:(GADInterstitial *)ad {
    self.interstitialAd = [self createAndLoadInterstitial];
}


- (GADInterstitial *)createAndLoadInterstitial {
    GADInterstitial *interstitial =
    [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-9029083903735558/1110714621"];
    interstitial.delegate = self;
    GADRequest *request = [GADRequest request];
    request.testDevices = @[@"1c60b6109c966cd0fffe2019d8ebc286"];
    [interstitial loadRequest:request];
    return interstitial;
}


@end
