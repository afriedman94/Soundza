//
//  SDSpinningDiskImageView.h
//  Soundza
//
//  Created by Andrew Friedman on 6/12/16.
//  Copyright © 2016 Andrew Friedman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDSpinningDiskImageView : UIImageView <UITabBarControllerDelegate>
-(id)initWithTabBar:(UITabBarController *)tabBar;
@end
