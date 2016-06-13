//
//  SDTabBarViewController.m
//  Soundza
//
//  Created by Andrew Friedman on 8/27/15.
//  Copyright (c) 2015 Andrew Friedman. All rights reserved.
//

#import "SDTabBarViewController.h"
#import "SDActionAlertView.h"
#import "SDSpinningDiskImageView.h"

@interface SDTabBarViewController ()
@end

@implementation SDTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *viewControllers = [[NSMutableArray alloc]initWithCapacity:3];
    [viewControllers addObject:[[UIStoryboard storyboardWithName:@"Search" bundle:nil] instantiateInitialViewController]];
    [viewControllers addObject:[[UIStoryboard storyboardWithName:@"Player" bundle:nil] instantiateInitialViewController]];
    [viewControllers addObject:[[UIStoryboard storyboardWithName:@"Playlist" bundle:nil] instantiateInitialViewController]];

    [self setViewControllers:viewControllers];
    
    UIViewController *searchVC = viewControllers[0];
    UIImage *tab1Image = [UIImage imageNamed:@"Search.png"];
    UITabBarItem *item1 = [[UITabBarItem alloc]initWithTitle:nil image:tab1Image selectedImage:nil];
    item1.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    item1.tag = 0;
    searchVC.tabBarItem = item1;
    
    UIViewController *playerVC = viewControllers[1];
    SDSpinningDiskImageView *spinner = [[SDSpinningDiskImageView alloc]initWithTabBar:self];
    [self.tabBar addSubview:spinner];
    UITabBarItem *item2 = [[UITabBarItem alloc]initWithTitle:nil image:nil selectedImage:nil];
    item2.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    item1.tag = 1;
    playerVC.tabBarItem = item2;

    UIViewController *playlistVC = viewControllers[2];
    UIImage *tab3Image = [UIImage imageNamed:@"Playlists.png"];
    UITabBarItem *item3 = [[UITabBarItem alloc]initWithTitle:nil image:tab3Image selectedImage:nil];
    item3.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    item1.tag = 2;
    playlistVC.tabBarItem = item3;

    //Set the tint color to the SoundCloud orange
    [self.tabBar setTintColor:[UIColor colorWithRed:0.981 green:0.347 blue:0 alpha:1]];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(songQueuedNotification:) name:@"songQueued" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(songSavedNotification:) name:@"songSaved" object:nil];

}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    [self.tabDelegate tabBarDidSelectItem:item];
}


-(void)songSavedNotification:(NSNotification *)note
{
    
    SDActionAlertView *alert = [[SDActionAlertView alloc]initWithTitle:@"Song Saved"];
    [self.view addSubview:alert];
    [alert animate];
}

-(void)songQueuedNotification:(NSNotification *)note
{
    SDActionAlertView *alert = [[SDActionAlertView alloc]initWithTitle:@"Song Queued"];
    [self.view addSubview:alert];
    [alert animate];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
