//
//  DCImageViewerViewController.h
//  DamageClaim
//
//  Created by Dev on 03/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCParentViewController.h"

@interface DCImageViewerViewController : DCParentViewController<UIScrollViewDelegate>

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil image:(UIImage *)image;

@end
