//
//  DCSurveyViewController.m
//  DamageClaim
//
//  Created by Dev on 13/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  Used to submit surveys to the server

#import "DCSurveyViewController.h"

#import "DCLoginViewController.h"

#import "Const.h"

#import "DCPickListViewController.h"

#import "DCSurveyModel.h"

#import "DCPickListViewController.h"

#import "DCSharedObject.h"

#import "DCDamageListViewController.h"


#define SURVEY_SECTION_ONE_ROWS 4
#define SURVEY_SECTION_TWO_ROWS 2
#define SMALL_TABLE_VIEW_HEIGHT 200

@interface DCSurveyViewController ()
@property (retain, nonatomic) IBOutlet UITableView *surveyTableView;
@property (retain, nonatomic) IBOutlet UITableViewCell *customCellSegmentedView;
@property (retain, nonatomic) IBOutlet UITableViewCell *customCellTextFieldView;
@property (nonatomic, getter = isTrailerInventoryVisible) BOOL trailerInventoryVisible;
@property (nonatomic) CGRect originalTableFrame;
@property (nonatomic, retain) DCSurveyModel *surveyModel;

-(void) customizeNavigationBar;
-(IBAction) submitSurveyReport;
- (IBAction)resetSurvey:(id)sender;
-(void) toggleInventorySection:(id) sender;
-(void) toggleTrailerType:(id) sender;
-(BOOL) isEmpty:(NSString *)string;
-(void) openDamageList;

@end

@implementation DCSurveyViewController
@synthesize surveyTableView = _surveyTableView;
@synthesize customCellSegmentedView = _customCellSegmentedView;
@synthesize customCellTextFieldView = _customCellTextFieldView;
@synthesize trailerInventoryVisible = _trailerInventoryVisible;
@synthesize originalTableFrame = _originalTableFrame;
@synthesize surveyModel = _surveyModel;

#pragma mark - View LifeCycle
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
    
    DCLoginViewController *loginViewController = [[[DCLoginViewController alloc] initWithNibName:@"LoginView" bundle:nil] autorelease];
    [self presentModalViewController:loginViewController animated:NO];
    
    //store the original tableview height. will be used in restoring it
    //to its old height
    self.originalTableFrame = self.surveyTableView.frame;
#if kDebug
    NSLog(@"TABLE HEIGHT: %f, ORIGINAL HEIGHT: %f", self.surveyTableView.frame.size.height, self.originalTableFrame.size.height);
#endif
    
    if (!self.surveyModel) {
        self.surveyModel = [[[DCSurveyModel alloc] init] autorelease];
    }
    
}

- (void)viewDidUnload
{
    [self setSurveyTableView:nil];
    [self setCustomCellSegmentedView:nil];
    [self setCustomCellTextFieldView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.surveyTableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [_surveyTableView release];
    [_customCellSegmentedView release];
    [_customCellTextFieldView release];
    [_surveyModel release];
    [super dealloc];
}

#pragma mark - Others
-(void) customizeNavigationBar {
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
#if kDebug
    NSLog(@"%@", [self.navigationItem description]);
#endif
    if (self.navigationItem) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"REPORT_DAMAGE", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(openDamageList)] autorelease];
    }
    
}

//open the damage report's list
-(void) openDamageList {
    DCDamageListViewController *damageListViewController = [[[DCDamageListViewController alloc] initWithNibName:@"DamageListView" bundle:nil] autorelease];
    [self.navigationController pushViewController:damageListViewController animated:YES];
}

//send the survey to the server
-(void) submitSurveyReport {
}

- (IBAction)resetSurvey:(id)sender {
    //reset the survey form here
    
    //reset trailer type
    UISegmentedControl *trailerTypeSegmentedControl = (UISegmentedControl *)[[self.surveyTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:CUSTOM_CELL_SEGMENTED_SEGMENTED_VIEW_TAG];
    [trailerTypeSegmentedControl setSelectedSegmentIndex:0];
    
    if (self.surveyModel.surveyTrailerType) {
        self.surveyModel.surveyTrailerType = @"";
    }
    
    //reset trailer id
    UITableViewCell *idCell = [self.surveyTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    idCell.textLabel.text = NSLocalizedString(@"ID", @"");
    [[[DCSharedObject sharedPreferences] preferences] removeObjectForKey:SURVEY_TRAILER_ID];
    if (self.surveyModel.surveyTrailerId) {
        self.surveyModel.surveyTrailerId = @"";
    }
    
    //reset survey place
    UITableViewCell *placeCell = [self.surveyTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    placeCell.textLabel.text = NSLocalizedString(@"PLACE", @"");
    [[[DCSharedObject sharedPreferences] preferences] removeObjectForKey:SURVEY_PLACE];
    if (self.surveyModel.surveyPlace) {
        self.surveyModel.surveyPlace = @"";
    }
    
    //reset survey plates
    UITableViewCell *platesCell = [self.surveyTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    platesCell.textLabel.text = NSLocalizedString(@"PLATES", @"");
    [[[DCSharedObject sharedPreferences] preferences] removeObjectForKey:SURVEY_PLATES];
    if (self.surveyModel.surveyPlates) {
        self.surveyModel.surveyPlates = nil;
    }
    
    //reset survey straps
    UITableViewCell *strapsCell = [self.surveyTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    strapsCell.textLabel.text = NSLocalizedString(@"STRAPS", @"");
    [[[DCSharedObject sharedPreferences] preferences] removeObjectForKey:SURVEY_STRAPS];
    if (self.surveyModel.surveyStraps) {
        self.surveyModel.surveyStraps = nil;
    }
    
    //reset survey trailer sealed field
    UISegmentedControl *trailerSealedSegmentedControl = (UISegmentedControl *)[[self.surveyTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]] viewWithTag:CUSTOM_CELL_SEGMENTED_SEGMENTED_VIEW_TAG];
    [trailerSealedSegmentedControl setSelectedSegmentIndex:0];
    if (self.surveyModel.surveyTrailerSealed) {
        self.surveyModel.surveyTrailerSealed = nil;
    }
    if ([self isTrailerInventoryVisible]) {
        [self toggleInventorySection:trailerSealedSegmentedControl];
    }
    [self setTrailerInventoryVisible:NO];
    
    
    
    
    
}

//open the Trailer inventory section
//if trailer is not sealed
-(void) toggleInventorySection:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
        
    if ([segmentedControl selectedSegmentIndex] == 0 && [self isTrailerInventoryVisible]) {
        //make inventory section invisible
        self.trailerInventoryVisible = NO;
        
        self.surveyModel.surveyTrailerSealed = [NSNumber numberWithBool:YES];
        
        NSArray *indexPaths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:1], [NSIndexPath indexPathForRow:1 inSection:1], nil];
        [self.surveyTableView beginUpdates];
        [self.surveyTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
        //[self.surveyTableView reloadData];
        [self.surveyTableView endUpdates];
        
        
    } else if ([segmentedControl selectedSegmentIndex] == 1 && ![self isTrailerInventoryVisible]) {
        //make inventory section visible
        self.trailerInventoryVisible = YES;
        
        self.surveyModel.surveyTrailerSealed = [NSNumber numberWithBool:NO];

        
        NSArray *indexPaths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:1], [NSIndexPath indexPathForRow:1 inSection:1], nil];
        
        [self.surveyTableView beginUpdates];
        [self.surveyTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
        //[self.surveyTableView reloadData];
        [self.surveyTableView endUpdates];
    }
    //store the original tableview height. will be used in restoring it
    //to its old height
    self.originalTableFrame = self.surveyTableView.frame;
#if kDebug
    NSLog(@"TABLE HEIGHT: %f, ORIGINAL HEIGHT: %f", self.surveyTableView.frame.size.height, self.originalTableFrame.size.height);
#endif

}

-(void) toggleTrailerType:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    if ([segmentedControl selectedSegmentIndex] == 0) {
        //assigning temporary hard coded values
        self.surveyModel.surveyTrailerType = @"Own";
    } else {
        self.surveyModel.surveyTrailerType = @"Rented";
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

#pragma mark - UITextFieldDelegate method

-(void) textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.tag == TEXT_FIELD_PLATES_TAG) {
        
        //reduce the height of UITableView to make the textfields visible
        CGRect newFrame = self.surveyTableView.frame;
#if kDebug
        NSLog(@"%f, %f", newFrame.size.height, self.surveyTableView.frame.size.height);
#endif
        if (newFrame.size.height == self.originalTableFrame.size.height) {
            newFrame.size.height = SMALL_TABLE_VIEW_HEIGHT;
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            [UIView setAnimationDuration:0.25];
            self.surveyTableView.frame = newFrame;
            [self.surveyTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            [UIView commitAnimations];
        }
        
    }
    
    if (textField.tag == TEXT_FIELD_STRAPS_TAG) {
        
        //reduce the height of UITableView to make the textfields visible
        CGRect newFrame = self.surveyTableView.frame;
        if (newFrame.size.height == self.originalTableFrame.size.height) {
            newFrame.size.height = SMALL_TABLE_VIEW_HEIGHT;
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            [UIView setAnimationDuration:0.25];
            self.surveyTableView.frame = newFrame;
            [self.surveyTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            [UIView commitAnimations];
        }
    }
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == TEXT_FIELD_ID_TAG) {
        UITableViewCell *cell = [self.surveyTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        UITextField *nextTextField = (UITextField *)[cell viewWithTag:TEXT_FIELD_PLACE_TAG];
#if kDebug
        NSLog(@"%d", nextTextField.tag);
#endif
        [nextTextField becomeFirstResponder];
        
        
    }
    if (textField.tag == TEXT_FIELD_PLACE_TAG) {
        [textField resignFirstResponder];
    }
    if (textField.tag == TEXT_FIELD_PLATES_TAG) {
        UITextField *nextTextField = (UITextField *)[[self.surveyTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]] viewWithTag:TEXT_FIELD_STRAPS_TAG];
#if kDebug
        NSLog(@"%d", nextTextField.tag);
#endif
        [nextTextField becomeFirstResponder];
        
    }
    if (textField.tag == TEXT_FIELD_STRAPS_TAG) {
        
        [textField resignFirstResponder];
        //reduce the height of UITableView to make the textfields visible
        CGRect newFrame = self.surveyTableView.frame;
        if (newFrame.size.height != self.originalTableFrame.size.height) {
            newFrame.size.height = self.originalTableFrame.size.height;
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            [UIView setAnimationDuration:0.25];
            self.surveyTableView.frame = newFrame;
            [UIView commitAnimations];
        }
    }
    return YES;
}

#pragma mark - UITableViewDataSource methods
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return SURVEY_SECTION_ONE_ROWS;
    }
    if (section == 1 && [self isTrailerInventoryVisible]) {
        return SURVEY_SECTION_TWO_ROWS;
    }
    return 0;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"SURVEY_SECTION_ONE_TITLE", @"");
    }
    if (section == 1) {
        return NSLocalizedString(@"SURVEY_SECTION_TWO_TITLE", @"");
    }
    return @"";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if ((indexPath.section == 0 && (indexPath.row == 1 || indexPath.row == 2)) || indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SimpleCell"];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    }
    
    if (!cell) {
        if (indexPath.section == 0 && (indexPath.row == 0 || indexPath.row == 3)) {
            NSArray *customCellSegmentView = [[NSBundle mainBundle] loadNibNamed:@"CustomCellSegmentedView" owner:nil options:nil];
            if (customCellSegmentView) {
                if ([customCellSegmentView count] > 0) {
                    cell = [customCellSegmentView objectAtIndex:0];
                }
            }
        }
        
        if ((indexPath.section == 0 && (indexPath.row == 1 || indexPath.row == 2)) || indexPath.section == 1) {
//            NSArray *customCellTextFieldView = [[NSBundle mainBundle] loadNibNamed:@"CustomCellTextFieldView" owner:nil options:nil];
//            if (customCellTextFieldView) {
//                if ([customCellTextFieldView count] > 0) {
//                    cell = [customCellTextFieldView objectAtIndex:0];
//                }
//            }
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SimpleCell"] autorelease];
            
        }
    }
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0: {
                    UILabel *titleLabel = (UILabel *)[cell viewWithTag:CUSTOM_CELL_SEGMENTED_TITE_LABEL_TAG];
                    titleLabel.text = NSLocalizedString(@"TRAILER_TYPE", @"");
                    
                    UISegmentedControl *segmentedControl = (UISegmentedControl *)[cell viewWithTag:CUSTOM_CELL_SEGMENTED_SEGMENTED_VIEW_TAG];
                    [segmentedControl setTitle:NSLocalizedString(@"OWN", @"") forSegmentAtIndex:0];
                    [segmentedControl setTitle:NSLocalizedString(@"RENTED", @"") forSegmentAtIndex:1];
                    if ([[self.surveyModel.surveyTrailerType lowercaseString] isEqualToString:@"rented"]) {
                        [segmentedControl setSelectedSegmentIndex:1];
                    }
                    [segmentedControl addTarget:self action:@selector(toggleTrailerType:) forControlEvents:UIControlEventValueChanged];
                }
                    break;
                case 1: {
//                    UITextField *idTextField = (UITextField *)[cell viewWithTag:CUSTOM_CELL_TEXTFIELD_TEXTFIELD_TAG];
//                    idTextField.placeholder = NSLocalizedString(@"ID", @"");
//                    idTextField.delegate = self;
//                    idTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
//                    idTextField.clearButtonMode = UITextFieldViewModeAlways;
//                    idTextField.returnKeyType = UIReturnKeyNext;
//                    //overwriting textField tag
//                    idTextField.tag = TEXT_FIELD_ID_TAG;
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    
                    cell.textLabel.shadowColor = [UIColor whiteColor];
                    cell.textLabel.shadowOffset = CGSizeMake(1, 1);
                    if ([[[DCSharedObject sharedPreferences] preferences] valueForKey:SURVEY_TRAILER_ID]) {
                        NSArray *trailerIDArray = [[[DCSharedObject sharedPreferences] preferences] valueForKey:SURVEY_TRAILER_ID];
                        if ([trailerIDArray count] > 0) {
                            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"ID", @""), [trailerIDArray objectAtIndex:0]];
                            
                        }
                        
                    } else {
                        cell.textLabel.text = NSLocalizedString(@"ID", @"");
                    }
                }
                    break;
                case 2: {
//                    UITextField *textField = (UITextField *)[cell viewWithTag:CUSTOM_CELL_TEXTFIELD_TEXTFIELD_TAG];
//                    textField.placeholder = NSLocalizedString(@"PLACE", @"");
//                    textField.delegate = self;
//                    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
//                    textField.clearButtonMode = UITextFieldViewModeAlways;
//                    //overwriting textField tag
//                    textField.tag = TEXT_FIELD_PLACE_TAG;
                    
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.textLabel.shadowColor = [UIColor whiteColor];
                    cell.textLabel.shadowOffset = CGSizeMake(1, 1);
                    if ([[[DCSharedObject sharedPreferences] preferences] valueForKey:SURVEY_PLACE]) {
                        NSArray *trailerIDArray = [[[DCSharedObject sharedPreferences] preferences] valueForKey:SURVEY_PLACE];
                        if ([trailerIDArray count] > 0) {
                            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"PLACE", @""), [trailerIDArray objectAtIndex:0]];
                        }
                        
                    } else {
                        cell.textLabel.text = NSLocalizedString(@"PLACE", @"");
                    }
                }
                    break;
                case 3: {
                    UILabel *titleLabel = (UILabel *)[cell viewWithTag:CUSTOM_CELL_SEGMENTED_TITE_LABEL_TAG];
                    titleLabel.text = NSLocalizedString(@"SEALED", @"");
                    
                    UISegmentedControl *segmentedControl = (UISegmentedControl *)[cell viewWithTag:CUSTOM_CELL_SEGMENTED_SEGMENTED_VIEW_TAG];
                    [segmentedControl setTitle:NSLocalizedString(@"YES", @"") forSegmentAtIndex:0];
                    [segmentedControl setTitle:NSLocalizedString(@"NO", @"") forSegmentAtIndex:1];
                    [segmentedControl addTarget:self action:@selector(toggleInventorySection:) forControlEvents:UIControlEventValueChanged];
                    if (self.surveyModel.surveyTrailerSealed) {
#if kDebug
                        NSLog([self.surveyModel.surveyTrailerSealed boolValue]?@"YES":@"NO");
#endif
                        if (![self.surveyModel.surveyTrailerSealed boolValue]) {
                            [segmentedControl setSelectedSegmentIndex:1];
                        }
                    }
                    
                }
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0: {
//                    UITextField *textField = (UITextField *)[cell viewWithTag:CUSTOM_CELL_TEXTFIELD_TEXTFIELD_TAG];
//                    textField.placeholder = NSLocalizedString(@"PLATES", @"");
//                    textField.delegate = self;
//                    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
//                    textField.clearButtonMode = UITextFieldViewModeAlways;
//                    textField.returnKeyType = UIReturnKeyNext;
//                    //overwriting textField tag
//                    textField.tag = TEXT_FIELD_PLATES_TAG;
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.textLabel.shadowColor = [UIColor whiteColor];
                    cell.textLabel.shadowOffset = CGSizeMake(1, 1);
                    
                    if ([[[DCSharedObject sharedPreferences] preferences] valueForKey:SURVEY_PLATES]) {
                        NSArray *trailerIDArray = [[[DCSharedObject sharedPreferences] preferences] valueForKey:SURVEY_PLATES];
                        if ([trailerIDArray count] > 0) {
                            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"PLATES", @""), [trailerIDArray objectAtIndex:0]];
                        }
                        
                    } else {
                        cell.textLabel.text = NSLocalizedString(@"PLATES", @"");
                    }
                }
                    break;
                case 1: {
//                    UITextField *textField = (UITextField *)[cell viewWithTag:CUSTOM_CELL_TEXTFIELD_TEXTFIELD_TAG];
//                    textField.placeholder = NSLocalizedString(@"STRAPS", @"");
//                    textField.delegate = self;
//                    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
//                    textField.clearButtonMode = UITextFieldViewModeAlways;
//                    //overwriting textField tag
//                    textField.tag = TEXT_FIELD_STRAPS_TAG;
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.textLabel.shadowColor = [UIColor whiteColor];
                    cell.textLabel.shadowOffset = CGSizeMake(1, 1);
                    
                    if ([[[DCSharedObject sharedPreferences] preferences] valueForKey:SURVEY_STRAPS]) {
                        NSArray *trailerIDArray = [[[DCSharedObject sharedPreferences] preferences] valueForKey:SURVEY_STRAPS];
                        if ([trailerIDArray count] > 0) {
                            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"STRAPS", @""), [trailerIDArray objectAtIndex:0]];
                        }
                        
                    } else {
                        cell.textLabel.text = NSLocalizedString(@"STRAPS", @"");
                    }
                }
                    break;
                    
                default:
                    break;
            }
            break;
        default:
            break;
    }
    return cell;
}

#pragma mark - UITableViewDelegate methods
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
#if kDebug
    NSLog(@"TableView Called");
#endif
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 1: {
                    //dummy values
                    NSArray *trailerIdArray = [NSArray arrayWithObjects:@"TR031A", @"TR031B", @"TR031B", @"TR031B", nil];
                    DCPickListViewController *pickListViewController = [[[DCPickListViewController alloc] initWithNibName:@"PickListView" bundle:nil modelArray:trailerIdArray storageKey:SURVEY_TRAILER_ID] autorelease];
                    [self.navigationController pushViewController:pickListViewController animated:YES];
                }
                    break;
                case 2: {
                    //dummy values
                    NSArray *trailerIdArray = [NSArray arrayWithObjects:@"Place 1", @"Place 2", @"Place 3", @"Place 4", nil];
                    
                    DCPickListViewController *pickListViewController = [[[DCPickListViewController alloc] initWithNibName:@"PickListView" bundle:nil modelArray:trailerIdArray storageKey:SURVEY_PLACE] autorelease];
                    [self.navigationController pushViewController:pickListViewController animated:YES];
                }
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0: {
                    //dummy values
                    NSArray *trailerIdArray = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", nil];
                    
                    DCPickListViewController *pickListViewController = [[[DCPickListViewController alloc] initWithNibName:@"PickListView" bundle:nil modelArray:trailerIdArray storageKey:SURVEY_PLATES] autorelease];
                    [self.navigationController pushViewController:pickListViewController animated:YES];
                }
                    break;
                case 1: {
                    //dummy values
                    NSArray *trailerIdArray = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", nil];
                    
                    DCPickListViewController *pickListViewController = [[[DCPickListViewController alloc] initWithNibName:@"PickListView" bundle:nil modelArray:trailerIdArray storageKey:SURVEY_STRAPS] autorelease];
                    [self.navigationController pushViewController:pickListViewController animated:YES];
                }
                    break;
                    
                default:
                    break;
            }
            break;
        default:
            break;
    }
}
@end
