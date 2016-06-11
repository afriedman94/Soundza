//
//  SDPlaylistTableViewCell.m
//  Soundza
//
//  Created by Andrew Friedman on 9/7/15.
//  Copyright (c) 2015 Andrew Friedman. All rights reserved.
//

#import "SDPlaylistTableViewCell.h"
#import "PlayerManager.h"

@implementation SDPlaylistTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setupDisplayForTrack:(SDTrack *)track;
{
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onSelfLongPressDetected:)];
    self.longPressGesture.minimumPressDuration = .8;
    [self addGestureRecognizer:self.longPressGesture];

    self.titleLabel.text = track.titleString;
    self.usernameLabel.text = track.usernameString;
    
    if (track.artworkURLString.length)
    {
        NSURL *albumArtURL = [NSURL URLWithString:track.artworkURLString];
        [self.artworkImageView sd_setImageWithURL:albumArtURL];
    }
    else{
        [self.artworkImageView setImage:[UIImage imageNamed:@"no-album-art"]];
    }
    
    
    //If this is the current track being played, make the labels text orange
    SDTrack *currentTrack= [PlayerManager sharedManager].currentTrack;
    if ([currentTrack.titleString isEqualToString:track.titleString] && [currentTrack.usernameString isEqualToString:track.usernameString]) {
        UIColor *orangeColor = [UIColor colorWithRed:0.981 green:0.347 blue:0 alpha:1];
        self.titleLabel.textColor = orangeColor;
        self.usernameLabel.textColor = orangeColor;
    }
    else
    {
        self.titleLabel.textColor = [UIColor blackColor];
        self.usernameLabel.textColor = [UIColor colorWithRed:0.568 green:0.567 blue:0.567 alpha:1];
    }
    
}

-(void)onSelfLongPressDetected:(UILongPressGestureRecognizer *)longPressGestRec
{
    if (longPressGestRec.state == UIGestureRecognizerStateBegan) {
        [self.playlistDelegate longPressOnCell:self];
    }
}

@end
