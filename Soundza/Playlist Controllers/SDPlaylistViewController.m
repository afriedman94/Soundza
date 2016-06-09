//
//  SDPlaylistViewController.m
//  Soundza
//
//  Created by Andrew Friedman on 9/7/15.
//  Copyright (c) 2015 Andrew Friedman. All rights reserved.
//

#import "SDPlaylistViewController.h"
#import "PlaylistManager.h"
#import "SDPlaylistTableViewCell.h"
#import "PlayerManager.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "iRate.h"
#import "SDSettingsNotificationManager.h"

static NSString *const KTableViewReuseIdentitifer = @"Playlist";
static NSString *const kPlaylistAdBannerId = @"ca-app-pub-9029083903735558/8545746621";

@interface SDPlaylistViewController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cogBarButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *tracks;
@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editBarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *renameBarButton;
@property (strong, nonatomic) RLMArray *RLMTracks;
@property (assign, nonatomic) BOOL editSelected;
@property (strong, nonatomic) IBOutlet GADBannerView *bannerView;
- (IBAction)editBarButtonPressed:(id)sender;
- (IBAction)renameBarButtonPressed:(id)sender;
- (IBAction)playlistNavButtonPressed:(id)sender;
@end

@implementation SDPlaylistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [self.tableView setEditing:YES];
    self.tableView.allowsSelectionDuringEditing = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if ([SDSettingsNotificationManager userHasTappedNotification]) {
        self.cogBarButton.image = [[UIImage imageNamed:@"Orange-Cog.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    else {
        self.cogBarButton.image = [[UIImage imageNamed:@"Notification-Cog.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    }
    
    self.editBarButton.tintColor = [UIColor colorWithRed:0.981 green:0.347 blue:0 alpha:1];
    self.renameBarButton.tintColor = [UIColor colorWithRed:0.981 green:0.347 blue:0 alpha:1];
    
    self.navigationItem.title = [PlaylistManager sharedManager].playlist.title;
    
    [self parseTracksReloadTableView];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(trackSavedNotification:) name:@"songSaved" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playerUpdatedNotification:) name:@"updatedPlayer" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playlistUpdatedNotification:) name:@"playlistUpdated" object:nil];

}

#pragma mark - Notification Center

-(void)playerUpdatedNotification:(NSNotification *)notification
{
    [self.tableView reloadData];
}

-(void)playlistUpdatedNotification:(NSNotification *)notification
{
    [self parseTracksReloadTableView];
    self.navigationItem.title = [PlaylistManager sharedManager].playlist.title;
}

-(void)trackSavedNotification:(NSNotification *)notification
{
    [self parseTracksReloadTableView];
    
    //If the user is playing from the playlist and has updated the playist, make sure to reasign the tracks so they are updated
    if ([PlayerManager sharedManager].playingFromPlaylist) {
        [PlayerManager sharedManager].playlist = self.tracks;
        [[PlayerManager sharedManager]updateShuffleIfNeeded];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.tracks.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SDPlaylistTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KTableViewReuseIdentitifer];
    SDTrack *track = self.tracks[indexPath.row];
    cell.playlistDelegate = self;
    [cell setupDisplayForTrack:track];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[PlayerManager sharedManager]playPlaylistTracks:self.tracks beginingAtIndex:indexPath.row];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.tracks removeObjectAtIndex:indexPath.row];
        
        RLMRealm *defaultRealm = [RLMRealm defaultRealm];
        [defaultRealm beginWriteTransaction];
        [self.RLMTracks removeObjectAtIndex:indexPath.row];
        [defaultRealm commitWriteTransaction];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editSelected) {
        return UITableViewCellEditingStyleDelete;
    }
    else {
    return UITableViewCellEditingStyleNone;
    }
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSDictionary *track = [self.tracks objectAtIndex:sourceIndexPath.row];
    [self.tracks removeObjectAtIndex:sourceIndexPath.row];
    [self.tracks insertObject:track atIndex:destinationIndexPath.row];
    
    RLMRealm *defaultRealm = [RLMRealm defaultRealm];
    [defaultRealm beginWriteTransaction];
    RLMTrack *rlmtrack = [self.RLMTracks objectAtIndex:sourceIndexPath.row];
    [self.RLMTracks removeObjectAtIndex:sourceIndexPath.row];
    [self.RLMTracks insertObject:rlmtrack atIndex:destinationIndexPath.row];
    [defaultRealm commitWriteTransaction];
    
    [self.tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        if (self.editSelected)
            return YES;
        else
            return NO;
    }
    else
        return NO;
}


-(NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if( sourceIndexPath.section != proposedDestinationIndexPath.section )
        return [NSIndexPath indexPathForRow:0 inSection:1];
    else
        return proposedDestinationIndexPath;
}

#pragma mark - SDPlaylistCellDelegate

-(void)longPressOnCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    SDTrack *selectedTrack = self.tracks[indexPath.row];
    [[PlayerManager sharedManager]enqueueTrack:selectedTrack];
}

#pragma mark - Buttons
- (IBAction)settingsCogPressed:(UIBarButtonItem *)sender {
    
    if (![SDSettingsNotificationManager userHasTappedNotification]) {
        [SDSettingsNotificationManager setNotificationHidden:YES];
        self.cogBarButton.image = [[UIImage imageNamed:@"Orange-Cog.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    [self performSegueWithIdentifier:@"toSettingsVC" sender:nil];
}

- (IBAction)editBarButtonPressed:(id)sender
{
    if (self.editSelected) {
        self.editBarButton.title = @"Edit";
        self.editSelected = NO;
        [self.tableView reloadData];
    }
    else{
        self.editBarButton.title = @"Done";
        self.editSelected = YES;
        [self.tableView reloadData];
    }
}

- (IBAction)renameBarButtonPressed:(id)sender
{
    
    //Create an alert controller for renaming the playlist, bunch of bull
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:@"Enter New Playlist Title"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         [textField addTarget:self
                       action:@selector(alertTextFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
     }];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       UITextField *textField = alertController.textFields.firstObject;
                                       [textField resignFirstResponder];
                                   }];
    UIAlertAction *doneAction = [UIAlertAction
                                 actionWithTitle:@"Done"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action)
                                 {
                                     UITextField *textField = alertController.textFields.firstObject;
                                     NSString *newTitle = textField.text;
                                     self.navigationItem.title = newTitle;
                                     [[PlaylistManager sharedManager]renameCurrentPlaylist:newTitle];
                                     [textField resignFirstResponder];
                                     
                                 }];
    doneAction.enabled = NO;
    [alertController addAction:cancelAction];
    [alertController addAction:doneAction];
    
    [self presentViewController:alertController animated:YES completion:nil];

}

- (IBAction)playlistNavButtonPressed:(id)sender
{
    [self performSegueWithIdentifier:@"toPlaylistsVC" sender:nil];
}

#pragma mark - Alert Controller

-(void)alertTextFieldDidChange:(UITextField *)textField
{
    
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController)
    {
        UITextField *textField = alertController.textFields.firstObject;
        UIAlertAction *doneAction = alertController.actions.lastObject;
        doneAction.enabled = textField.text.length > 0;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString *newTitle = [alertView textFieldAtIndex:0].text;
        self.navigationItem.title = newTitle;
        [[PlaylistManager sharedManager]renameCurrentPlaylist:newTitle];
    }
}

#pragma mark - Local Methods

-(void)parseTracksReloadTableView
{
    self.RLMTracks = [PlaylistManager sharedManager].playlist.tracks;
    [[PlaylistManager sharedManager]parseTracks:self.RLMTracks withCompletion:^(NSArray *parsedTracks) {
        self.tracks = [parsedTracks mutableCopy];
        self.tableView.hidden = !self.tracks.count;
        [self.tableView reloadData];
        [self setupAdBanner];
    }];

}

-(void)setupAdBanner{
    
    self.bannerView.adUnitID = kPlaylistAdBannerId;
    self.bannerView.rootViewController = self;
    GADRequest *request = [GADRequest request];
    [self.bannerView loadRequest:request];
    
}



-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
