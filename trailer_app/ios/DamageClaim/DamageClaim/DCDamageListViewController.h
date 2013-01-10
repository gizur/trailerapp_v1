//
//  DCDamageListViewController.h
//  DamageClaim
//
//  Created by Dev on 29/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HTTPService.h"
#import "DCParentViewController.h"

@interface DCDamageListViewController : DCParentViewController<UITableViewDelegate, UITableViewDataSource, HTTPServiceDelegate, UIAlertViewDelegate, UIAlertViewDelegate>

@end
