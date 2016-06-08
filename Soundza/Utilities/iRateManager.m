//
//  iRateManager.m
//  Soundza
//
//  Created by Andrew Friedman on 6/7/16.
//  Copyright © 2016 Andrew Friedman. All rights reserved.
//

#import "iRateManager.h"

@implementation iRateManager

+(void)setUp {
    
    //overriding the default iRate strings
    [iRate sharedInstance].messageTitle = @"Enjoying Soundza?";
    [iRate sharedInstance].message = @"If so, please rate in the App Store. It takes less than a minute and we appreciate the support!";
    [iRate sharedInstance].cancelButtonLabel = @"No Thanks";
    [iRate sharedInstance].remindButtonLabel = @"Remind Me Later";
    [iRate sharedInstance].rateButtonLabel = @"Okay, Sure";
    
    [iRate sharedInstance].applicationBundleID = @"SD.Soundza";
    
    [iRate sharedInstance].daysUntilPrompt = 4;
    [iRate sharedInstance].usesUntilPrompt = 7;
    [iRate sharedInstance].daysUntilPrompt = 5;
    
    //Remove for deployment
    [iRate sharedInstance].previewMode = YES;
}
@end
