//
//  DCResetPasswordViewController.m
//  DamageClaim
//
//  Created by Dev on 03/10/12.
//
//

#import "DCResetPasswordViewController.h"

#import "Const.h"

@interface DCResetPasswordViewController ()
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) NSString *oldPassword;
@property (retain, nonatomic) NSString *enteredNewPassword;
@property (retain, nonatomic) NSString *confirmNewPassword;

- (IBAction)submit:(id)sender;

@end

@implementation DCResetPasswordViewController
@synthesize tableView = _tableView;
@synthesize oldPassword = _oldPassword;
@synthesize enteredNewPassword = _enteredNewPassword;
@synthesize confirmNewPassword = _confirmNewPassword;


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
    [_oldPassword release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

#pragma mark - Others

- (IBAction)submit:(id)sender {
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
        NSArray *customCellTextFieldView = [[NSBundle mainBundle] loadNibNamed:@"CustomCellTextFieldView" owner:nil options:nil];
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
        textField.placeholder = NSLocalizedString(@"OLD_PASSWORD", nil);
        textField.tag = RESET_OLD_PASSWORD_TAG;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.returnKeyType = UIReturnKeyNext;
        
    } else if (indexPath.row == 1) {
        textField.secureTextEntry = YES;
        textField.placeholder = NSLocalizedString(@"NEW_PASSWORD", nil);
        textField.tag = RESET_NEW_PASSWORD_TAG;
        textField.returnKeyType = UIReturnKeyNext;
        
    }  else if (indexPath.row == 2) {
        textField.secureTextEntry = YES;
        textField.placeholder = NSLocalizedString(@"CONFIRM_NEW_PASSWORD", nil);
        textField.tag = RESET_CONFIRM_NEW_PASSWORD_TAG;
    }
    
    return cell;
}

@end
