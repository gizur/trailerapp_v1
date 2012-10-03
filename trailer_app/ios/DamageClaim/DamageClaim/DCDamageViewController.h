//
//  DCDamageViewController.h
//  DamageClaim
//
//  Created by Dev on 18/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DCParentViewController.h"

@interface DCDamageViewController : DCParentViewController<UITableViewDelegate, UITableViewDataSource>


-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil reportedDamageDetails:(NSMutableArray *) reportedDamageDetailArrayOrNil;
@end
