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

static NSString *const kResultsAdBannerId = @"ca-app-pub-9029083903735558/4036651825";

@interface SDSearchResultsViewController ()
@property (strong, nonatomic) IBOutlet GADBannerView *bannerView;
@property (strong, nonatomic) IBOutlet UIView *containerView;

@end

@implementation SDSearchResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupAdBanner];
    
     self.navigationItem.title = self.genreString ? self.genreString : self.searchString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)setupAdBanner{
    
    self.bannerView.adUnitID = kResultsAdBannerId;
    self.bannerView.rootViewController = self;
    GADRequest *request = [GADRequest request];
    [self.bannerView loadRequest:request];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"EmbedSegue"]) {
        SDSearchResultsTableViewController *embed = segue.destinationViewController;
        embed.genreString = self.genreString;
        embed.searchString = self.searchString;
    }
}


@end
