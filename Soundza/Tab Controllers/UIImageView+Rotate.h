//
//  UIImageView+Rotate.h
//  TuneSnap
//
//  Created by Andrew Friedman on 7/21/15.
//  Copyright (c) 2015 Andrew Friedman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Rotate)
- (void)rotate360WithDuration;
- (void)pauseAnimations;
- (void)resumeAnimations;
- (void)stopAllAnimations;
@end
