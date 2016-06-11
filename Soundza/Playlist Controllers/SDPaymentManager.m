//
//  SDPaymentManager.m
//  Soundza
//
//  Created by Andrew Friedman on 6/10/16.
//  Copyright © 2016 Andrew Friedman. All rights reserved.
//

#import "SDPaymentManager.h"
#import <StoreKit/StoreKit.h>

static NSString *const kRemoveAdsProductIdentifier = @"com.soundza.removeAdsPurchase";

@interface SDPaymentManager () <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@end

@implementation SDPaymentManager

+(SDPaymentManager *)sharedInstance {
    
    static dispatch_once_t _once;
    static SDPaymentManager *sharedManager = nil;
    dispatch_once(&_once, ^{
        sharedManager = [[SDPaymentManager alloc] init];
    });
    return sharedManager;
}

-(BOOL)adsAreRemoved
{
    BOOL areAdsRemoved = [[NSUserDefaults standardUserDefaults] boolForKey:@"areAdsRemoved"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return areAdsRemoved;
}
-(void)beginRestoringAds
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

-(void)beginRemovingAds
{
    if([SKPaymentQueue canMakePayments]){
        NSLog(@"User can make payments");
        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:kRemoveAdsProductIdentifier]];
        productsRequest.delegate = self;
        [productsRequest start];
    }
    else{
        NSLog(@"User cannot make payments due to parental controls");
    }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    SKProduct *validProduct = nil;
    int count = [response.products count];
    if(count > 0){
        validProduct = [response.products objectAtIndex:0];
        NSLog(@"Products Available!");
        [self purchase:validProduct];
    }
    else if(!validProduct){
        NSLog(@"No products available");
        //this is called if your product id is not valid, this shouldn't be called unless that happens.
    }
}

- (void)purchase:(SKProduct *)product{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    for(SKPaymentTransaction *transaction in queue.transactions){
        if(transaction.transactionState == SKPaymentTransactionStateRestored){
            //called when the user successfully restores a purchase
            NSLog(@"Transaction state -> Restored");
            [self saveAdsRemoved];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for(SKPaymentTransaction *transaction in transactions){
        switch(transaction.transactionState){
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"Transaction state -> Purchasing");
                break;
            case SKPaymentTransactionStatePurchased:
                [self saveAdsRemoved];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [self.delegate purchaseStateDidChange:SKPaymentTransactionStatePurchased];
                NSLog(@"Transaction state -> Purchased");
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Transaction state -> Restored");
                [self saveAdsRemoved];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [self.delegate purchaseStateDidChange:SKPaymentTransactionStateRestored];
                break;
            case SKPaymentTransactionStateFailed:
                if(transaction.error.code == SKErrorPaymentCancelled){
                    NSLog(@"Transaction state -> Cancelled");
                    //the user cancelled the payment ;(
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
        }
    }
}

- (void)saveAdsRemoved{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"areAdsRemoved"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
