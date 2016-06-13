//
//  SDSpinningDiskImageView.m
//  Soundza
//
//  Created by Andrew Friedman on 6/12/16.
//  Copyright © 2016 Andrew Friedman. All rights reserved.
//

#import "SDSpinningDiskImageView.h"
#import "UIImageView+Rotate.h"
#import "PlayerManager.h"
#import "UIColor+SoundzaColors.h"

@implementation SDSpinningDiskImageView


-(id)initWithTabBar:(UITabBarController *)tabBarController;
{
    self = [super init];
    if (self) {
        
        //Add observers for when tracks are played/paused/ended for spinning the center button
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedPlayer:) name:@"updatedPlayer" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        
        self.frame = CGRectMake(tabBarController.tabBar.frame.size.width/2-15,
                                tabBarController.tabBar.frame.size.height/2-15,
                                30,
                                30);
        [self setImage:[UIImage imageNamed:@"StreamBlack.png"]];
        self.image = [self.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self setTintColor:[UIColor colorWithRed:0.502 green:0.502 blue:0.502 alpha:1]];
        tabBarController.delegate = self;
        
    }
    return self;
}


-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
    if ([viewController.title isEqualToString:@"Player"]) {
        [self setTintColor:[UIColor soundzaOrange]];
    }
    else {
        [self setTintColor:[UIColor colorWithRed:0.502 green:0.502 blue:0.502 alpha:1]];
    }
}

-(void)applicationWillEnterForeground:(NSNotification *)notification {
    
    [self toggleSpinner];
}

-(void)updatedPlayer:(NSNotification *)notification {
    
    [self toggleSpinner];
}

-(void)toggleSpinner {
    BOOL playerIsPlaying = [PlayerManager sharedManager].playerIsPlaying;
    if (playerIsPlaying) {
        [self rotate360WithDuration];
    }
    else {
        [self stopAllAnimations];
    }

}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
