//
//  SDSettingsTableViewController.m
//  Soundza
//
//  Created by Andrew Friedman on 6/8/16.
//  Copyright © 2016 Andrew Friedman. All rights reserved.
//

#import "SDSettingsTableViewController.h"
#import <MessageUI/MessageUI.h>
#import "UIColor+SoundzaColors.h"
#import <StoreKit/StoreKit.h>
#import "SDPaymentManager.h"

@interface SDSettingsTableViewController () <SDPaymentManagerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *removeAdsLabel;
@property (strong, nonatomic) IBOutlet UILabel *restorePurchaseLabel;
@end

@implementation SDSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Settings";
    [SDPaymentManager sharedInstance].delegate = self;
    [self setDisplay];
    
}

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0 && ![[SDPaymentManager sharedInstance] adsAreRemoved]) {
        if(indexPath.row == 0){
            [[SDPaymentManager sharedInstance] beginRemovingAds];
        }
        else {
            [[SDPaymentManager sharedInstance] beginRestoringAds];
        }
    }
    else if (indexPath.section == 1) {
        NSLog(@"Rate");
        [self rateApp];
    }
    else if (indexPath.section == 2) {
        [self composeMail];
    }
    else if (indexPath.section == 3) {
        NSLog(@"Send to friend");
        [self shareToFriends];
    }
}

#pragma mark - Mail

-(void)composeMail {
    
    if (![MFMailComposeViewController canSendMail]) {
        NSLog(@"Mail services are not available.");
        [self showAlertWithTitle:@"Mail not available" message:@"Your iPhone must be configured to send mail in Settings"];
        return;
    }
    
    MFMailComposeViewController* composeVC = [[MFMailComposeViewController alloc] init];
    composeVC.mailComposeDelegate = self;
    [[composeVC navigationBar] setTintColor:[UIColor soundzaOrange]];
    
    // Configure the fields of the interface.
    [composeVC setToRecipients:@[@"soundzaapp@gmail.com"]];
    [composeVC setSubject:@"Feedback for Soundza App"];
    [composeVC setMessageBody:@"Hello Soundza Team, " isHTML:NO];
    
    // Present the view controller modally.
    [self presentViewController:composeVC animated:YES completion:nil];
}


- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Notifications

//Standard Alert
-(void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //code
    }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Set Display

-(void)setDisplay {
    
    if ([[SDPaymentManager sharedInstance] adsAreRemoved]) {
        self.removeAdsLabel.alpha = .5;
        self.restorePurchaseLabel.alpha = .5;
    }
}

#pragma mark - Sharing

-(void)shareToFriends {
    
    NSString *textToShare = @"Hey, check out this app!";
    NSURL *appStore = [NSURL URLWithString:@"https://geo.itunes.apple.com/us/app/soundza-free-music-streaming/id1043813927?mt=8"];
    
    NSArray *objectsToShare = @[textToShare, appStore];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark - In App Purchases

-(void)purchaseStateDidChange:(SKPaymentTransactionState)state {
    
    switch(state){
        case SKPaymentTransactionStatePurchased:
            [self setDisplay];
            break;
        case SKPaymentTransactionStateRestored:
            [self showAlertWithTitle:@"Success" message:@"Your ad removal purchase has been restored."];
            [self setDisplay];
            break;
    }
}

#pragma mark - Rate App

-(void)rateApp {
    
    NSString *appId = @"1043813927";
    NSString *urlString = [NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8", appId];
    NSURL *url = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:url];
}

@end
