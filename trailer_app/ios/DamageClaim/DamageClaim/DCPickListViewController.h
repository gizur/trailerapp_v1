//
//  DCPickListViewController.h
//  DamageClaim
//
//  Created by Dev on 14/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HTTPService.h"

#import "DCParentViewController.h"

@protocol DCPickListViewControllerDelegate <NSObject>

@required
-(void) pickListDidPickItem:(id) item ofType:(NSInteger) type;
-(void) pickListDidPickItems:(NSArray *)items ofType:(NSInteger)type;

@end

@interface DCPickListViewController : DCParentViewController<UITableViewDelegate, UITableViewDataSource, HTTPServiceDelegate, UIAlertViewDelegate>
@property (assign, nonatomic) id<DCPickListViewControllerDelegate> delegate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil modelArray:(NSArray *)modelArrayOrNil storageKey:(NSString *)key isSingleValue:(BOOL) singleValue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil modelArray:(NSArray *)modelArrayOrNil type:(NSInteger)type isSingleValue:(BOOL) singleValue;

@end
