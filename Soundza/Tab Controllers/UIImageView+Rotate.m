//
//  UIImageView+Rotate.m
//  TuneSnap
//
//  Created by Andrew Friedman on 7/21/15.
//  Copyright (c) 2015 Andrew Friedman. All rights reserved.
//

#import "UIImageView+Rotate.h"

@implementation UIImageView (Rotate)

- (void)rotate360WithDuration {
    
    CABasicAnimation *fullRotation;
    fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    fullRotation.fromValue = [NSNumber numberWithFloat:0];
    fullRotation.toValue = [NSNumber numberWithFloat:(2*M_PI)];
    fullRotation.speed = .1f;
    fullRotation.repeatCount = MAXFLOAT;
    [self.layer addAnimation:fullRotation forKey:@"360"];
}

- (void)pauseAnimations;
{
    CFTimeInterval pausedTime = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    self.layer.speed = 0.0;
    self.layer.timeOffset = pausedTime;
}

- (void)resumeAnimations;
{
    CFTimeInterval pausedTime = [self.layer timeOffset];
    self.layer.speed = 1.0;
    self.layer.timeOffset = 0.0;
    self.layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    self.layer.beginTime = timeSincePause;
}

- (void)stopAllAnimations
{
    [self.layer removeAllAnimations];
}
@end
