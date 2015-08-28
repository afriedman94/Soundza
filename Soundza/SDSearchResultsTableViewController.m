//
//  SDSearchResultsTableViewController.m
//  
//
//  Created by Andrew Friedman on 8/27/15.
//
//

#import "SDSearchResultsTableViewController.h"
#import "SDSearchResultsTableViewCell.h"
#import "SDSoundCloudAPI.h"
#import "SDTrack.h"

static NSString *const KSearchResultsTableViewCellReuseID = @"Results";

@interface SDSearchResultsTableViewController ()
@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) UIRefreshControl *refreshController;
@end

@implementation SDSearchResultsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchResults = [[NSArray alloc]init];
    
    self.navigationItem.title = self.genreString ? self.genreString : self.searchString;
    
    self.refreshController = [[UIRefreshControl alloc]init];
    [self setRefreshControl:self.refreshController];
    [self.refreshController addTarget:self action:@selector(refreshControlActivated:) forControlEvents:UIControlEventValueChanged];
    
     [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y-self.refreshControl.frame.size.height) animated:YES];
    [self populateDataSource];
}

-(void)refreshControlActivated:(UIRefreshControl *)refreshControl
{
    [self populateDataSource];
}

#pragma mark - Table view data source

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @" ";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SDSearchResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KSearchResultsTableViewCellReuseID forIndexPath:indexPath];
    SDTrack *track = self.searchResults[indexPath.row];
    [cell setDisplayForTrack:track];
    return cell;
}

-(void)populateDataSource
{
    
    [self.refreshController beginRefreshing];
    
    //if the user is searching by genre, else, search by search text field
    if (self.genreString) {
        [[SDSoundCloudAPI sharedManager]getTracksForGenre:self.genreString withCompletion:^(NSArray *tracks, BOOL error) {
            if (!error) {
                [[SDSoundCloudAPI sharedManager]parseTracks:tracks withCompletion:^(NSArray *parsedTracks) {
                    self.searchResults = parsedTracks;
                    [self.refreshController endRefreshing];
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                }];
            }
        }];
    }
    else{
        [SDSoundCloudAPI getTracksWithSearch:self.searchString withCompletion:^(NSMutableArray *tracks, BOOL error) {
            if (!error) {
                [[SDSoundCloudAPI sharedManager]parseTracks:tracks withCompletion:^(NSArray *parsedTracks) {
                    self.searchResults = parsedTracks;
                    [self.refreshController endRefreshing];
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                }];
            }
        }];
    }
    
}

@end