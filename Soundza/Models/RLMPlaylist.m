//
//  RLMPlaylist.m
//  Soundza
//
//  Created by Andrew Friedman on 9/7/15.
//  Copyright (c) 2015 Andrew Friedman. All rights reserved.
//

#import "RLMPlaylist.h"

@implementation RLMPlaylist

+ (NSArray *)requiredProperties {
    return @[@"title", @"createdAt"];
}
@end
