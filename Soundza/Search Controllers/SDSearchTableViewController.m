//
//  SDSearchTableViewController.m
//  Soundza
//
//  Created by Andrew Friedman on 8/27/15.
//  Copyright (c) 2015 Andrew Friedman. All rights reserved.
//

#import "SDSearchTableViewController.h"
#import "SDSoundCloudAPI.h"
#import "SDSearchResultsTableViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "SDAdMobConfigurer.h"

static NSString *const KTableViewReuseIdentitifer = @"Cell";
static NSString *const kGenreAdBannerId = @"ca-app-pub-9029083903735558/6710916626";

@interface SDSearchTableViewController () <SKPaymentTransactionObserver>

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewYConst;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *generes;
@property (assign ,nonatomic) BOOL fromSearch;
@property (strong, nonatomic) IBOutlet GADBannerView *bannerView;
@end

@implementation SDSearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.generes = [SDSoundCloudAPI listOfGenres];
    self.searchBar.delegate = self;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self setupAdBanner];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.generes.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KTableViewReuseIdentitifer];
    NSString *genre = self.generes[indexPath.row];
    cell.textLabel.text = genre;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *genreSelected = self.generes[indexPath.row];
    self.fromSearch = NO;
    [self performSegueWithIdentifier:@"toResultsVC" sender:genreSelected];
}

#pragma mark - Search Bar Delegate / Data Source

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.fromSearch = YES;
    [searchBar resignFirstResponder];
    [self performSegueWithIdentifier:@"toResultsVC" sender:searchBar.text];
}


#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toResultsVC"]) {
        SDSearchResultsTableViewController *resultsVC = segue.destinationViewController;
        if (self.fromSearch) {
            resultsVC.searchString = sender;
            resultsVC.genreString = nil;
        }
        else{
            resultsVC.genreString = sender;
            resultsVC.searchString = nil;
        }
    }
}

#pragma mark - Ads


-(void)setupAdBanner{
    
    BOOL adsAreRemoved = [SDAdMobConfigurer configureBanner:self.bannerView withId:kGenreAdBannerId forController:self];
    if (adsAreRemoved) {
        self.tableViewYConst.constant = 0;
    }
    else {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
         [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userRatedAppRemoveAdsNotification:) name:@"RatedApp" object:nil];
    }
}

-(void)hideBanner {
    self.bannerView.hidden = true;
    self.tableViewYConst.constant = 0;
}

-(void)userRatedAppRemoveAdsNotification:(NSNotification *)notification
{
    [self hideBanner];
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
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"RatedApp" object:nil];
}


@end
