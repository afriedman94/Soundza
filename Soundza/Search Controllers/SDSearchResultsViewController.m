//
//  SDSearchResultsViewController.m
//  Soundza
//
//  Created by Andrew Friedman on 6/7/16.
//  Copyright © 2016 Andrew Friedman. All rights reserved.
//

#import "SDSearchResultsViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "SDSearchResultsTableViewController.h"
#import "SDAdMobConfigurer.h"

static NSString *const kResultsAdBannerId = @"ca-app-pub-9029083903735558/4036651825";

@interface SDSearchResultsViewController () <SKPaymentTransactionObserver>
@property (strong, nonatomic) IBOutlet GADBannerView *bannerView;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *containerViewYConst;

@end

@implementation SDSearchResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.navigationItem.title = self.genreString ? self.genreString : self.searchString;
    
    [self setupAdBanner];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"EmbedSegue"]) {
        SDSearchResultsTableViewController *embed = segue.destinationViewController;
        embed.genreString = self.genreString;
        embed.searchString = self.searchString;
    }
}

#pragma mark - Ads

-(void)setupAdBanner{
    
    BOOL adsAreRemoved = [SDAdMobConfigurer configureBanner:self.bannerView withId:kResultsAdBannerId forController:self];
    if (adsAreRemoved) {
        self.containerViewYConst.constant = 0;
    }
    else {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
}

-(void)hideBanner {
    self.bannerView.hidden = true;
    self.containerViewYConst.constant = 0;
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for(SKPaymentTransaction *transaction in transactions){
        switch(transaction.transactionState){
            case SKPaymentTransactionStatePurchased:
                NSLog(@"Transaction state -> Purchased");
                [self hideBanner];
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Transaction state -> Restored");
                [self hideBanner];
                break;
        }
    }
}

-(void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}


@end
