//
//  SDPlaylistsViewController.m
//  Soundza
//
//  Created by Andrew Friedman on 9/9/15.
//  Copyright (c) 2015 Andrew Friedman. All rights reserved.
//

#import "SDPlaylistsViewController.h"
#import "SDPlaylistsTableViewCell.h"
#import "PlaylistManager.h"
#import "SDCreatePlaylistTableViewCell.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

static NSString *const KTableViewReuseIdentitifer = @"Playlists";
static NSString *const KTableViewNewReuseIdentitifer = @"New";
static NSString *const kPlaylistsAdBannerId = @"ca-app-pub-9029083903735558/9743278227";


@interface SDPlaylistsViewController ()
@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editBarButton;
@property (assign, nonatomic) BOOL editSelected;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet GADBannerView *bannerView;
@property (strong, nonatomic) UITextField *createTextField;
- (IBAction)backBarButtonPressed:(id)sender;
- (IBAction)editButtonPressed:(id)sender;

@property (strong, nonatomic) RLMResults *playlists;
@end

@implementation SDPlaylistsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.navBar.tintColor = [UIColor colorWithRed:0.981 green:0.347 blue:0 alpha:1];
    
    RLMResults *playlists = [[RLMPlaylist allObjects]sortedResultsUsingProperty:@"createdAt" ascending:YES];
    self.playlists = playlists;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupAdBanner];
}

#pragma mark - UITableView Delegate/Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    else
        return self.playlists.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        SDPlaylistsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KTableViewReuseIdentitifer];
        RLMPlaylist *playlist = self.playlists[indexPath.row];
        [cell setupDisplayForPlaylist:playlist];
        return cell;

    }
    else{
        SDCreatePlaylistTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KTableViewNewReuseIdentitifer];
        cell.textField.delegate = self;
        cell.textField.tintColor = [UIColor colorWithRed:0.981 green:0.347 blue:0 alpha:1];
        return cell;

    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        SDCreatePlaylistTableViewCell *cell = (SDCreatePlaylistTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell.textField becomeFirstResponder];
    }
    else
    {
        RLMPlaylist *selectedPlaylist = self.playlists[indexPath.row];
        [[PlaylistManager sharedManager]switchCurrentWithPlaylist:selectedPlaylist];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.createTextField resignFirstResponder];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return NO;
    else
        return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        BOOL isCurrent = NO;
        
        RLMPlaylist *playlist = self.playlists[indexPath.row];
        
        //Check if the user is deleting the current playlist
        if ([playlist isEqualToObject:[PlaylistManager sharedManager].playlist]) {
            isCurrent = YES;
        }
        
        RLMRealm *defaultRealm = self.playlists.realm;
        [defaultRealm beginWriteTransaction];
        [defaultRealm deleteObject:playlist];
        [defaultRealm commitWriteTransaction];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        //User is deleting the current playist.
        if (isCurrent) {
            //If there is more than one playlist, make the first playlist current
            if (self.playlists.count > 1) {
                RLMPlaylist *playlist = self.playlists.firstObject;
                [PlaylistManager sharedManager].playlist = playlist;
                RLMRealm *defaultRealm = self.playlists.realm;
                [defaultRealm beginWriteTransaction];
                playlist.isCurrent = YES;
                [defaultRealm commitWriteTransaction];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"playlistUpdated" object:nil];
                [self.tableView reloadData];
            }
            //If there is only one playlist, create a new emtpy playlist
            else{
                [[PlaylistManager sharedManager]createNewPlaylistWithTitle:@"Playlist"];
                [self editButtonPressed:nil];
                [self.tableView reloadData];
            }
        }
        
    }
}

#pragma mark - UITextField Delegate

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.createTextField = textField;
    textField.text = nil;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.text = @"New Playlist";
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [[PlaylistManager sharedManager]createNewPlaylistWithTitle:textField.text];
    [textField resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
    return YES;
}


#pragma mark - Custom Buttons

- (IBAction)backBarButtonPressed:(id)sender
{
    [self.createTextField resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)editButtonPressed:(id)sender
{
    if (self.editSelected) {
        self.editBarButton.title = @"Edit";
        self.editSelected = NO;
        [self.tableView setEditing:NO animated:YES];
        
    }
    else{
        self.editBarButton.title = @"Done";
        self.editSelected = YES;
        [self.tableView setEditing:YES animated:YES];
    }

}

#pragma mark - Helpers

-(void)setupAdBanner{
    
    self.bannerView.adUnitID = kPlaylistsAdBannerId;
    self.bannerView.rootViewController = self;
    GADRequest *request = [GADRequest request];
    [self.bannerView loadRequest:request];
}

@end
