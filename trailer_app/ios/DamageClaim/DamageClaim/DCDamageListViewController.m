//
//  DCDamageListViewController.m
//  DamageClaim
//
//  Created by Dev on 29/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DCDamageListViewController.h"

#import "DCDamageDetailModel.h"

#import "Const.h"

#import "DCDamageViewController.h"

#import "DCSharedObject.h"

#import "DCDamageDetailViewController.h"

#import "DCLoginViewController.h"

#import "MBProgressHUD.h"

#import "RequestHeaders.h"

#import "JSONKit.h"

#import "NSData+Base64.h"


@interface DCDamageListViewController ()
@property (retain, nonatomic) IBOutlet UIBarButtonItem *editBarButtonItem;
@property (retain, nonatomic) IBOutlet UITableView *damageTableView;
@property (retain, nonatomic) NSMutableArray *currentDamageArray;
@property (retain, nonatomic) NSMutableArray *damageListModelArray;
@property (retain, nonatomic) DCSurveyModel *surveyModel;
@property (nonatomic) NSInteger submittingDamageIndex;
@property (nonatomic) NSInteger totalCurrentDamages;
@property (retain, nonatomic) HTTPService *httpService;
@property (nonatomic) NSInteger httpStatusCode;
@property (nonatomic, getter = isGetDamageListCalled) BOOL getDamageListCalled;
-(void) customizeNavigationBar;
-(void) logout;
-(void) submitDamageReport;
-(void) submitDamageReportAtIndex:(NSInteger) index;
-(NSInteger) checkDuplicateModel:(DCDamageDetailModel *) model;
-(void) tranferImagesFromOldModel:(DCDamageDetailModel *)oldModel toNewModel:(DCDamageDetailModel *)newModel;
-(void) toggleActionButtons;
- (IBAction)editTable:(id)sender;
-(void) getDamageList;
-(void) parseResponse:(NSString *)responseString forIdentifier:(NSString *) identifier;
-(void) disableActions;
-(void) enableActions;
-(void) goBack;
@end

@implementation DCDamageListViewController
@synthesize editBarButtonItem = _editBarButtonItem;
@synthesize damageTableView = _damageTableView;
@synthesize damageListModelArray = _damageListModelArray;
@synthesize currentDamageArray = _currentDamageArray;
@synthesize surveyModel = _surveyModel;
@synthesize submittingDamageIndex = _submittingDamageIndex;
@synthesize  totalCurrentDamages = _totalCurrentDamages;
@synthesize httpService = _httpService;
@synthesize httpStatusCode = _httpStatusCode;
@synthesize getDamageListCalled = _getDamageListCalled;

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
    
    if ([[[DCSharedObject sharedPreferences] preferences] valueForKey:SURVEY_MODEL]) {
        self.surveyModel = [[[DCSharedObject sharedPreferences] preferences] valueForKey:SURVEY_MODEL];
        //remove the value after use
        [[[DCSharedObject sharedPreferences] preferences] removeObjectForKey:SURVEY_MODEL];
    }
    
    [self customizeNavigationBar];
    
    

    [self.damageTableView reloadData];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![self isGetDamageListCalled]) {
        [self setGetDamageListCalled:YES];
        [self getDamageList];
    }
    //always use the update modelArray from DCSharedObject
    //and reload the tableView
    if ([[[DCSharedObject sharedPreferences] preferences] valueForKey:DAMAGE_DETAIL_MODEL]) {
        DCDamageDetailModel *damageDetailModel = [[[DCSharedObject sharedPreferences] preferences] valueForKey:DAMAGE_DETAIL_MODEL];
        NSInteger index = [self checkDuplicateModel:damageDetailModel];
        if (index == -1) {
            if (!self.currentDamageArray) {
                self.currentDamageArray = [[[NSMutableArray alloc] init] autorelease];
            }
            if (self.surveyModel) {
                damageDetailModel.surveyModel = self.surveyModel;
            }
            
            [self.currentDamageArray addObject:damageDetailModel];
            [self.damageTableView reloadData];
        } else {
            [self tranferImagesFromOldModel:damageDetailModel toNewModel:[self.currentDamageArray objectAtIndex:index]];
            [self.damageTableView reloadData];
            
            //select the row after reloading it. the row numbers will not change
            [self.damageTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1] animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
        //clear the selected object from DCSharedObject
        [[[DCSharedObject sharedPreferences] preferences] removeObjectForKey:DAMAGE_DETAIL_MODEL];
        [self toggleActionButtons];
    }
}


-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.navigationController) {
        [DCSharedObject hideProgressDialogInView:self.navigationController.view];
    } else {
        [DCSharedObject hideProgressDialogInView:self.view];
    }
}

- (void)viewDidUnload
{
    [self setEditBarButtonItem:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:RESET_SURVEY_NOTIFICATION object:nil]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) dealloc {
#if kDebug
    NSLog(@"DamageList Deallocated");
#endif
    [_damageTableView release];
    [_damageListModelArray release];
    [_currentDamageArray release];
    [_editBarButtonItem release];
    [_surveyModel release];
    [_httpService release];
    [super dealloc];

}

#pragma mark - Others
-(void) customizeNavigationBar {
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"APPROVE_DAMAGE", @"") style:UIBarButtonItemStylePlain target:self action:@selector(submitDamageReport)] autorelease];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BACK", @"") style:UIBarButtonItemStylePlain target:self action:@selector(goBack)] autorelease];
    [self toggleActionButtons];
}

-(void) logout {
    
}

-(void) submitDamageReport {
    
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"CONFIRM_DAMAGE_SUBMIT", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", @"") otherButtonTitles:NSLocalizedString(@"SUBMIT", @"") , nil] autorelease];
    [alertView show];
    
}

//sends the damage report to the server
-(void) submitDamageReportAtIndex:(NSInteger)index {
    if (self.currentDamageArray) {
        if (self.submittingDamageIndex < [self.currentDamageArray count]) {
            DCDamageDetailModel *damageDetailModel = [self.currentDamageArray objectAtIndex:index];
            //make a dictionary of post data
            NSMutableDictionary *bodyDict = [[[NSMutableDictionary alloc] init] autorelease];

            NSDictionary *reportDamageDict = [[[DCSharedObject sharedPreferences] preferences] valueForKey:HELPDESK_REPORTDAMAGE];
            if (reportDamageDict) {
                NSString *reportDamageNoValue = [reportDamageDict valueForKey:@"Yes"];
#if kDebug
                NSLog(@"%@", reportDamageNoValue);
#endif
                if (reportDamageDict) {
                    [bodyDict setValue:reportDamageNoValue forKey:@"reportdamage"];
                } else {
                    [bodyDict setValue:@"Yes" forKey:@"reportdamage"];
                }
            } else {
                [bodyDict setValue:@"Yes" forKey:@"reportdamage"];
            }

            NSDictionary *ticketStatusDict = [[[DCSharedObject sharedPreferences] preferences] valueForKey:HELPDESK_TICKETSTATUS];
            if (ticketStatusDict) {
                NSString *ticketStatusOpenValue = [ticketStatusDict valueForKey:@"Open"];
#if kDebug
                NSLog(@"%@, %@", ticketStatusDict, ticketStatusOpenValue);
#endif
                if (ticketStatusOpenValue) {
                    [bodyDict setValue:ticketStatusOpenValue forKey:@"ticketstatus"];
                } else {
                    [bodyDict setValue:@"Open" forKey:@"ticketstatus"];
                }
            } else {
                [bodyDict setValue:@"Open" forKey:@"ticketstatus"];
            }
            
            NSString *ticketTitle = @"";
            if ([[NSUserDefaults standardUserDefaults] valueForKey:CONTACT_NAME]) {
                ticketTitle = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"DAMAGE_TICKET_TITLE", @""), [[NSUserDefaults standardUserDefaults] valueForKey:CONTACT_NAME]];
            }
            [bodyDict setValue:ticketTitle forKey:@"ticket_title"];

            
            if (damageDetailModel.surveyModel.surveyAssetModel.trailerId) {
                [bodyDict setValue:damageDetailModel.surveyModel.surveyAssetModel.trailerId forKey:@"trailerid"];
            }
            
            if (damageDetailModel.surveyModel.surveyPlace) {
                [bodyDict setValue:damageDetailModel.surveyModel.surveyPlace forKey:@"damagereportlocation"];
            }

            if (damageDetailModel.surveyModel.surveyTrailerSealed) {
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
            
            if (damageDetailModel.damageDriverCausedDamage) {
                NSDictionary *driverCausedDamageDict = [[[DCSharedObject sharedPreferences] preferences] valueForKey:HELPDESK_DRIVERCAUSEDDAMAGE];
                if (driverCausedDamageDict) {
                    NSString *yesValue = [driverCausedDamageDict valueForKey:@"Yes"];
                    NSString *noValue = [driverCausedDamageDict valueForKey:@"No"];
#if kDebug
                    NSLog(@"%@ %@", yesValue, noValue);
#endif
                    if ([[damageDetailModel.damageDriverCausedDamage lowercaseString] isEqualToString:@"yes"]) {
                        [bodyDict setValue:yesValue forKey:@"drivercauseddamage"];
                    } else {
                        [bodyDict setValue:noValue forKey:@"drivercauseddamage"];
                    }
                } else {
                    if ([[damageDetailModel.damageDriverCausedDamage lowercaseString] isEqualToString:@"yes"]) {
                        [bodyDict setValue:@"Yes" forKey:@"drivercauseddamage"];
                    } else {
                        [bodyDict setValue:@"No" forKey:@"drivercauseddamage"];
                    }
                }
            } else {
                [bodyDict setValue:@"No" forKey:@"drivercauseddamage"];
            }
            
            if (damageDetailModel.surveyModel.surveyPlates) {
                [bodyDict setValue:[NSString stringWithFormat:@"%d", [damageDetailModel.surveyModel.surveyPlates intValue]] forKey:@"plates"];
            }
            
            if (damageDetailModel.surveyModel.surveyStraps) {
                [bodyDict setValue:[NSString stringWithFormat:@"%d", [damageDetailModel.surveyModel.surveyStraps intValue]] forKey:@"straps"];
            }
            
            if (damageDetailModel.damageType) {
                [bodyDict setValue:damageDetailModel.damageType forKey:@"damagetype"];
            }
            
            if (damageDetailModel.damagePosition) {
                [bodyDict setValue:damageDetailModel.damagePosition forKey:@"damageposition"];
            }
            
            NSString *boundary = @"----------ThIs_Is_tHe_bouNdaRY_$";
            // post body
            NSMutableData *body = [NSMutableData data];
            
            // add params (all params are strings)
            for (NSString *param in bodyDict) {
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"%@\r\n", [bodyDict objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
            }
            
            // add image data
            for (NSString *imagePath in damageDetailModel.damageImagePaths) {
                if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
                    NSData *imageData = [[NSFileManager defaultManager] contentsAtPath:imagePath];
                    if (imageData) {
                        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                        //the file name is a combination of damageType, damagePosition and the index of this image in the array
                        [body appendData:[[NSString stringWithFormat:
                                           @"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", 
                                           [NSString stringWithFormat:@"%@%@%d", damageDetailModel.damageType, damageDetailModel.damageType, [damageDetailModel.damageImagePaths indexOfObject:imagePath]],
                                           [NSString stringWithFormat:@"image%d", [damageDetailModel.damageImagePaths indexOfObject:imagePath]]]
                                          dataUsingEncoding:NSUTF8StringEncoding]];
                        
#if kDebug
                        NSLog(@"%@", [[NSString stringWithFormat:
                                      @"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", 
                                      [NSString stringWithFormat:@"%@%@%d", damageDetailModel.damageType, damageDetailModel.damageType, [damageDetailModel.damageImagePaths indexOfObject:imagePath]],
                                      [NSString stringWithFormat:@"%@%@%d", damageDetailModel.damageType, damageDetailModel.damageType, [damageDetailModel.damageImagePaths indexOfObject:imagePath]]]
                              dataUsingEncoding:NSUTF8StringEncoding]);
#endif
                        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                        [body appendData:imageData];
                        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                    }
                }
                
            }
            [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
#if kDebug
            NSLog(@"%@", [[[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding] autorelease]);
#endif
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
            NSDictionary *extraHeaders = [NSDictionary dictionaryWithObjectsAndKeys:
                                          contentType, @"Content-Type",
                                          [NSString stringWithFormat:@"%d", [body length]], @"Content-Length", nil];
            
            [DCSharedObject makeURLCALLWithHTTPService:self.httpService extraHeaders:extraHeaders body:body identifier:HELPDESK requestMethod:kRequestMethodPOST model:HELPDESK delegate:self viewController:self showProgressView:NO];
#if kDebug
            NSLog(@"total: %d, current: %d percentage: %.0f", self.totalCurrentDamages, [self.currentDamageArray count], (((float)self.totalCurrentDamages - (float)[self.currentDamageArray count]) / (float)self.totalCurrentDamages) * 100);
#endif
            if (self.navigationController) {
                [DCSharedObject hideProgressDialogInView:self.navigationController.view];
            } else {
                [DCSharedObject hideProgressDialogInView:self.view];
            }
            
            [DCSharedObject showProgressDialogInView:self.navigationController.view message:[NSString stringWithFormat:@"%.0f%%", (((float)self.totalCurrentDamages - (float)[self.currentDamageArray count]) / (float)self.totalCurrentDamages) * 100]];
        }
    }
}

//checks if the newly created object already
//exists in the array. if yes, it returns its index otherwise returns -1
-(NSInteger) checkDuplicateModel:(DCDamageDetailModel *)model {
    if (model && self.currentDamageArray) {
        for (NSInteger i = 0; i < [self.currentDamageArray count]; i++) {
            DCDamageDetailModel *existingDamageDetailModel = [self.currentDamageArray objectAtIndex:i];
            if (existingDamageDetailModel.damageType && model.damageType) {
                if ([existingDamageDetailModel.damageType isEqualToString:model.damageType]) {
                    if (existingDamageDetailModel.damagePosition && model.damagePosition) {
                        if ([existingDamageDetailModel.damagePosition isEqualToString:model.damagePosition]) {
                            return i;
                        }
                    }
                }
            }
        }
    }
    return -1;
}

//transfers all the imagePaths from newModel to oldModel
//add only those imagePaths which are not present
-(void) tranferImagesFromOldModel:(DCDamageDetailModel *)oldModel toNewModel:(DCDamageDetailModel *)newModel {
    if (oldModel.damageImagePaths) {
        if (!newModel.damageImagePaths) {
            newModel.damageImagePaths = [[[NSMutableArray alloc] init] autorelease];
            newModel.damageImagePaths = oldModel.damageImagePaths;
            newModel.damageThumbnailImagePaths = newModel.damageThumbnailImagePaths;
        } else {
            for (NSString *oldFilePath in oldModel.damageImagePaths) {
                BOOL matched = NO;
                for (NSString *newFilePath in newModel.damageImagePaths) {
                    if ([newFilePath isEqualToString:oldFilePath]) {
                        matched = YES;
                        break;
                    }
                }
                if (!matched) {
                    [newModel.damageImagePaths addObject:oldFilePath];
                    NSInteger index = [oldModel.damageImagePaths indexOfObject:oldFilePath];
                    [newModel.damageThumbnailImagePaths addObject:[oldModel.damageThumbnailImagePaths objectAtIndex:index]];
                }
            }
        }
#if kDebug
        NSLog(@"After copy: %@", newModel.damageThumbnailImagePaths);
#endif
    }
}

-(void) toggleActionButtons {
    if (self.currentDamageArray) {
        if ([self.currentDamageArray count] > 0) {
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
            [self.editBarButtonItem setEnabled:YES];
        } else {
            [self.navigationItem.rightBarButtonItem setEnabled:NO];
            [self.editBarButtonItem setEnabled:NO];
        }
    } else {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        [self.editBarButtonItem setEnabled:NO];
    }
}

- (IBAction)editTable:(id)sender {
    UIBarButtonItem *editButton = (UIBarButtonItem *)sender;
    if (self.editing) {
        [super setEditing:NO];
        [self.damageTableView setEditing:NO];
        [editButton setTitle:NSLocalizedString(@"EDIT", @"")];
        [self toggleActionButtons];
    } else {
        [super setEditing:YES];
        [self.damageTableView setEditing:YES];
        [editButton setTitle:NSLocalizedString(@"DONE", @"")];
    }
}

-(void) getDamageList {
    [DCSharedObject makeURLCALLWithHTTPService:self.httpService extraHeaders:nil body:nil identifier:HELPDESK_DAMAGED requestMethod:kRequestMethodGET model:HELPDESK delegate:self viewController:self];
}

-(void) parseResponse:(NSString *)responseString forIdentifier:(NSString *)identifier {
    //logout irrespective of the response string
    if ([identifier isEqualToString:AUTHENTICATE_LOGOUT]) {
        if (self.navigationController) {
            [DCSharedObject hideProgressDialogInView:self.navigationController.view];
        } else {
            [DCSharedObject hideProgressDialogInView:self.view];
        }
        [DCSharedObject processLogout:self.navigationController clearData:NO];
        return;
    } else
    if (responseString) {
        NSDictionary *jsonDict = [responseString objectFromJSONString];
        if ([identifier isEqualToString:HELPDESK_DAMAGED]) {
            if ((NSNull *)[jsonDict valueForKey:SUCCESS] != [NSNull null]) {
                NSString *status = [jsonDict valueForKey:SUCCESS];
                if ([status boolValue]) {
                    
                    //clear all the objects
                    if (self.damageListModelArray) {
                        [self.damageListModelArray removeAllObjects];
                    }
                    if ((NSNull *)[jsonDict valueForKey:@"result"] != [NSNull null]) {
                        NSArray *resultsArray = [jsonDict valueForKey:@"result"];
                        for (NSDictionary *damageDict in resultsArray) {
                            DCDamageDetailModel *damageDetailModel = [[[DCDamageDetailModel alloc] init] autorelease];
#if kDebug
                            NSLog(@"DamageDict: %@", damageDict);
#endif

                            if ((NSNull *)[damageDict valueForKey:@"id"] != [NSNull null]) {
                                damageDetailModel.damageId = [damageDict valueForKey:@"id"];
                            }

                            if ((NSNull *)[damageDict valueForKey:@"trailerid"] != [NSNull null]) {
                                if (!damageDetailModel.surveyModel) {
                                    damageDetailModel.surveyModel = [[[DCSurveyModel alloc] init] autorelease];

                                }
                                damageDetailModel.surveyModel.surveyAssetModel.trailerId = [damageDict valueForKey:@"trailerid"];
                            }

                            
                            if ((NSNull *)[damageDict valueForKey:@"damagereportlocation"] != [NSNull null]) {
                                if (!damageDetailModel.surveyModel) {
                                    damageDetailModel.surveyModel = [[[DCSurveyModel alloc] init] autorelease];

                                }
                                damageDetailModel.surveyModel.surveyPlace = [damageDict valueForKey:@"damagereportlocation"];

                            }

                            
                            //sealed is received as a string and converted to NSNumber
                            if ((NSNull *)[damageDict valueForKey:@"sealed"] != [NSNull null]) {
                                if (!damageDetailModel.surveyModel) {
                                    damageDetailModel.surveyModel = [[[DCSurveyModel alloc] init] autorelease];

                                }
                                NSString *sealed = [damageDict valueForKey:@"sealed"];
                                damageDetailModel.surveyModel.surveyTrailerSealed = [NSNumber numberWithBool:[[sealed lowercaseString] isEqualToString:@"yes"]? YES: NO];

                            }
                            
                            if ((NSNull *)[damageDict valueForKey:@"plates"] != [NSNull null]) {
                                if (!damageDetailModel.surveyModel) {
                                    damageDetailModel.surveyModel = [[[DCSurveyModel alloc] init] autorelease];
                                }
                                damageDetailModel.surveyModel.surveyPlates = [NSNumber numberWithInt:[[damageDict valueForKey:@"plates"] intValue]];
                            }
                            
                            
                            if ((NSNull *)[damageDict valueForKey:@"straps"] != [NSNull null]) {
                                if (!damageDetailModel.surveyModel) {
                                    damageDetailModel.surveyModel = [[[DCSurveyModel alloc] init] autorelease];
                                }
                                damageDetailModel.surveyModel.surveyStraps = [NSNumber numberWithInt:[[damageDict valueForKey:@"straps"] intValue]];
                            }
                                                        
                            if ((NSNull *)[damageDict valueForKey:@"damagetype"] != [NSNull null]) {
                                damageDetailModel.damageType = [damageDict valueForKey:@"damagetype"];
                            }
                            
                            
                            if ((NSNull *)[damageDict valueForKey:@"drivercauseddamage"] != [NSNull null]) {
                                damageDetailModel.damageDriverCausedDamage = [damageDict valueForKey:@"drivercauseddamage"];
                            }
                            
                            
                            
                            if ((NSNull *)[damageDict valueForKey:@"damageposition"] != [NSNull null]) {
                                damageDetailModel.damagePosition = [damageDict valueForKey:@"damageposition"];
                            }
                            
                            if (!self.damageListModelArray) {
                                self.damageListModelArray = [[[NSMutableArray alloc] init] autorelease];
                            }
                            
                            [self.damageListModelArray addObject:damageDetailModel];
                        }
                    }
                } else if ((NSNull *)[jsonDict valueForKey:@"error"] != [NSNull null]) {
                    NSDictionary *errorDict = [jsonDict valueForKey:@"error"];
                    if ((NSNull *)[errorDict valueForKey:@"code"] != [NSNull null]) {
                        NSString *errorCode = [errorDict valueForKey:@"code"];
                        if ([errorCode isEqualToString:TIME_NOT_IN_SYNC]) {
                            if ((NSNull *)[errorDict valueForKey:@"time_difference"] != [NSNull null]) {
                                [[[DCSharedObject sharedPreferences] preferences] setValue:[errorDict valueForKey:@"time_difference"] forKey:TIME_DIFFERENCE];

                                //timestamp is adjusted. call the same url again
                                [self getDamageList];
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
        
        if ([identifier isEqualToString:HELPDESK]) {
            if ((NSNull *)[jsonDict valueForKey:SUCCESS] != [NSNull null]) {
                NSString *status = [jsonDict valueForKey:SUCCESS];
                if ([status boolValue]) {
#if kDebug
                    NSLog(@"s: %d, c: %d", self.submittingDamageIndex, [self.currentDamageArray count]);
#endif
                    if (self.submittingDamageIndex < [self.currentDamageArray count] - 1) {
                        [self.currentDamageArray removeObjectAtIndex:self.submittingDamageIndex];
                        //self.submittingDamageIndex will always be zero since the next damageClaim to submit 
                        //is always at zero
                        [self submitDamageReportAtIndex:self.submittingDamageIndex];
                    } else if (self.submittingDamageIndex == [self.currentDamageArray count] - 1) {
                        [self.currentDamageArray removeObjectAtIndex:self.submittingDamageIndex];
                        if ([self.currentDamageArray count] == 0) { //if all the damages were sent successfully, make the array nil
                            self.currentDamageArray = nil;
                            self.submittingDamageIndex = 0;
                            self.totalCurrentDamages = 0;
                            if (self.navigationController) {
                                [DCSharedObject hideProgressDialogInView:self.navigationController.view];
                            } else {
                                [DCSharedObject hideProgressDialogInView:self.view];
                            }
                            [self showAlertWithMessage:NSLocalizedString(@"DAMAGE_REPORTED_SUCCESSFULLY", @"")];
                            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:RESET_SURVEY_NOTIFICATION object:nil]];
                        }
                        [self enableActions];
                        
                        //update the damage list
                        //[self getDamageList];
                    }
                    //check if the call failed because of timestamp
                    //if yes, adjust the timestamp and hit the url again
                } else if ((NSNull *)[jsonDict valueForKey:@"error"] != [NSNull null]) {
                    NSDictionary *errorDict = [jsonDict valueForKey:@"error"];
                    if ((NSNull *)[errorDict valueForKey:@"code"] != [NSNull null]) {
                        NSString *errorCode = [errorDict valueForKey:@"code"];
                        if ([errorCode isEqualToString:TIME_NOT_IN_SYNC]) {
                            if ((NSNull *)[errorDict valueForKey:@"time_difference"] != [NSNull null]) {
                                [[[DCSharedObject sharedPreferences] preferences] setValue:[errorDict valueForKey:@"time_difference"] forKey:TIME_DIFFERENCE];

                                //timestamp is adjusted. call the same url again
#if kDebug
                                NSLog(@"s: %d, c: %d", self.submittingDamageIndex, [self.currentDamageArray count]);
#endif

                                if (self.submittingDamageIndex < [self.currentDamageArray count]) {
                                    //self.submittingDamageIndex will always be zero since the next damageClaim to submit 
                                    //is always at zero
                                    [self submitDamageReportAtIndex:self.submittingDamageIndex];
                                }
                            }
                        } else {
                            [self showAlertWithMessage:NSLocalizedString(@"SUBMIT_DAMAGE_ERROR", @"")];
                        }
                    }
                }
            }
        }
    }
#if kDebug
    NSLog(@"Parse Ended");
#endif

    [self toggleActionButtons];
    [self.damageTableView reloadData];
}

-(void) disableActions {
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [self.editBarButtonItem setEnabled:NO];
}

-(void) enableActions {
    [self toggleActionButtons];
}

-(void) goBack {

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIAlertViewDelegate methods
-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [super alertView:alertView didDismissWithButtonIndex:buttonIndex];
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"LOGOUT", @"")]) {
        [DCSharedObject makeURLCALLWithHTTPService:self.httpService extraHeaders:nil body:nil identifier:AUTHENTICATE_LOGOUT requestMethod:kRequestMethodGET model:AUTHENTICATE delegate:self viewController:self];
    }
    
    if ([[alertView message] isEqualToString:NSLocalizedString(@"DAMAGE_REPORTED_SUCCESSFULLY", @"")]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    if ([[alertView message] isEqualToString:NSLocalizedString(@"SUBMIT_DAMAGE_ERROR", @"")] &&
        [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"YES", @"")] ) {
        if (self.currentDamageArray) {
            if ([self.currentDamageArray count] > 0) {
                self.submittingDamageIndex = 0;
                [self submitDamageReportAtIndex:self.submittingDamageIndex];
            }
        }
    }
    
    if ([[alertView message] isEqualToString:NSLocalizedString(@"CONFIRM_DAMAGE_SUBMIT", @"")] &&
        [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"SUBMIT", @"")]) {
        if (!self.surveyModel.surveyAssetModel.trailerId) {
            [self showAlertWithMessage:NSLocalizedString(@"TRAILER_ID_NULL_ERROR", @"")];
        } else {
            [self disableActions];
            self.submittingDamageIndex = 0;
            self.totalCurrentDamages = [self.currentDamageArray count];
            [self submitDamageReportAtIndex:self.submittingDamageIndex];
        }
    }
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
    if (![identifier isEqualToString:HELPDESK]) {
        if (self.navigationController) {
            [DCSharedObject hideProgressDialogInView:self.navigationController.view];
        } else {
            [DCSharedObject hideProgressDialogInView:self.view];
        }
    }
}

-(void) serviceDidFailWithError:(NSError *)error forIdentifier:(NSString *)identifier {
    if ([identifier isEqualToString:HELPDESK]) {
        if (self.navigationController) {
            [DCSharedObject hideProgressDialogInView:self.navigationController.view];
        } else {
            [DCSharedObject hideProgressDialogInView:self.view];
        }
        if (self.submittingDamageIndex < [self.currentDamageArray count]) {
            self.submittingDamageIndex++;
            [self submitDamageReportAtIndex:self.submittingDamageIndex];
#if kDebug
            NSLog(@"submittingindex: %d, array: %d", self.submittingDamageIndex, [self.currentDamageArray count]);
#endif
        }
        if (self.submittingDamageIndex == [self.currentDamageArray count] - 1) {
            [self showAlertWithMessage:NSLocalizedString(@"SUBMIT_DAMAGE_ERROR", @"")];
            [self enableActions];
            
            //update the damage list
            [self getDamageList];
        }
    } else {
        if ([error code] >= kNetworkConnectionError && [error code] <= kHostUnreachableError) {
            [self showAlertWithMessage:NSLocalizedString(@"NETWORK_ERROR", @"")];
        } else if ([identifier isEqualToString:AUTHENTICATE_LOGOUT]) {
            [DCSharedObject processLogout:self.navigationController clearData:NO];
            
        } else {
            [self showAlertWithMessage:NSLocalizedString(@"INTERNAL_SERVER_ERROR", @"")];
        }

    }
    
}

-(void) storeResponse:(NSData *)data forIdentifier:(NSString *)identifier {
    
}

#pragma mark - UITableViewDataSource methods

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfSections = 1;
    if (self.damageListModelArray) {
        if ([self.damageListModelArray count] > 0) {
            numberOfSections++;
        }
    }
    
    if (self.currentDamageArray) {
        if ([self.currentDamageArray count] > 0) {
            numberOfSections++;
        }
    }
    return numberOfSections;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch ([tableView numberOfSections]) {
        case 1:
            //currentDamageArray and damageDetailsModelArray is nil
            return 1;
            break;
        case 2:
            if (self.currentDamageArray) { //if currentDamageArray has elements and damageDetailsModelArray is nil
                if ([self.currentDamageArray count] > 0) {
                    switch (section) {
                        case 0:
                            return 1;
                            break;
                        case 1:
                            return [self.currentDamageArray count];
                            break;
                        default:
                            break;
                    }
                }
            }
            
            if (self.damageListModelArray) { //if damageDetailsModelArray has elements and currentDamageArray is nil
                if ([self.damageListModelArray count] > 0) {
                    switch (section) {
                        case 0:
                            return 1;
                            break;
                        case 1:
                            return [self.damageListModelArray count];
                        default:
                            break;
                    }
                }
            }
        case 3: //if currentDamageArray and DamageDetailsModelArray has elements
            switch (section) {
                case 0:
                    return 1;
                    break;
                case 1:
                    if (self.currentDamageArray) {
                        if ([self.currentDamageArray count] > 0) {
                            return [self.currentDamageArray count];
                        }
                    }
                case 2:
                    if (self.damageListModelArray) {
                        if ([self.damageListModelArray count] > 0) {
                            return [self.damageListModelArray count];
                        }
                    }
                default:
                    break;
            }
        default:
            break;
    }
    return 0;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.currentDamageArray) {
        if ([self.currentDamageArray count] > 0) {
            switch (section) {
                case 1:
                    return NSLocalizedString(@"REPORTING_DAMAGE", @"");
                    break;
                case 2:
                    return NSLocalizedString(@"PREVIOUSLY_REPORTED_DAMAGES", @"");
                default:
                    break;
            }
        }
    }
    if (section == 1) {
        return NSLocalizedString(@"PREVIOUSLY_REPORTED_DAMAGES", @"");
    }
    return @"";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
#if kDebug
    NSLog(@"Cell Started");
#endif
    UITableViewCell *cell;
    if (self.currentDamageArray) {
        if ([self.currentDamageArray count] > 0) {
            if (indexPath.section == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"SimpleCell"];
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
            }
            
            
            if (!cell) {
                if (indexPath.section == 0) {
                    NSArray *customCellAddNewItemView = [[NSBundle mainBundle] loadNibNamed:@"CustomCellAddNewItemView" owner:nil options:nil];
                    if (customCellAddNewItemView) {
                        if ([customCellAddNewItemView count] > 0) {
                            cell = [customCellAddNewItemView objectAtIndex:0];
                        }
                    }
                } else {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"] autorelease];                    
                }
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            
            if (indexPath.section == 0) {
                UILabel *titleLabel = (UILabel *)[cell viewWithTag:CUSTOM_CELL_LABEL_ADD_NEW_ITEM_TAG];
                titleLabel.text = NSLocalizedString(@"REPORT_NEW_DAMAGE", @"");
            } else if (indexPath.section == 1) {
                if (indexPath.row < [self.currentDamageArray count]) {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    
                    DCDamageDetailModel *damageModel = [self.currentDamageArray objectAtIndex:indexPath.row];
                    
                    cell.textLabel.text = @"";
                    if (damageModel.damageType) {
                        cell.textLabel.text = damageModel.damageType;
                    }
                    
                    cell.detailTextLabel.text = @"";
                    if (damageModel.damagePosition) {
                        cell.detailTextLabel.text = damageModel.damagePosition;
                    }
                }
            } else if (indexPath.row < [self.damageListModelArray count]) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                DCDamageDetailModel *damageModel = [self.damageListModelArray objectAtIndex:indexPath.row];
                
                cell.textLabel.text = @"";
                if (damageModel.damageType) {
                    cell.textLabel.text = damageModel.damageType;
                }
                
                cell.detailTextLabel.text = @"";
                if (damageModel.damagePosition) {
                    cell.detailTextLabel.text = damageModel.damagePosition;
                }
            }
            return cell;
        }
    }
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SimpleCell"];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    }
    
    
    if (!cell) {
        if (indexPath.section == 0) {
            NSArray *customCellAddNewItemView = [[NSBundle mainBundle] loadNibNamed:@"CustomCellAddNewItemView" owner:nil options:nil];
            if (customCellAddNewItemView) {
                if ([customCellAddNewItemView count] > 0) {
                    cell = [customCellAddNewItemView objectAtIndex:0];
                }
            }
        } else {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"] autorelease];
            
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    if (indexPath.section == 0) {
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:CUSTOM_CELL_LABEL_ADD_NEW_ITEM_TAG];
        titleLabel.text = NSLocalizedString(@"REPORT_NEW_DAMAGE", @"");
    } else if (indexPath.row < [self.damageListModelArray count]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        DCDamageDetailModel *damageModel = [self.damageListModelArray objectAtIndex:indexPath.row];
        
        cell.textLabel.text = @"";
        if (damageModel.damageType) {
            cell.textLabel.text = damageModel.damageType;
        }
        
        cell.detailTextLabel.text = @"";
        if (damageModel.damagePosition) {
            cell.detailTextLabel.text = damageModel.damagePosition;
        }
    }
#if kDebug
    NSLog(@"Cell Returned");
#endif

    return cell;
}

#pragma mark - UITableViewDelegate methods
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DCDamageDetailViewController *damageDetailViewController = nil;
    if (self.currentDamageArray) {
        if ([self.currentDamageArray count] > 0) {
            if (indexPath.section == 0) {
                if (!self.surveyModel.surveyAssetModel.trailerId) { // the user can submit the damage report only after setting the trailer id.
                    [self showAlertWithMessage:NSLocalizedString(@"TRAILER_ID_NULL_ERROR", @"")];
                    return;
                } else {
                    damageDetailViewController = [[[DCDamageDetailViewController alloc] initWithNibName:@"DamageDetailView" bundle:nil damageDetailModel:nil isEditable:YES] autorelease];
                }
                
            } else if (indexPath.section == 1) {
                if (indexPath.row < [self.currentDamageArray count]) {
                    damageDetailViewController = [[[DCDamageDetailViewController alloc] initWithNibName:@"DamageDetailView" bundle:nil damageDetailModel:[self.currentDamageArray objectAtIndex:indexPath.row] isEditable:YES] autorelease];
                }
            } else {
                if (self.damageListModelArray) {
                    if (indexPath.row < [self.damageListModelArray count]) {
                        damageDetailViewController = [[[DCDamageDetailViewController alloc] initWithNibName:@"DamageDetailView" bundle:nil damageDetailModel:[self.damageListModelArray objectAtIndex:indexPath.row]] autorelease];
                    }
                }
            }
        } else {
            if (indexPath.section == 0) {
                if (!self.surveyModel.surveyAssetModel.trailerId) { // the user can submit the damage report only after setting the trailer id.
                    [self showAlertWithMessage:NSLocalizedString(@"TRAILER_ID_NULL_ERROR", @"")];
                    return;
                } else {
                    damageDetailViewController = [[[DCDamageDetailViewController alloc] initWithNibName:@"DamageDetailView" bundle:nil damageDetailModel:nil isEditable:YES] autorelease];
                }
                
            } else {
                if (self.damageListModelArray) {
                    if (indexPath.row < [self.damageListModelArray count]) {
                        damageDetailViewController = [[[DCDamageDetailViewController alloc] initWithNibName:@"DamageDetailView" bundle:nil damageDetailModel:[self.damageListModelArray objectAtIndex:indexPath.row]] autorelease];
                    }
                }
                
            }
        }
    }else {
        if (indexPath.section == 0) {
            if (!self.surveyModel.surveyAssetModel.trailerId) { // the user can submit the damage report only after setting the trailer id.
#if kDebug
                NSLog(@"%@", self.surveyModel.surveyAssetModel.trailerId);
#endif
                [self showAlertWithMessage:NSLocalizedString(@"TRAILER_ID_NULL_ERROR", @"")];
                return;
            } else {
                damageDetailViewController = [[[DCDamageDetailViewController alloc] initWithNibName:@"DamageDetailView" bundle:nil damageDetailModel:nil isEditable:YES] autorelease];
            }
            
        } else {
            if (self.damageListModelArray) {
                if (indexPath.row < [self.damageListModelArray count]) {
                    damageDetailViewController = [[[DCDamageDetailViewController alloc] initWithNibName:@"DamageDetailView" bundle:nil damageDetailModel:[self.damageListModelArray objectAtIndex:indexPath.row]] autorelease];
                }
            }
        }
    }
    
    if (damageDetailViewController) {
        [self.navigationController pushViewController:damageDetailViewController animated:YES];
    }
    
}


-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.currentDamageArray) {
        if ([self.currentDamageArray count] > 0) {
            if (indexPath.section == 1) {
                return YES;
            }
        }
    }
    return NO;
}


-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.currentDamageArray removeObjectAtIndex:indexPath.row];
        if ([self.currentDamageArray count] == 0) {
            [self.damageTableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationTop];
            self.currentDamageArray = nil;
        } else {
            [self.damageTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        }
        
    }
}
@end
