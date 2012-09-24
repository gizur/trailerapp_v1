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

#import "MBProgressHUD.h"

#import "JSONKit.h"


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
@property (retain, nonatomic) IBOutlet UIBarButtonItem *submitToolBarButton;
@property (retain, nonatomic) HTTPService *httpService;
@property (nonatomic) NSInteger httpStatusCode;

-(void) customizeNavigationBar;
-(IBAction) submitSurveyReport;
- (IBAction)resetSurvey:(id)sender;
-(void) toggleInventorySection:(id) sender;
-(void) toggleTrailerType:(id) sender;
-(BOOL) isEmpty:(NSString *)string;
-(void) openDamageList;
-(void) logout;
-(void) toggleActionButtons;
-(void) loadPickLists;
-(void) parseResponse:(NSString *)responseString forIdentifier:(NSString *)identifier;
@end

@implementation DCSurveyViewController
@synthesize surveyTableView = _surveyTableView;
@synthesize customCellSegmentedView = _customCellSegmentedView;
@synthesize customCellTextFieldView = _customCellTextFieldView;
@synthesize trailerInventoryVisible = _trailerInventoryVisible;
@synthesize originalTableFrame = _originalTableFrame;
@synthesize surveyModel = _surveyModel;
@synthesize submitToolBarButton = _submitToolBarButton;
@synthesize httpService = _httpService;
@synthesize httpStatusCode = _httpStatusCode;

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
    
    //store the original tableview height. will be used in restoring it
    //to its old height
    self.originalTableFrame = self.surveyTableView.frame;
#if kDebug
    NSLog(@"TABLE HEIGHT: %f, ORIGINAL HEIGHT: %f", self.surveyTableView.frame.size.height, self.originalTableFrame.size.height);
#endif
    
    if (!self.surveyModel) {
        self.surveyModel = [[[DCSurveyModel alloc] init] autorelease];
    }
    
    [self loadPickLists];
    [self toggleActionButtons];
    
}

- (void)viewDidUnload
{
    [self setSurveyTableView:nil];
    [self setCustomCellSegmentedView:nil];
    [self setCustomCellTextFieldView:nil];
    [self setSubmitToolBarButton:nil];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}
-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.httpService cancelHTTPService];
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
    [_submitToolBarButton release];
    [_httpService release];
    [super dealloc];
}

#pragma mark - Others
-(void) customizeNavigationBar {
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
#if kDebug
    NSLog(@"%@", [self.navigationItem description]);
#endif
    if (self.navigationItem) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"REPORT_DAMAGE", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(openDamageList)] autorelease];
        
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"LOGOUT", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(logout)] autorelease];
    }
    
}

-(void) logout {
    [DCSharedObject makeURLCALLWithHTTPService:self.httpService extraHeaders:nil body:nil identifier:AUTHENTICATE_LOGOUT requestMethod:kRequestMethodPOST model:AUTHENTICATE delegate:self viewController:self];
}

//open the damage report's list
-(void) openDamageList {
    //share the survey model with damageListViewController
    [[[DCSharedObject sharedPreferences] preferences] setValue:self.surveyModel forKey:SURVEY_MODEL];
    DCDamageListViewController *damageListViewController = [[[DCDamageListViewController alloc] initWithNibName:@"DamageListView" bundle:nil] autorelease];
    [self.navigationController pushViewController:damageListViewController animated:YES];
}

//send the survey to the server
-(void) submitSurveyReport {
    //make a dictionary of post data
    NSMutableDictionary *bodyDict = [[[NSMutableDictionary alloc] init] autorelease];
    
    NSDictionary *reportDamageDict = [[[DCSharedObject sharedPreferences] preferences] valueForKey:HELPDESK_REPORTDAMAGE];
    if (reportDamageDict) {
        NSString *reportDamageNoValue = [reportDamageDict valueForKey:@"No"];
#if kDebug
        NSLog(@"%@", reportDamageNoValue);
#endif
        if (reportDamageDict) {
            [bodyDict setValue:reportDamageNoValue forKey:@"reportdamage"];
        } else {
            [bodyDict setValue:@"No" forKey:@"reportdamage"];
        }
    } else {
        [bodyDict setValue:@"No" forKey:@"reportdamage"];
    }
    
    NSDictionary *ticketStatusDict = [[[DCSharedObject sharedPreferences] preferences] valueForKey:HELPDESK_TICKETSTATUS];
    if (ticketStatusDict) {
        NSString *ticketStatusClosedValue = [ticketStatusDict valueForKey:@"Closed"];
#if kDebug
        NSLog(@"%@, %@", ticketStatusDict, ticketStatusClosedValue);
#endif
        if (ticketStatusClosedValue) {
            [bodyDict setValue:ticketStatusClosedValue forKey:@"ticketstatus"];
        } else {
            [bodyDict setValue:@"Closed" forKey:@"ticketstatus"];
        }
    } else {
        [bodyDict setValue:@"Closed" forKey:@"ticketstatus"];
    }

    
    NSString *ticketTitle = @"";
    if ([[NSUserDefaults standardUserDefaults] valueForKey:CONTACT_NAME]) {
        ticketTitle = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"SURVEY_TICKET_TITLE", @""), [[NSUserDefaults standardUserDefaults] valueForKey:CONTACT_NAME]];
    }
    [bodyDict setValue:ticketTitle forKey:@"ticket_title"];
    
    
    if (self.surveyModel.surveyTrailerId) {
        [bodyDict setValue:self.surveyModel.surveyTrailerId forKey:@"trailerid"];
    }
    
    if (self.surveyModel.surveyPlace) {
        [bodyDict setValue:self.surveyModel.surveyPlace forKey:@"damagereportlocation"];
    }
    
    if (self.surveyModel.surveyTrailerSealed) {
        NSDictionary *sealedDict = [[[DCSharedObject sharedPreferences] preferences] valueForKey:HELPDESK_SEALED];
        if (sealedDict) {
            NSString *sealedYesValue = [reportDamageDict valueForKey:@"Yes"];
            NSString *sealedNoValue = [reportDamageDict valueForKey:@"No"];
#if kDebug
            NSLog(@"%@ %@", sealedYesValue, sealedNoValue);
#endif
            if (sealedDict) {
                [bodyDict setValue:[self.surveyModel.surveyTrailerSealed boolValue]?sealedYesValue:sealedNoValue forKey:@"sealed"];
            } else {
                [bodyDict setValue:[self.surveyModel.surveyTrailerSealed boolValue]?@"Yes":@"No" forKey:@"sealed"];
            }
        } else {
            [bodyDict setValue:[self.surveyModel.surveyTrailerSealed boolValue]?@"Yes":@"No" forKey:@"sealed"];
        }
    }
    
    if (self.surveyModel.surveyPlates) {
        [bodyDict setValue:[NSString stringWithFormat:@"%d", [self.surveyModel.surveyPlates intValue]] forKey:@"plates"];
    }
    
    if (self.surveyModel.surveyStraps) {
        [bodyDict setValue:[NSString stringWithFormat:@"%d", [self.surveyModel.surveyStraps intValue]] forKey:@"straps"];
    }
    
    [DCSharedObject makeURLCALLWithHTTPService:self.httpService extraHeaders:nil bodyDictionary:bodyDict identifier:HELPDESK requestMethod:kRequestMethodPOST model:HELPDESK delegate:self viewController:self];
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
    if (self.surveyModel.surveyTrailerId) {
        self.surveyModel.surveyTrailerId = nil;
    }
    
    //reset survey place
    UITableViewCell *placeCell = [self.surveyTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    placeCell.textLabel.text = NSLocalizedString(@"PLACE", @"");
    if (self.surveyModel.surveyPlace) {
        self.surveyModel.surveyPlace = nil;
    }
    
    //reset survey plates
    UITableViewCell *platesCell = [self.surveyTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    platesCell.textLabel.text = NSLocalizedString(@"PLATES", @"");
    if (self.surveyModel.surveyPlates) {
        self.surveyModel.surveyPlates = nil;
    }
    
    //reset survey straps
    UITableViewCell *strapsCell = [self.surveyTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    strapsCell.textLabel.text = NSLocalizedString(@"STRAPS", @"");
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
    
    [self toggleActionButtons];
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
        
        //reset the plates and straps if the trailer is sealed
        self.surveyModel.surveyPlates = nil;
        self.surveyModel.surveyStraps = nil;
        
        
        
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

-(void) toggleActionButtons {
    if (!self.surveyModel.surveyTrailerId) {
        //[self.navigationItem.rightBarButtonItem setEnabled:NO];
        [self.submitToolBarButton setEnabled:NO];
    } else {
        //[self.navigationItem.rightBarButtonItem setEnabled:YES];
        [self.submitToolBarButton setEnabled:YES];
    }
}

-(void) loadPickLists {
    [DCSharedObject makeURLCALLWithHTTPService:self.httpService extraHeaders:nil body:nil identifier:HELPDESK_TICKETSTATUS requestMethod:kRequestMethodGET model:HELPDESK delegate:self viewController:self];
    
    [DCSharedObject makeURLCALLWithHTTPService:self.httpService extraHeaders:nil bodyDictionary:nil identifier:HELPDESK_SEALED requestMethod:kRequestMethodGET model:HELPDESK delegate:self viewController:self];
    
    [DCSharedObject makeURLCALLWithHTTPService:self.httpService extraHeaders:nil body:nil identifier:HELPDESK_REPORTDAMAGE requestMethod:kRequestMethodGET model:HELPDESK delegate:self viewController:self];
    
}

-(void) parseResponse:(NSString *)responseString forIdentifier:(NSString *)identifier {
    if (responseString) {
        NSDictionary *jsonDict = [responseString objectFromJSONString];
        if ([identifier isEqualToString:HELPDESK_TICKETSTATUS]) {
            if ((NSNull *)[jsonDict valueForKey:SUCCESS] != [NSNull null]) {
                if ([(NSNumber *)[jsonDict valueForKey:SUCCESS] boolValue]) {
                    if ((NSNull *)[jsonDict valueForKey:@"result"] != [NSNull null]) {
                        NSArray *resultArray = [jsonDict valueForKey:@"result"];
                        NSMutableDictionary *ticketStatusDictionary = [[[NSMutableDictionary alloc] init] autorelease];
                        for (NSDictionary *result in resultArray) {
                            if ((NSNull *)[result valueForKey:@"label"] != [NSNull null]) {
                                NSString *label = [result valueForKey:@"label"];
                                if ((NSNull *)[result valueForKey:@"value"] != [NSNull null]) {
                                    NSString *value = [result valueForKey:@"value"];
                                    [ticketStatusDictionary setValue:value forKey:label];
                                }
                            }
                        }
                        [[[DCSharedObject sharedPreferences] preferences] setValue:ticketStatusDictionary forKey:HELPDESK_TICKETSTATUS];
                    }
                }  else if ((NSNull *)[jsonDict valueForKey:@"error"] != [NSNull null]) {
                    NSDictionary *errorDict = [jsonDict valueForKey:@"error"];
                    if ((NSNull *)[errorDict valueForKey:@"code"] != [NSNull null]) {
                        NSString *errorCode = [errorDict valueForKey:@"code"];
                        if ([errorCode isEqualToString:TIME_NOT_IN_SYNC]) {
                            if ((NSNull *)[errorDict valueForKey:@"time_difference"] != [NSNull null]) {
                                [[[DCSharedObject sharedPreferences] preferences] setValue:[errorDict valueForKey:@"time_difference"] forKey:TIME_DIFFERENCE];
                                //[[NSUserDefaults standardUserDefaults] setValue:[errorDict valueForKey:@"time_difference"] forKey:TIME_DIFFERENCE];
                                
                                [DCSharedObject makeURLCALLWithHTTPService:self.httpService extraHeaders:nil body:nil identifier:HELPDESK_TICKETSTATUS requestMethod:kRequestMethodGET model:HELPDESK delegate:self viewController:self];
                            }
                        } else {
                            [DCSharedObject showAlertWithMessage:@"INTERNAL_SERVER_ERROR"];
                        }
                    }
                } else {
                    [DCSharedObject showAlertWithMessage:@"INTERNAL_SERVER_ERROR"];
                }
            }
        }
        
        
        if ([identifier isEqualToString:HELPDESK_SEALED]) {
            if ((NSNull *)[jsonDict valueForKey:SUCCESS] != [NSNull null]) {
                if ([(NSNumber *)[jsonDict valueForKey:SUCCESS] boolValue]) {
                    if ((NSNull *)[jsonDict valueForKey:@"result"] != [NSNull null]) {
                        NSArray *resultArray = [jsonDict valueForKey:@"result"];
                        NSMutableDictionary *sealedDictionary = [[[NSMutableDictionary alloc] init] autorelease];
                        for (NSDictionary *result in resultArray) {
                            if ((NSNull *)[result valueForKey:@"label"] != [NSNull null]) {
                                NSString *label = [result valueForKey:@"label"];
                                if ((NSNull *)[result valueForKey:@"value"] != [NSNull null]) {
                                    NSString *value = [result valueForKey:@"value"];
                                    [sealedDictionary setValue:value forKey:label];
                                }
                            }
                        }
                        [[[DCSharedObject sharedPreferences] preferences] setValue:sealedDictionary forKey:HELPDESK_SEALED];
                        [self.surveyTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                    }
                }  else if ((NSNull *)[jsonDict valueForKey:@"error"] != [NSNull null]) {
                    NSDictionary *errorDict = [jsonDict valueForKey:@"error"];
                    if ((NSNull *)[errorDict valueForKey:@"code"] != [NSNull null]) {
                        NSString *errorCode = [errorDict valueForKey:@"code"];
                        if ([errorCode isEqualToString:TIME_NOT_IN_SYNC]) {
                            if ((NSNull *)[errorDict valueForKey:@"time_difference"] != [NSNull null]) {
                                [[[DCSharedObject sharedPreferences] preferences] setValue:[errorDict valueForKey:@"time_difference"] forKey:TIME_DIFFERENCE];
                                //[[NSUserDefaults standardUserDefaults] setValue:[errorDict valueForKey:@"time_difference"] forKey:TIME_DIFFERENCE];
                                //timestamp is adjusted. call the same url again
                                [DCSharedObject makeURLCALLWithHTTPService:self.httpService extraHeaders:nil body:nil identifier:HELPDESK_SEALED requestMethod:kRequestMethodGET model:HELPDESK delegate:self viewController:self];
                            }
                        } else {
                            [DCSharedObject showAlertWithMessage:@"INTERNAL_SERVER_ERROR"];
                        }
                    }
                } else {
                    [DCSharedObject showAlertWithMessage:@"INTERNAL_SERVER_ERROR"];
                }
            }
        }
        
        
        if ([identifier isEqualToString:HELPDESK_REPORTDAMAGE]) {
            if ((NSNull *)[jsonDict valueForKey:SUCCESS] != [NSNull null]) {
                if ([(NSNumber *)[jsonDict valueForKey:SUCCESS] boolValue]) {
                    if ((NSNull *)[jsonDict valueForKey:@"result"] != [NSNull null]) {
                        NSArray *resultArray = [jsonDict valueForKey:@"result"];
                        NSMutableDictionary *reportDamageDictionary = [[[NSMutableDictionary alloc] init] autorelease];
                        for (NSDictionary *result in resultArray) {
                            if ((NSNull *)[result valueForKey:@"label"] != [NSNull null]) {
                                NSString *label = [result valueForKey:@"label"];
                                if ((NSNull *)[result valueForKey:@"value"] != [NSNull null]) {
                                    NSString *value = [result valueForKey:@"value"];
                                    [reportDamageDictionary setValue:value forKey:label];
                                }
                            }
                        }
                        [[[DCSharedObject sharedPreferences] preferences] setValue:reportDamageDictionary forKey:HELPDESK_REPORTDAMAGE];
                    }
                }  else if ((NSNull *)[jsonDict valueForKey:@"error"] != [NSNull null]) {
                    NSDictionary *errorDict = [jsonDict valueForKey:@"error"];
                    if ((NSNull *)[errorDict valueForKey:@"code"] != [NSNull null]) {
                        NSString *errorCode = [errorDict valueForKey:@"code"];
                        if ([errorCode isEqualToString:TIME_NOT_IN_SYNC]) {
                            if ((NSNull *)[errorDict valueForKey:@"time_difference"] != [NSNull null]) {
                                [[[DCSharedObject sharedPreferences] preferences] setValue:[errorDict valueForKey:@"time_difference"] forKey:TIME_DIFFERENCE];
                                //[[NSUserDefaults standardUserDefaults] setValue:[errorDict valueForKey:@"time_difference"] forKey:TIME_DIFFERENCE];
                                
                                //timestamp is adjusted. call the same url again
                                [DCSharedObject makeURLCALLWithHTTPService:self.httpService extraHeaders:nil body:nil identifier:HELPDESK_REPORTDAMAGE requestMethod:kRequestMethodGET model:HELPDESK delegate:self viewController:self];
                            }
                        } else {
                            [DCSharedObject showAlertWithMessage:@"INTERNAL_SERVER_ERROR"];
                        }
                    }
                } else {
                    [DCSharedObject showAlertWithMessage:@"INTERNAL_SERVER_ERROR"];
                }
            }
        }
        
        
        if ([identifier isEqualToString:HELPDESK]) {
            if ((NSNull *)[jsonDict valueForKey:SUCCESS] != [NSNull null]) {
                if (![(NSNumber *)[jsonDict valueForKey:SUCCESS] boolValue]) {
                    if ((NSNull *)[jsonDict valueForKey:@"error"] != [NSNull null]) {
                        NSDictionary *errorDict = [jsonDict valueForKey:@"error"];
                        if ((NSNull *)[errorDict valueForKey:@"code"] != [NSNull null]) {
                            NSString *errorCode = [errorDict valueForKey:@"code"];
                            if ([errorCode isEqualToString:TIME_NOT_IN_SYNC]) {
                                if ((NSNull *)[errorDict valueForKey:@"time_difference"] != [NSNull null]) {
                                    [[[DCSharedObject sharedPreferences] preferences] setValue:[errorDict valueForKey:@"time_difference"] forKey:TIME_DIFFERENCE];
                                    //[[NSUserDefaults standardUserDefaults] setValue:[errorDict valueForKey:@"time_difference"] forKey:TIME_DIFFERENCE];
                                    
                                    //timestamp is adjusted. call the same url again
                                    [DCSharedObject makeURLCALLWithHTTPService:self.httpService extraHeaders:nil body:nil identifier:HELPDESK requestMethod:kRequestMethodGET model:HELPDESK delegate:self viewController:self];
                                }
                            } else {
                                [DCSharedObject showAlertWithMessage:@"INTERNAL_SERVER_ERROR"];
                            }
                        }
                    }
                }
            }
        }
        
        if ([identifier isEqualToString:AUTHENTICATE_LOGOUT]) {
            if ((NSNull *)[jsonDict valueForKey:SUCCESS] != [NSNull null]) {
                if ([(NSNumber *)[jsonDict valueForKey:SUCCESS] boolValue]) {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_NAME];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PASSWORD];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:GIZURCLOUD_API_KEY];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:GIZURCLOUD_SECRET_KEY];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:CONTACT_NAME];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ACCOUNT_NAME];
                    
                    if ([[[DCSharedObject sharedPreferences] preferences] valueForKey:USER_NAME]) {
                        [[[DCSharedObject sharedPreferences] preferences] removeObjectForKey:USER_NAME];
                    }
                    
                    if ([[[DCSharedObject sharedPreferences] preferences] valueForKey:PASSWORD]) {
                        [[[DCSharedObject sharedPreferences] preferences] removeObjectForKey:PASSWORD];
                    }
                    
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_LOGGED_IN];
#if kDebug
                    NSLog(@"%@", self.navigationController);
#endif
                    id parentViewController = [self.navigationController parentViewController];
                    if ([parentViewController isKindOfClass:[DCLoginViewController class]]) {
                        [self.navigationController popViewControllerAnimated:YES];
                    } else {
                        DCLoginViewController *loginViewController = [[[DCLoginViewController alloc] initWithNibName:@"LoginView" bundle:nil] autorelease];
                        [self.navigationController pushViewController:loginViewController animated:YES];
                    }
                    

                } else if ((NSNull *)[jsonDict valueForKey:@"error"] != [NSNull null]) {
                    NSDictionary *errorDict = [jsonDict valueForKey:@"error"];
                    if ((NSNull *)[errorDict valueForKey:@"code"] != [NSNull null]) {
                        NSString *errorCode = [errorDict valueForKey:@"code"];
                        if ([errorCode isEqualToString:TIME_NOT_IN_SYNC]) {
                            if ((NSNull *)[errorDict valueForKey:@"time_difference"] != [NSNull null]) {
                                [[[DCSharedObject sharedPreferences] preferences] setValue:[errorDict valueForKey:@"time_difference"] forKey:TIME_DIFFERENCE];
                                //[[NSUserDefaults standardUserDefaults] setValue:[errorDict valueForKey:@"time_difference"] forKey:TIME_DIFFERENCE];
                                //timestamp is adjusted. call the same url again
                                
                                [DCSharedObject makeURLCALLWithHTTPService:self.httpService extraHeaders:nil body:nil identifier:HELPDESK requestMethod:kRequestMethodGET model:HELPDESK delegate:self viewController:self];
                            }
                        } else {
                            [DCSharedObject showAlertWithMessage:@"INTERNAL_SERVER_ERROR"];
                        }
                    }
                } else {
                    [DCSharedObject showAlertWithMessage:NSLocalizedString(@"INTERNAL_SERVER_ERROR", @"")];
                }
            }
        }
    }
}


#pragma mark - DCPickListViewControllerDelegate
-(void) pickListDidPickItem:(id)item ofType:(NSInteger)type {
    switch (type) {
        case DCPickListItemSurveyTrailerId:
            if (!self.surveyModel) {
                self.surveyModel = [[[DCSurveyModel alloc] init] autorelease];
            }
            self.surveyModel.surveyTrailerId = item;
            break;
        case DCPickListItemSurveyPlace:
            if (!self.surveyModel) {
                self.surveyModel = [[[DCSurveyModel alloc] init] autorelease];
            }
            self.surveyModel.surveyPlace = item;
            break;
        case DCPickListItemSurveyPlates:
            if (!self.surveyModel) {
                self.surveyModel = [[[DCSurveyModel alloc] init] autorelease];
            }
            self.surveyModel.surveyPlates = item;
            break;
        case DCPickListItemSurveyStraps:
            if (!self.surveyModel) {
                self.surveyModel = [[[DCSurveyModel alloc] init] autorelease];
            }
            self.surveyModel.surveyStraps = item;
            break;
        default:
            break;
    }
    
    [self toggleActionButtons];
    [self.surveyTableView reloadData];
}

-(void) pickListDidPickItems:(NSArray *)items ofType:(NSInteger)type {
    
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


#pragma mark - HTTPServiceDelegate methods
-(void) responseCode:(int)code {
    self.httpStatusCode = code;
}

-(void) didReceiveResponse:(NSData *)data forIdentifier:(NSString *)identifier {
    [DCSharedObject hideProgressDialogInView:self.view];
    NSString *responseString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
#if kDebug
    NSLog(@"%@: %@", identifier, responseString);
#endif

    if (self.httpStatusCode == 200 || self.httpStatusCode == 403) {
        [self parseResponse:[DCSharedObject decodeSwedishHTMLFromString:responseString] forIdentifier:identifier];
    } else {
        [DCSharedObject showAlertWithMessage:NSLocalizedString(@"INTERNAL_SERVER_ERROR", @"")];
    }

}

-(void) serviceDidFailWithError:(NSError *)error forIdentifier:(NSString *)identifier {
    [DCSharedObject hideProgressDialogInView:self.view];
    if ([error code] >= kNetworkConnectionError && [error code] <= kHostUnreachableError) {
        [DCSharedObject showAlertWithMessage:NSLocalizedString(@"NETWORK_ERROR", @"")];
    } else {
        [DCSharedObject showAlertWithMessage:NSLocalizedString(@"INTERNAL_SERVER_ERROR", @"")];
    }
    

}

-(void) storeResponse:(NSData *)data forIdentifier:(NSString *)identifier {
    
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
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SimpleCell"] autorelease];
        }
    }
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0: {
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    UILabel *titleLabel = (UILabel *)[cell viewWithTag:CUSTOM_CELL_SEGMENTED_TITE_LABEL_TAG];
                    titleLabel.text = NSLocalizedString(@"TRAILER_TYPE", @"");
                    
                    UISegmentedControl *segmentedControl = (UISegmentedControl *)[cell viewWithTag:CUSTOM_CELL_SEGMENTED_SEGMENTED_VIEW_TAG];
                    [segmentedControl setTitle:NSLocalizedString(@"OWN", @"") forSegmentAtIndex:0];
                    [segmentedControl setTitle:NSLocalizedString(@"RENTED", @"") forSegmentAtIndex:1];
                    if ([[self.surveyModel.surveyTrailerType lowercaseString] isEqualToString:NSLocalizedString(@"RENTED", @"")]) {
                        [segmentedControl setSelectedSegmentIndex:1];
                    }
                    [segmentedControl addTarget:self action:@selector(toggleTrailerType:) forControlEvents:UIControlEventValueChanged];
                }
                    break;
                case 1: {
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    
                    cell.textLabel.shadowColor = [UIColor whiteColor];
                    cell.textLabel.shadowOffset = CGSizeMake(1, 1);
                    if (self.surveyModel.surveyTrailerId) {
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"ID", @""), self.surveyModel.surveyTrailerId];
                         [self.navigationItem.rightBarButtonItem setEnabled:YES];
                        
                    } else {
                        cell.textLabel.text = NSLocalizedString(@"ID", @"");
                    }
                }
                    break;
                case 2: {                    
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.textLabel.shadowColor = [UIColor whiteColor];
                    cell.textLabel.shadowOffset = CGSizeMake(1, 1);
                    if (self.surveyModel.surveyPlace) {
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"PLACE", @""), self.surveyModel.surveyPlace];
                    } else {
                        cell.textLabel.text = NSLocalizedString(@"PLACE", @"");
                    }
                }
                    break;
                case 3: {
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    UILabel *titleLabel = (UILabel *)[cell viewWithTag:CUSTOM_CELL_SEGMENTED_TITE_LABEL_TAG];
                    titleLabel.text = NSLocalizedString(@"SEALED", @"");
                    
                    UISegmentedControl *segmentedControl = (UISegmentedControl *)[cell viewWithTag:CUSTOM_CELL_SEGMENTED_SEGMENTED_VIEW_TAG];
                    if ([[[DCSharedObject sharedPreferences] preferences] valueForKey:HELPDESK_SEALED]) {
                        NSString *yesString = [[[DCSharedObject sharedPreferences] preferences] valueForKey:@"Yes"];
                        NSString *noString = [[[DCSharedObject sharedPreferences] preferences] valueForKey:@"No"];
                        if (yesString && noString) {
                            [segmentedControl setTitle:yesString forSegmentAtIndex:0];
                            [segmentedControl setTitle:noString forSegmentAtIndex:1];
                        } else {
                            [segmentedControl setTitle:NSLocalizedString(@"YES", @"") forSegmentAtIndex:0];
                            [segmentedControl setTitle:NSLocalizedString(@"NO", @"") forSegmentAtIndex:1];
                        }
                    } else {
                        [segmentedControl setTitle:NSLocalizedString(@"YES", @"") forSegmentAtIndex:0];
                        [segmentedControl setTitle:NSLocalizedString(@"NO", @"") forSegmentAtIndex:1];
                    }
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
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.textLabel.shadowColor = [UIColor whiteColor];
                    cell.textLabel.shadowOffset = CGSizeMake(1, 1);
                    
                    if (self.surveyModel.surveyPlates) {
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"PLATES", @""), self.surveyModel.surveyPlates];
                        } else {
                        cell.textLabel.text = NSLocalizedString(@"PLATES", @"");
                    }
                }
                    break;
                case 1: {
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.textLabel.shadowColor = [UIColor whiteColor];
                    cell.textLabel.shadowOffset = CGSizeMake(1, 1);
                    
                    if (self.surveyModel.surveyStraps) {
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"STRAPS", @""), self.surveyModel.surveyStraps];
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
                    
                    DCPickListViewController *pickListViewController = [[[DCPickListViewController alloc] initWithNibName:@"PickListView" bundle:nil modelArray:nil type:DCPickListItemSurveyTrailerId isSingleValue:YES] autorelease];
                    pickListViewController.delegate = self;
                    [self.navigationController pushViewController:pickListViewController animated:YES];
                }
                    break;
                case 2: {
                    //dummy values
                    NSArray *trailerIdArray = [NSArray arrayWithObjects:@"Place 1", @"Place 2", @"Place 3", @"Place 4", nil];
                    
                    DCPickListViewController *pickListViewController = [[[DCPickListViewController alloc] initWithNibName:@"PickListView" bundle:nil modelArray:trailerIdArray type:DCPickListItemSurveyPlace isSingleValue:YES] autorelease];
                    pickListViewController.delegate = self;
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
                    
                    DCPickListViewController *pickListViewController = [[[DCPickListViewController alloc] initWithNibName:@"PickListView" bundle:nil modelArray:trailerIdArray type:DCPickListItemSurveyPlates isSingleValue:YES] autorelease];
                    pickListViewController.delegate = self;
                    [self.navigationController pushViewController:pickListViewController animated:YES];
                }
                    break;
                case 1: {
                    //dummy values
                    NSArray *trailerIdArray = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", nil];
                    
                    DCPickListViewController *pickListViewController = [[[DCPickListViewController alloc] initWithNibName:@"PickListView" bundle:nil modelArray:trailerIdArray type:DCPickListItemSurveyStraps isSingleValue:YES] autorelease];
                    pickListViewController.delegate = self;
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
