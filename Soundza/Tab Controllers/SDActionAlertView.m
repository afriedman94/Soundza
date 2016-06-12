//
//  SAActionAlertView.m
//  StreamacyBeta
//
//  Created by Andrew Friedman on 6/28/15.
//  Copyright (c) 2015 Andrew Friedman. All rights reserved.
//

#import "SDActionAlertView.h"

@implementation SDActionAlertView


typedef enum {
    Saved = 0,
    Queued
}AlertType;

-(id)initWithTitle:(NSString *)title;
{
    self = [super init];
    if (self){

        self.frame = CGRectMake(0, 0, 170, 170);
        UIImageView *checkImage = [[UIImageView alloc]initWithFrame:CGRectMake(41, 25, 87, 69)];
        [checkImage setImage:[UIImage imageNamed:@"CheckMark.png"]];
        UILabel *alertLabel = [UILabel new];
        alertLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold"size: 22.0 ];
        alertLabel.textColor = [UIColor whiteColor];
        alertLabel.frame = CGRectMake(14, 114, 143, 31);
        alertLabel.text = title;
        alertLabel.textAlignment = NSTextAlignmentCenter;
        alertLabel.center = CGPointMake(85, 130);
        [self addSubview:checkImage];
        [self addSubview:alertLabel];
        self.backgroundColor = [UIColor colorWithRed:0.545 green:0.545 blue:0.545 alpha:.95];
        self.layer.cornerRadius = 15;
        
    }
    return self;
}

-(void)animate;
{
    self.center = self.superview.center;
    self.transform = CGAffineTransformMakeScale(0.01, 0.01);
    
    [UIView animateWithDuration:0.20 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
        
        CGPoint center = self.center;
        center.y += 30;
        [UIView animateWithDuration:.10 delay:1.25 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.alpha = .20;
            self.center = center;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }];
}

@end
