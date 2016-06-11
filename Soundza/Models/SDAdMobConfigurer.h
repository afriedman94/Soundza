//
//  SDAdMobConfigurer.h
//  Soundza
//
//  Created by Andrew Friedman on 6/10/16.
//  Copyright © 2016 Andrew Friedman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface SDAdMobConfigurer : NSObject
+(BOOL)configureBanner:(GADBannerView *)bannerView withId:(NSString *)Id forController:(UIViewController *)viewController;
@end
