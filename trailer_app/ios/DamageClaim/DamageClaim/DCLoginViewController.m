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
-(void) parseResponse:(NSString *)responseString forURLString:(NSString *)urlString;


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
    //[self dismissModalViewControllerAnimated:YES];
    NSString *model = @"Authenticate";
    NSString *action = @"login";
    NSString *urlString = [NSString stringWithFormat:@"http://gizurtrailerapp-env.elasticbeanstalk.com/api/index.php/api/%@/%@", model, action];
    self.httpService = [[HTTPService alloc] initWithURLString:urlString headers:[RequestHeaders commonHeaders] body:nil delegate:self requestMethod:kRequestMethodPOST];
    NSURLRequest *request = [self.httpService request];
    NSString *signature;
    if ([self.httpService serviceRequestMethod] == kRequestMethodPOST) {
       signature  = [DCSharedObject generateSignatureForRequest:request model:model requestType:POST];
    } else {
        signature = [DCSharedObject generateSignatureForRequest:request model:model requestType:GET];
    }
#if kDebug
    NSLog(@"%@", signature);
#endif
    
    if (signature) {
        [[self.httpService headersDictionary] setValue:signature forKey:HTTP_X_SIGNATURE];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.animationType = MBProgressHUDAnimationFade;
        hud.labelText = NSLocalizedString(@"LOADING_MESSAGE", @"");
        [self.httpService startService];
#if kDebug
        NSLog(@"%@", [[self.httpService headersDictionary] description]);
#endif

    } else {
        //something went wrong
        [DCSharedObject showAlertWithMessage:NSLocalizedString(@"INTERNAL_SERVER_ERROR", @"")];
    }
    
}

-(void) parseResponse:(NSString *)responseString forURLString:(NSString *)urlString {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - HTTPServiceDelegate
-(void) responseCode:(int)code {
    self.httpStatusCode = code;
}

-(void) didReceiveResponse:(NSData *)data forURLString:(NSString *)urlString {
    if (self.httpStatusCode == 200) {
        NSString *responseString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
#if kDebug
        NSLog(@"%@", responseString);
#endif
        
        [self parseResponse:responseString forURLString:urlString];
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(void) serviceDidFailWithError:(NSError *)error forURLString:(NSString *)urlString {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}


#pragma mark - UITextFieldDelegate

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.tag == LOGIN_USERNAME_TEXTFIELD_TAG) {
#if kDebug
        NSLog(@"Entered Username: %@", textField.text);
#endif
        
        //assign it to the model
        if (self.loginModel) {
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
        if (self.loginModel) {
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
