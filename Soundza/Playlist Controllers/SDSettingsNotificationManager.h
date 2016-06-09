//
//  SDSettingsNotificationManager.h
//  Soundza
//
//  Created by Andrew Friedman on 6/8/16.
//  Copyright © 2016 Andrew Friedman. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SDSettingsNotificationManager : NSObject
+(BOOL)userHasTappedNotification;
+(void)setNotificationHidden:(BOOL)hidden;
@end
