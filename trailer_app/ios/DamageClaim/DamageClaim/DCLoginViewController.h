//
//  DCLoginViewController.h
//  DamageClaim
//
//  Created by Dev on 13/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPService.h"
#import "DCAboutViewController.h"
#import "DCParentViewController.h"

@interface DCLoginViewController : DCParentViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, HTTPServiceDelegate, DCAboutViewControllerDelegate, UIAlertViewDelegate>


@end
