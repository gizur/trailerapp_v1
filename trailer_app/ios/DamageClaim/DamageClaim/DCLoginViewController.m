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

@interface DCLoginViewController ()
@property (retain, nonatomic) IBOutlet UIView *parentView;
@property (retain, nonatomic) IBOutlet UITableView *loginTableView;
@property (retain, nonatomic) IBOutlet UITableViewCell *customCellLoginView;
@property (retain, nonatomic) DCLoginModel *loginModel;

-(void) keyboardWillShow:(NSNotification *)notification;
-(void) keyboardWillHide:(NSNotification *)notification;
- (IBAction)login:(id)sender;


@end

@implementation DCLoginViewController
@synthesize parentView = _parentView;
@synthesize loginTableView = _loginTableView;
@synthesize customCellLoginView = _customCellLoginView;
@synthesize loginModel = _loginModel;

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
    [self dismissModalViewControllerAnimated:YES];
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
