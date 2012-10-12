//
//  DCResetPasswordViewController.h
//  DamageClaim
//
//  Created by Dev on 03/10/12.
//
//

#import "DCParentViewController.h"

#import "HTTPService.h"

@interface DCChangePasswordViewController : DCParentViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextFieldDelegate, HTTPServiceDelegate, UIAlertViewDelegate>

@end
