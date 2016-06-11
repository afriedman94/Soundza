//
//  SDAdMobConfigurer.m
//  Soundza
//
//  Created by Andrew Friedman on 6/10/16.
//  Copyright © 2016 Andrew Friedman. All rights reserved.
//

#import "SDAdMobConfigurer.h"
#import "SDPaymentManager.h"

@implementation SDAdMobConfigurer

/**
    Configures a banner view for the appropriate view controller.
    
    Returns - True if ads are enabled, False if ads are removed.
 */
+(BOOL)configureBanner:(GADBannerView *)bannerView withId:(NSString *)Id forController:(UIViewController *)viewController {
    
    if ([[SDPaymentManager sharedInstance]adsAreRemoved]){
        bannerView.hidden = true;
        return true;
    }
    else {
        bannerView.adUnitID = Id;
        bannerView.rootViewController = viewController;
        GADRequest *request = [GADRequest request];
        [bannerView loadRequest:request];
    }
    
    return false;
}
@end
