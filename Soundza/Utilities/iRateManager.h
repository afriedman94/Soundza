//
//  iRateManager.h
//  Soundza
//
//  Created by Andrew Friedman on 6/7/16.
//  Copyright © 2016 Andrew Friedman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iRate.h"

@interface iRateManager : NSObject <iRateDelegate>

@property (strong, nonatomic) iRate* sharedInstance;

+(void)setUp;

@end
