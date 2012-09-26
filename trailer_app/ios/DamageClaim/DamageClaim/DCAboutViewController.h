//
//  DCAboutViewController.h
//  DamageClaim
//
//  Created by Dev on 24/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DCAboutViewControllerDelegate <NSObject>

@required
-(void) aboutViewWillClose;

@end

@interface DCAboutViewController : UIViewController
@property (nonatomic, assign) id<DCAboutViewControllerDelegate> delegate;

@end
