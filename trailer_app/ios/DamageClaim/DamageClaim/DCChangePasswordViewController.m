//
//  DCResetPasswordViewController.m
//  DamageClaim
//
//  Created by Dev on 03/10/12.
//
//

#import "DCChangePasswordViewController.h"

#import "Const.h"

#import "DCSharedObject.h"

#import "JSONKit.h"

@interface DCChangePasswordViewController ()
@property (retain, nonatomic) IBOutlet UIView *parentView;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) NSString *oldPassword;
@property (retain, nonatomic) NSString *enteredNewPassword;
@property (retain, nonatomic) NSString *confirmNewPassword;
@property (retain, nonatomic) HTTPService *httpService;
@property (nonatomic) NSInteger httpStatusCode;

- (IBAction)submit:(id)sender;
-(void) customizeNavigationBar;
-(BOOL) isEmpty:(NSString *)string;
-(void) parseResponse:(NSString *)reponseString forIdentifier:(NSString *)identifier;
@end

@implementation DCChangePasswordViewController
@synthesize tableView = _tableView;
@synthesize oldPassword = _oldPassword;
@synthesize enteredNewPassword = _enteredNewPassword;
@synthesize confirmNewPassword = _confirmNewPassword;
@synthesize httpService = _httpService;
@synthesize httpStatusCode = _httpStatusCode;

#pragma mark - View LifeCycle methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self customizeNavigationBar];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_tableView release];
    [_oldPassword release];
    [_enteredNewPassword release];
    [_confirmNewPassword release];
    [_parentView release];
    [_httpService release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setParentView:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [super viewDidUnload];
}

#pragma mark - Others

-(void) keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //get the parent view's currrent frame and change it
    CGRect newFrame = self.parentView.frame;
    newFrame.origin.y -=keyboardSize.height / 3;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.25];
    [self.parentView setFrame:newFrame];
    [UIView commitAnimations];
    
}

-(void) keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //get the parent view's currrent frame and change it
    CGRect newFrame = self.parentView.frame;
    newFrame.origin.y +=keyboardSize.height / 3;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.25];
    [self.parentView setFrame:newFrame];
    [UIView commitAnimations];
}


- (IBAction)submit:(id)sender {
    if (![self isEmpty:self.oldPassword] && ![self isEmpty:self.enteredNewPassword] && ![self isEmpty:self.confirmNewPassword]) {
        //if the password is already stored, compare against it else send the users password 
        if ([[NSUserDefaults standardUserDefaults] valueForKey:PASSWORD]) {
            NSString *storedPassword = [[NSUserDefaults standardUserDefaults] valueForKey:PASSWORD];
            if (![storedPassword isEqualToString:self.oldPassword]) {
                [self showAlertWithMessage:NSLocalizedString(@"WRONG_OLD_PASSWORD", @"")];
                return;
            }
            if (![self.enteredNewPassword isEqualToString:self.confirmNewPassword]) {
                [self showAlertWithMessage:NSLocalizedString(@"NEW_PASSWORD_MISMATCH", @"")];
                return;
            }
            
            NSDictionary *bodyDict = [NSDictionary dictionaryWithObjectsAndKeys:self.enteredNewPassword, @"newpassword", nil];
            [DCSharedObject makeURLCALLWithHTTPService:self.httpService extraHeaders:nil bodyDictionary:bodyDict identifier:AUTHENTICATE_CHANGEPW requestMethod:kRequestMethodPUT model:AUTHENTICATE delegate:self viewController:self];
        }
    } else {
        [self showAlertWithMessage:NSLocalizedString(@"EMPTY_FIELDS", @"")];
        return;
    }
    
}


-(void) customizeNavigationBar {
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
}

-(BOOL) isEmpty:(NSString *)string {
    NSCharacterSet *whiteSpaces = [NSCharacterSet whitespaceCharacterSet];
    NSString *validatedString = [string stringByTrimmingCharactersInSet:whiteSpaces];
    if ([validatedString length] == 0) {
        return YES;
    }
    return NO;
}

-(void) parseResponse:(NSString *)reponseString forIdentifier:(NSString *)identifier {
    
    if (reponseString) {
        if ([identifier isEqualToString:AUTHENTICATE_LOGOUT]) {
            if (self.navigationController) {
                [DCSharedObject hideProgressDialogInView:self.navigationController.view];
            } else {
                [DCSharedObject hideProgressDialogInView:self.view];
            }
            [DCSharedObject processLogout:self.navigationController clearData:NO];
            return;
        } else if ([identifier isEqualToString:AUTHENTICATE_CHANGEPW]) {
            NSDictionary *jsonDict = [reponseString objectFromJSONString];
            if ((NSNull *)[jsonDict valueForKey:SUCCESS] != [NSNull null]) {
                if ([(NSNumber *)[jsonDict valueForKey:SUCCESS] boolValue]) {
                    
                    [[NSUserDefaults standardUserDefaults] setValue:self.enteredNewPassword forKey:PASSWORD];
                    
                    [self showAlertWithMessage:NSLocalizedString(@"PASSWORD_CHANGE_SUCCESSFUL", @"")];
                } else if ((NSNull *)[jsonDict valueForKey:@"error"] != [NSNull null]) {
                    NSDictionary *errorDict = [jsonDict valueForKey:@"error"];
                    if ((NSNull *)[errorDict valueForKey:@"code"] != [NSNull null]) {
                        NSString *errorCode = [errorDict valueForKey:@"code"];
                        if ([errorCode isEqualToString:TIME_NOT_IN_SYNC]) {
                            if ((NSNull *)[errorDict valueForKey:@"time_difference"] != [NSNull null]) {
                                [[[DCSharedObject sharedPreferences] preferences] setValue:[errorDict valueForKey:@"time_difference"] forKey:TIME_DIFFERENCE];
                                //[[NSUserDefaults standardUserDefaults] setValue:[errorDict valueForKey:@"time_difference"] forKey:TIME_DIFFERENCE];
                                //timestamp is adjusted. call the same url again
                                [DCSharedObject makeURLCALLWithHTTPService:self.httpService
                                                              extraHeaders:nil bodyDictionary:[NSDictionary dictionaryWithObjectsAndKeys:self.enteredNewPassword, @"newpassword", nil]
                                                                identifier:AUTHENTICATE_CHANGEPW
                                                             requestMethod:kRequestMethodPUT
                                                                     model:AUTHENTICATE
                                                                  delegate:self
                                                            viewController:self];
                            }
                        } else {
                            [self showAlertWithMessage:NSLocalizedString(@"INTERNAL_SERVER_ERROR", @"")];
                        }
                    }
                } else {
                    [self showAlertWithMessage:NSLocalizedString(@"INTERNAL_SERVER_ERROR", @"")];
                }
            }
        }
    }
}

#pragma mark - UIAlertViewDelegate methods
-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [super alertView:alertView didDismissWithButtonIndex:buttonIndex];
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"LOGOUT", @"")]) {
        [DCSharedObject makeURLCALLWithHTTPService:self.httpService extraHeaders:nil body:nil identifier:AUTHENTICATE_LOGOUT requestMethod:kRequestMethodGET model:AUTHENTICATE delegate:self viewController:self];
    }
    
    if ([[alertView message] isEqualToString:NSLocalizedString(@"PASSWORD_CHANGE_SUCCESSFUL", @"")]) {
        [DCSharedObject processLogout:self.navigationController clearData:NO];
    }
}


#pragma mark - UITextFieldDelegate

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.tag == RESET_OLD_PASSWORD_TAG) {
#if kDebug
        NSLog(@"old password: %@", textField.text);
#endif
        
        //assign it to the model
        if (![self isEmpty:textField.text]) {
            self.oldPassword = textField.text;
            
        }
        UITextField *enteredPasswordTextField = (UITextField *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] viewWithTag:RESET_NEW_PASSWORD_TAG];
        [enteredPasswordTextField becomeFirstResponder];
    }
    
    if (textField.tag == RESET_NEW_PASSWORD_TAG) {
#if kDebug
        NSLog(@"new Password: %@", textField.text);
#endif
        //assign it to the model
        if (![self isEmpty:textField.text]) {
            self.enteredNewPassword = textField.text;
            
        }
        UITextField *confirmPasswordTextField = (UITextField *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] viewWithTag:RESET_CONFIRM_NEW_PASSWORD_TAG];
        [confirmPasswordTextField becomeFirstResponder];
    }
    
    if (textField.tag == RESET_CONFIRM_NEW_PASSWORD_TAG) {
#if kDebug
        NSLog(@"confirmed Password: %@", textField.text);
#endif
        //assign it to the model
        if (![self isEmpty:textField.text]) {
            self.confirmNewPassword = textField.text;
            
        }
        [textField resignFirstResponder];
    }
    return YES;
}


#pragma mark - HTTPServiceDelegate methods
-(void) responseCode:(int)code {
    self.httpStatusCode = code;
}

-(void) didReceiveResponse:(NSData *)data forIdentifier:(NSString *)identifier {
    
    NSString *responseString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
#if kDebug
    NSLog(@"%@", responseString);
#endif
    
    if (self.httpStatusCode == 200 || self.httpStatusCode == 403) {
        [self parseResponse:[DCSharedObject decodeSwedishHTMLFromString:responseString] forIdentifier:identifier];
    } else {
        if ([identifier isEqualToString:AUTHENTICATE_LOGOUT]) {
            if (self.navigationController) {
                [DCSharedObject hideProgressDialogInView:self.navigationController.view];
            } else {
                [DCSharedObject hideProgressDialogInView:self.view];
            }
            [DCSharedObject processLogout:self.navigationController clearData:NO];
            
        }
    }
    
    if (self.navigationController) {
        [DCSharedObject hideProgressDialogInView:self.navigationController.view];
    } else {
        [DCSharedObject hideProgressDialogInView:self.view];
    }

}

-(void) serviceDidFailWithError:(NSError *)error forIdentifier:(NSString *)identifier {
    if (self.navigationController) {
        [DCSharedObject hideProgressDialogInView:self.navigationController.view];
    } else {
        [DCSharedObject hideProgressDialogInView:self.view];
    }

    if ([error code] >= kNetworkConnectionError && [error code] <= kHostUnreachableError) {
        [self showAlertWithMessage:NSLocalizedString(@"NETWORK_ERROR", @"")];
    } else if ([identifier isEqualToString:AUTHENTICATE_LOGOUT]) {
        [DCSharedObject processLogout:self.navigationController clearData:NO];
        
    } else {
        [self showAlertWithMessage:NSLocalizedString(@"INTERNAL_SERVER_ERROR", @"")];
    }
    
}

-(void) storeResponse:(NSData *)data forIdentifier:(NSString *)identifier {
    
}



#pragma mark - UITableViewDataSource methods

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedString(@"RESET_PASSWORD", @"");
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *customCellTextFieldView = [[NSBundle mainBundle] loadNibNamed:@"CustomCellTextFieldView" owner:nil options:nil];
    if (customCellTextFieldView) {
        if ([customCellTextFieldView count] > 0) {
            UIView *view = [customCellTextFieldView objectAtIndex:0];
            return view.frame.size.height;
        }
    }
    return 0;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell) {
        NSArray *customCellTextFieldView = [[NSBundle mainBundle] loadNibNamed:@"CustomCellLoginView" owner:nil options:nil];
        if (customCellTextFieldView) {
            if ([customCellTextFieldView count] > 0) {
                cell = [customCellTextFieldView objectAtIndex:0];
                
            }
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UITextField *textField = (UITextField *)[cell viewWithTag:LOGIN_CUSTOM_CELL_TEXT_FIELD_TAG];
    textField.delegate = self;
    if (indexPath.row == 0) {
        textField.placeholder = NSLocalizedString(@"ENTER_OLD_PASSWORD", nil);
        textField.tag = RESET_OLD_PASSWORD_TAG;
        textField.secureTextEntry = YES;
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.returnKeyType = UIReturnKeyNext;
        
    } else if (indexPath.row == 1) {
        textField.secureTextEntry = YES;
        textField.placeholder = NSLocalizedString(@"ENTER_NEW_PASSWORD", nil);
        textField.tag = RESET_NEW_PASSWORD_TAG;
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.returnKeyType = UIReturnKeyNext;
        
    }  else if (indexPath.row == 2) {
        textField.secureTextEntry = YES;
        textField.placeholder = NSLocalizedString(@"CONFIRM_NEW_PASSWORD", nil);
        textField.tag = RESET_CONFIRM_NEW_PASSWORD_TAG;
        textField.clearButtonMode = UITextFieldViewModeAlways;
    }
    
    return cell;
}

@end
