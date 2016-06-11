//
//  SDPaymentManager.h
//  Soundza
//
//  Created by Andrew Friedman on 6/10/16.
//  Copyright © 2016 Andrew Friedman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@protocol SDPaymentManagerDelegate <NSObject>
-(void)purchaseStateDidChange:(SKPaymentTransactionState)state;
@end

static NSString *const kRemoveAdsProductIdentifier;

@interface SDPaymentManager : NSObject

@property (weak, nonatomic) id<SDPaymentManagerDelegate> delegate;

+(SDPaymentManager *)sharedInstance;
-(void)beginRemovingAds;
-(void)beginRestoringAds;
-(BOOL)adsAreRemoved;
@end
