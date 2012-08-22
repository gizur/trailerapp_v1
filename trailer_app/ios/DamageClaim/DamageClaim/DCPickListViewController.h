//
//  DCPickListViewController.h
//  DamageClaim
//
//  Created by Dev on 14/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCPickListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil modelArray:(NSArray *)modelArray storageKey:(NSString *)key;

@end
