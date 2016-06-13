//
//  SDTabBarViewController.h
//  Soundza
//
//  Created by Andrew Friedman on 8/27/15.
//  Copyright (c) 2015 Andrew Friedman. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SDTabBarDelegate <NSObject>
-(void)tabBarDidSelectItem:(UITabBarItem *)item;
@end

@interface SDTabBarViewController : UITabBarController

@property (weak, nonatomic) id<SDTabBarDelegate> tabDelegate;

@end
