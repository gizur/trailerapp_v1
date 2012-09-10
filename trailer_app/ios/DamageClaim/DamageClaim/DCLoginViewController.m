//
//  DCLoginViewController.m
//  DamageClaim
//
//  Created by Dev on 13/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DCLoginViewController.h"

#import "Const.h"

#import "DCLoginModel.h"

#import "DCSharedObject.h"

#import "RequestHeaders.h"

#import "MBProgressHUD.h"

#import "JSONKit.h"

@interface DCLoginViewController ()
@property (retain, nonatomic) IBOutlet UIView *parentView;
@property (retain, nonatomic) IBOutlet UITableView *loginTableView;
@property (retain, nonatomic) IBOutlet UITableViewCell *customCellLoginView;
@property (retain, nonatomic) DCLoginModel *loginModel;
@property (nonatomic) NSInteger httpStatusCode;
@property (retain, nonatomic) HTTPService *httpService;

-(void) keyboardWillShow:(NSNotification *)notification;
-(void) keyboardWillHide:(NSNotification *)notification;
- (IBAction)login:(id)sender;
-(void) parseResponse:(NSString *)responseString forIdentifier:(NSString *)identifier;
-(BOOL) isEmpty:(NSString *)string;

@end

@implementation DCLoginViewController
@synthesize parentView = _parentView;
@synthesize loginTableView = _loginTableView;
@synthesize customCellLoginView = _customCellLoginView;
@synthesize loginModel = _loginModel;
@synthesize httpStatusCode = _httpStatusCode;
@synthesize httpService = _httpService;

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
    [self.navigationController setNavigationBarHidden:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    if (!self.loginModel) {
        self.loginModel = [[[DCLoginModel alloc] init] autorelease];
    }
    
    [self.loginTableView reloadData];
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:USER_NAME]) {
        UITextField *usernameTextField = (UITextField *)[[self.loginTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:LOGIN_USERNAME_TEXTFIELD_TAG];
        usernameTextField.text = [[NSUserDefaults standardUserDefaults] valueForKey:USER_NAME];
    }
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:PASSWORD]) {
        UITextField *passwordTextField = (UITextField *)[[self.loginTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] viewWithTag:LOGIN_PASSWORD_TEXTFIELD_TAG];
        passwordTextField.text = [[NSUserDefaults standardUserDefaults] valueForKey:PASSWORD];
    }
    
    
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.httpService cancelHTTPService];
}


- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [self setLoginTableView:nil];
    [self setCustomCellLoginView:nil];
    [self setParentView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [_loginTableView release];
    [_customCellLoginView release];
    [_parentView release];
    [_loginModel release];
    [_httpService release];
    [super dealloc];
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

- (IBAction)login:(id)sender {
    //[self dismissModalViewControllerAnimated:YES];i]
    //[DCSharedObject makeURLCALLWithHTTPService:self.httpService extraHeaders:nil bodyDictionary:nil identifier:[NSString stringWithFormat:DOCUMENTATTACHMENTS_ID, @"15x475"] requestMethod:kRequestMethodGET model:DOCUMENTATTACHMENTS delegate:self viewController:self];
    
    UITextField *usernameTextField = (UITextField *)[[self.loginTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:LOGIN_USERNAME_TEXTFIELD_TAG];
    
    UITextField *passwordTextField = (UITextField *)[[self.loginTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] viewWithTag:LOGIN_PASSWORD_TEXTFIELD_TAG];
    
    //store the username temporariy to share amongst the objects
    [[[DCSharedObject sharedPreferences] preferences] setValue:usernameTextField.text forKey:USER_NAME];
    //store the username temporariy to share amongst the screen
    [[[DCSharedObject sharedPreferences] preferences] setValue:passwordTextField.text forKey:PASSWORD];
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:GIZURCLOUD_API_KEY] &&
        [[NSUserDefaults standardUserDefaults] valueForKey:GIZURCLOUD_SECRET_KEY]) {
        
        if ([self isEmpty:usernameTextField.text] || [self isEmpty:passwordTextField.text]) {
            [DCSharedObject showAlertWithMessage:NSLocalizedString(@"EMPTY_USERNAME_PASSWORD", @"")];
            
        } else {
            [DCSharedObject makeURLCALLWithHTTPService:self.httpService extraHeaders:nil bodyDictionary:nil identifier:AUTHENTICATE_LOGIN requestMethod:kRequestMethodPOST model:AUTHENTICATE delegate:self viewController:self];
        }
    } else {
        [DCSharedObject showAlertWithMessage:NSLocalizedString(@"NO_API_KEY_ERROR", @"")];
    }
}

-(BOOL) isEmpty:(NSString *)string {
    NSCharacterSet *whiteSpaces = [NSCharacterSet whitespaceCharacterSet];
    NSString *validatedString = [string stringByTrimmingCharactersInSet:whiteSpaces];
    if ([validatedString length] == 0) {
        return YES;
    }
    return NO;
}


-(void) parseResponse:(NSString *)responseString forIdentifier:(NSString *)identifier {
    if ([identifier isEqualToString:AUTHENTICATE_LOGIN]) {
        NSDictionary *jsonDict = [responseString objectFromJSONString];
        if ((NSNull *)[jsonDict valueForKey:SUCCESS] != [NSNull null]) {
            NSNumber *status = [jsonDict valueForKey:SUCCESS];
            if ([status boolValue]) {
                //store the info till the user logs out
                if ([[NSUserDefaults standardUserDefaults] valueForKey:GIZURCLOUD_API_KEY] &&
                    [[NSUserDefaults standardUserDefaults] valueForKey:GIZURCLOUD_SECRET_KEY]) {
                    
                    [[NSUserDefaults standardUserDefaults] setValue:[[[DCSharedObject sharedPreferences] preferences] valueForKey:USER_NAME] forKey:USER_NAME];
                    [[NSUserDefaults standardUserDefaults] setValue:[[[DCSharedObject sharedPreferences] preferences] valueForKey:PASSWORD] forKey:PASSWORD];
                }
                [self dismissModalViewControllerAnimated:YES];
            } else {
                [DCSharedObject showAlertWithMessage:NSLocalizedString(@"INVALID_LOGIN", @"")];
            }
        }
    }
}

#pragma mark - HTTPServiceDelegate
-(void) responseCode:(int)code {
    self.httpStatusCode = code;
}

-(void) didReceiveResponse:(NSData *)data forIdentifier:(NSString *)identifier {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSString *responseString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
#if kDebug
    NSLog(@"%@", responseString);
#endif

    if (self.httpStatusCode == 200) {        
        [self parseResponse:responseString forIdentifier:identifier];
    } else {
        [DCSharedObject showAlertWithMessage:NSLocalizedString(@"INTERNAL_SERVER_ERROR", @"")];
    }
    
}

-(void) serviceDidFailWithError:(NSError *)error forIdentifier:(NSString *)identifier {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if ([error code] >= kNetworkConnectionError && [error code] <= kHostUnreachableError) {
        [DCSharedObject showAlertWithMessage:NSLocalizedString(@"NETWORK_ERROR", @"")];
    } else {
        [DCSharedObject showAlertWithMessage:NSLocalizedString(@"INTERNAL_SERVER_ERROR", @"")];
    }
}

-(void) storeResponse:(NSData *)data forIdentifier:(NSString *)identifier {
    
}


#pragma mark - UITextFieldDelegate

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.tag == LOGIN_USERNAME_TEXTFIELD_TAG) {
#if kDebug
        NSLog(@"Entered Username: %@", textField.text);
#endif
        
        //assign it to the model
        if (self.loginModel && ![self isEmpty:textField.text]) {
            self.loginModel.loginUsername = textField.text;
            
        }
    UITextField *passwordTextField = (UITextField *)[[self.loginTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] viewWithTag:LOGIN_PASSWORD_TEXTFIELD_TAG];
        [passwordTextField becomeFirstResponder];
    }
    
    if (textField.tag == LOGIN_PASSWORD_TEXTFIELD_TAG) {
#if kDebug
        NSLog(@"Entered Password: %@", textField.text);
#endif
        //assign it to the model
        if (self.loginModel && ![self isEmpty:textField.text]) {
            self.loginModel.loginPassword = textField.text;
            
        }
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - UITableViewDataSource methods

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"LOGIN", nil);
    }
    return @"";
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    return 0;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *customCellLoginView = [[NSBundle mainBundle] loadNibNamed:@"CustomCellLoginView" owner:nil options:nil];
    if (customCellLoginView) {
        if ([customCellLoginView count] > 0) {
            UIView *view = (UIView *)[customCellLoginView objectAtIndex:0];
            return view.frame.size.height;
        }
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        NSArray *customCellLoginView = [[NSBundle mainBundle] loadNibNamed:@"CustomCellLoginView" owner:self options:nil];
        if (customCellLoginView) {
            if ([customCellLoginView count] > 0) {
                cell = [customCellLoginView objectAtIndex:0];
            }
        }
    }
    
    UITextField *textField = (UITextField *)[cell viewWithTag:LOGIN_CUSTOM_CELL_TEXT_FIELD_TAG];
    textField.delegate = self;
    if (indexPath.row == 0) {
        textField.placeholder = NSLocalizedString(@"USERNAME", nil);
        textField.tag = LOGIN_USERNAME_TEXTFIELD_TAG;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.returnKeyType = UIReturnKeyNext;
        if (self.loginModel.loginUsername) {
            textField.text = self.loginModel.loginUsername;
        }
    } else if (indexPath.row == 1) {
        textField.secureTextEntry = YES;
        textField.placeholder = NSLocalizedString(@"PASSWORD", nil);
        textField.tag = LOGIN_PASSWORD_TEXTFIELD_TAG;
        textField.returnKeyType = UIReturnKeyGo;
        if (self.loginModel.loginPassword) {
            textField.text = self.loginModel.loginPassword;
        }
    }
    
    return cell;
}
@end
