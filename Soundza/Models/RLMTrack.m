//
//  RLMTrack.m
//  Soundza
//
//  Created by Andrew Friedman on 9/7/15.
//  Copyright (c) 2015 Andrew Friedman. All rights reserved.
//

#import "RLMTrack.h"

@implementation RLMTrack

//Required as of Realm .96 - A migration will probably be necessary in the future if project is expanded.
+ (NSArray *)requiredProperties {
    return @[@"titleString", @"createdAt", @"usernameString", @"streamURLString", @"artworkURLString"];
}
@end
