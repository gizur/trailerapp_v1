//
//  DCDamageDetailViewController.h
//  DamageClaim
//
//  Created by Dev on 13/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DCPickListViewController.h"

#import "DCDamageDetailModel.h"

#import "HTTPService.h"

@interface DCDamageDetailViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DCPickListViewControllerDelegate, HTTPServiceDelegate>

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil damageDetailModel:(DCDamageDetailModel *)damageDetailModelOrNil;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil damageDetailModel:(DCDamageDetailModel *)damageDetailModelOrNil isEditable:(BOOL) isEditable;

@end
