//
//  DCParentViewController.h
//  DamageClaim
//
//  Created by Dev on 03/10/12.
//
//

#import <UIKit/UIKit.h>

@interface DCParentViewController : UIViewController<UIAlertViewDelegate>

@property (nonatomic, getter = isAlertViewShown) BOOL alertViewShown;

-(void)showAlertWithMessage:(NSString *)alertMessage;
-(void) handleNotification:(NSNotification *)notification;

@end
