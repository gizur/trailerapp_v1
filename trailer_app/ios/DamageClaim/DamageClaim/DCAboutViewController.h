//
//  DCAboutViewController.h
//  DamageClaim
//
//  Created by Dev on 24/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCParentViewController.h"

@protocol DCAboutViewControllerDelegate <NSObject>

@required
-(void) aboutViewWillClose;

@end

@interface DCAboutViewController : DCParentViewController
@property (nonatomic, assign) id<DCAboutViewControllerDelegate> delegate;

@end
