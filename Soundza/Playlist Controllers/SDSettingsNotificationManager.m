//
//  SDSettingsNotificationManager.m
//  Soundza
//
//  Created by Andrew Friedman on 6/8/16.
//  Copyright © 2016 Andrew Friedman. All rights reserved.
//

#import "SDSettingsNotificationManager.h"

static NSString *const kCogAlertTapped = @"AlertTapped1";

@implementation SDSettingsNotificationManager

+(BOOL)userHasTappedNotification;
{
    return [[NSUserDefaults standardUserDefaults]boolForKey:kCogAlertTapped];
}

+(void)setNotificationHidden:(BOOL)hidden
{
    [[NSUserDefaults standardUserDefaults]setBool:hidden forKey:kCogAlertTapped];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

@end