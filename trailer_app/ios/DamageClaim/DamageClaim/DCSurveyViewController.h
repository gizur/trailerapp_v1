//
//  DCSurveyViewController.h
//  DamageClaim
//
//  Created by Dev on 13/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCPickListViewController.h"
#import "HTTPService.h"

@interface DCSurveyViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, DCPickListViewControllerDelegate, HTTPServiceDelegate>

@end
