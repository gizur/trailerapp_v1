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

#import "MBProgressHUD.h"

#import "RequestHeaders.h"

#import "JSONKit.h"


@interface DCDamageListViewController ()
@property (retain, nonatomic) IBOutlet UIBarButtonItem *editBarButtonItem;
@property (retain, nonatomic) IBOutlet UITableView *damageTableView;
@property (retain, nonatomic) NSMutableArray *currentDamageArray;
@property (retain, nonatomic) NSMutableArray *damageListModelArray;
@property (retain, nonatomic) DCSurveyModel *surveyModel;
@property (nonatomic) NSInteger submittingDamageIndex;
@property (retain, nonatomic) HTTPService *httpService;
@property (nonatomic) NSInteger httpStatusCode;

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

@end

@implementation DCDamageListViewController
@synthesize editBarButtonItem = _editBarButtonItem;
@synthesize damageTableView = _damageTableView;
@synthesize damageListModelArray = _damageListModelArray;
@synthesize currentDamageArray = _currentDamageArray;
@synthesize surveyModel = _surveyModel;
@synthesize submittingDamageIndex = _submittingDamageIndex;
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
    
    if ([[[DCSharedObject sharedPreferences] preferences] valueForKey:SURVEY_MODEL]) {
        self.surveyModel = [[[DCSharedObject sharedPreferences] preferences] valueForKey:SURVEY_MODEL];
        //remove the value after use
        [[[DCSharedObject sharedPreferences] preferences] removeObjectForKey:SURVEY_MODEL];
    }
    
    [self customizeNavigationBar];
    [self getDamageList];
    
    //fill array with dummy values
//    self.damageListModelArray = [[[NSMutableArray alloc] init] autorelease];
//    {
//        DCDamageDetailModel *damageModel = [[[DCDamageDetailModel alloc] init] autorelease];
//        damageModel.damageType = @"Doors";
//        damageModel.damagePosition = @"Left Side";
//        [self.damageListModelArray addObject:damageModel];
//    }
//    {
//        DCDamageDetailModel *damageModel = [[[DCDamageDetailModel alloc] init] autorelease];
//        damageModel.damageType = @"Outriggers";
//        damageModel.damagePosition = @"Top Side";
//        [self.damageListModelArray addObject:damageModel];
//    }
//    {
//        DCDamageDetailModel *damageModel = [[[DCDamageDetailModel alloc] init] autorelease];
//        damageModel.damageType = @"Undercover";
//        damageModel.damagePosition = @"Right Side";
//        [self.damageListModelArray addObject:damageModel];
//    }
//    {
//        DCDamageDetailModel *damageModel = [[[DCDamageDetailModel alloc] init] autorelease];
//        damageModel.damageType = @"Lighting";
//        damageModel.damagePosition = @"Front Side";
//        [self.damageListModelArray addObject:damageModel];
//    }
//    {
//        DCDamageDetailModel *damageModel = [[[DCDamageDetailModel alloc] init] autorelease];
//        damageModel.damageType = @"Breaks";
//        damageModel.damagePosition = @"Device Hood";
//        [self.damageListModelArray addObject:damageModel];
//    }
//    {
//        DCDamageDetailModel *damageModel = [[[DCDamageDetailModel alloc] init] autorelease];
//        damageModel.damageType = @"Doors";
//        damageModel.damagePosition = @"Right Side";
//        [self.damageListModelArray addObject:damageModel];
//    }
//    
//#if kDebug
//    for (DCDamageDetailModel *damage in self.damageListModelArray) {
//        NSLog(@"%@", damage.damageType);
//    }
//    
//#endif
    [self.damageTableView reloadData];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
    [self.httpService cancelHTTPService];
}

- (void)viewDidUnload
{
    [self setEditBarButtonItem:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) dealloc {
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
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SUBMIT", @"") style:UIBarButtonItemStylePlain target:self action:@selector(submitDamageReport)] autorelease];
    [self toggleActionButtons];
}

-(void) logout {
    
}

-(void) submitDamageReport {
    if (!self.surveyModel.surveyTrailerId) {
        [DCSharedObject showAlertWithMessage:NSLocalizedString(@"TRAILER_ID_NULL_ERROR", @"")];
    } else {
        [self disableActions];
        self.submittingDamageIndex = 0;
        [self submitDamageReportAtIndex:self.submittingDamageIndex];
    }
}

//sends the damage report to the server
-(void) submitDamageReportAtIndex:(NSInteger)index {
    if (self.currentDamageArray) {
        if (self.submittingDamageIndex < [self.currentDamageArray count]) {
            DCDamageDetailModel *damageDetailModel = [self.currentDamageArray objectAtIndex:index];
            //make a dictionary of post data
            NSMutableDictionary *bodyDict = [[[NSMutableDictionary alloc] init] autorelease];
#warning Fetch this from the pick list

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
#warning Fetch this from the pick list

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

            
            if (damageDetailModel.surveyModel.surveyTrailerId) {
                [bodyDict setValue:damageDetailModel.surveyModel.surveyTrailerId forKey:@"trailerid"];
            }
            
            if (damageDetailModel.surveyModel.surveyPlace) {
                [bodyDict setValue:damageDetailModel.surveyModel.surveyPlace forKey:@"damagereportlocation"];
            }
#warning Fetch this from the pick list

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
                        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", [NSString stringWithFormat:@"%@%@%d", damageDetailModel.damageType, damageDetailModel.damageType, [damageDetailModel.damageImagePaths indexOfObject:imagePath]]] dataUsingEncoding:NSUTF8StringEncoding]];
                        [body appendData:[[NSString stringWithString:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
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
            [DCSharedObject makeURLCALLWithHTTPService:self.httpService extraHeaders:extraHeaders body:body identifier:HELPDESK requestMethod:kRequestMethodPOST model:HELPDESK delegate:self viewController:self];
            
//            // set URL
//            [request setURL:[NSURL URLWithString:[DCSharedObject createURLStringFromIdentifier:HELPDESK]]];
//            
//            
//            NSString *urlString = [DCSharedObject createURLStringFromIdentifier:HELPDESK];
//#if kDebug
//            NSLog(@"%@", urlString);
//#endif
//            
//            if (!self.httpService) {
//                self.httpService = [[[HTTPService alloc] initWithURLString:urlString headers:[RequestHeaders commonHeaders] body:nil delegate:self requestMethod:kRequestMethodPOST identifier:HELPDESK] autorelease];
//            } else {
//                [self.httpService setServiceURLString:urlString];
//                [self.httpService setHeadersDictionary:[[[RequestHeaders commonHeaders] mutableCopy] autorelease]];
//                [self.httpService setDelegate:self];
//                [self.httpService setServiceRequestMethod:kRequestMethodPOST];
//                [self.httpService setIdentifier:HELPDESK];
//                
//            }
//            
//            NSString *signature;
//            signature  = [DCSharedObject generateSignatureFromModel:HELPDESK requestType:POST];
//#if kDebug
//            NSLog(@"%@", signature);
//#endif
//            
//            if (signature) {
//                [[self.httpService headersDictionary] setValue:signature forKey:X_SIGNATURE];
//                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//                hud.animationType = MBProgressHUDAnimationFade;
//                hud.labelText = NSLocalizedString(@"LOADING_MESSAGE", @"");
//                [self.httpService startService];
//#if kDebug
//                NSLog(@"%@", [[self.httpService headersDictionary] description]);
//#endif
//                
//            } else {
//                //something went wrong
//                [DCSharedObject showAlertWithMessage:NSLocalizedString(@"INTERNAL_SERVER_ERROR", @"")];
//            }
            
            
            
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
#if kDebug
    NSLog(@"Parse started for identifier: %@", identifier);
#endif
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
                            NSLog(@"parsing id: %@", damageDict);
#endif

                            if ((NSNull *)[damageDict valueForKey:@"id"] != [NSNull null]) {
#if kDebug
                                NSLog(@"%@", [damageDict valueForKey:@"id"]);
#endif
                                damageDetailModel.damageId = [damageDict valueForKey:@"id"];
                            }
#if kDebug
                            NSLog(@"id parsed");
#endif

                            if ((NSNull *)[damageDict valueForKey:@"trailerid"] != [NSNull null]) {
                                if (!damageDetailModel.surveyModel) {
                                    damageDetailModel.surveyModel = [[[DCSurveyModel alloc] init] autorelease];

                                }
                                damageDetailModel.surveyModel.surveyTrailerId = [damageDict valueForKey:@"trailerid"];
                            }
#if kDebug
                            NSLog(@"trailer id parsed");
#endif

                            
                            if ((NSNull *)[damageDict valueForKey:@"damagereportlocation"] != [NSNull null]) {
                                if (!damageDetailModel.surveyModel) {
                                    damageDetailModel.surveyModel = [[[DCSurveyModel alloc] init] autorelease];

                                }
                                damageDetailModel.surveyModel.surveyPlace = [damageDict valueForKey:@"damagereportlocation"];

                            }
#if kDebug
                            NSLog(@"damage report location parsed");
#endif

                            
                            //sealed is received as a string and converted to NSNumber
                            if ((NSNull *)[damageDict valueForKey:@"sealed"] != [NSNull null]) {
                                if (!damageDetailModel.surveyModel) {
                                    damageDetailModel.surveyModel = [[[DCSurveyModel alloc] init] autorelease];

                                }
                                NSString *sealed = [damageDict valueForKey:@"sealed"];
                                damageDetailModel.surveyModel.surveyTrailerSealed = [NSNumber numberWithBool:[[sealed lowercaseString] isEqualToString:@"yes"]? YES: NO];

                            }
#if kDebug
                            NSLog(@"sealed parsed");
#endif

                            
                            if ((NSNull *)[damageDict valueForKey:@"plates"] != [NSNull null]) {
                                if (!damageDetailModel.surveyModel) {
                                    damageDetailModel.surveyModel = [[[DCSurveyModel alloc] init] autorelease];
                                }
                                damageDetailModel.surveyModel.surveyPlates = [NSNumber numberWithInt:[[damageDict valueForKey:@"plates"] intValue]];
                            }
                            
#if kDebug
                            NSLog(@"plates parsed");
#endif

                            
                            if ((NSNull *)[damageDict valueForKey:@"straps"] != [NSNull null]) {
                                if (!damageDetailModel.surveyModel) {
                                    damageDetailModel.surveyModel = [[[DCSurveyModel alloc] init] autorelease];
                                }
                                damageDetailModel.surveyModel.surveyStraps = [NSNumber numberWithInt:[[damageDict valueForKey:@"straps"] intValue]];
                            }
                            
#if kDebug
                            NSLog(@"straps parsed");
#endif

                            
                            if ((NSNull *)[damageDict valueForKey:@"damagetype"] != [NSNull null]) {
                                damageDetailModel.damageType = [damageDict valueForKey:@"damagetype"];
                            }
                            
#if kDebug
                            NSLog(@"damage type parsed");
#endif

                            
                            if ((NSNull *)[damageDict valueForKey:@"damageposition"] != [NSNull null]) {
                                damageDetailModel.damagePosition = [damageDict valueForKey:@"damageposition"];
                            }
                            
#if kDebug
                            NSLog(@"damage position parsed");
#endif

                            
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
                                //[[NSUserDefaults standardUserDefaults] setValue:[errorDict valueForKey:@"time_difference"] forKey:TIME_DIFFERENCE];
                                //timestamp is adjusted. call the same url again
                                [self getDamageList];
                            }
                        } else {
                            [DCSharedObject showAlertWithMessage:NSLocalizedString(@"INTERNAL_SERVER_ERRO", @"")];
                        }
                    }
                } else {
                    [DCSharedObject showAlertWithMessage:NSLocalizedString(@"INTERNAL_SERVER_ERROR", @"")];
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
                        }
                        [self enableActions];
                        
                        //update the damage list
                        [self getDamageList];
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
                                //[[NSUserDefaults standardUserDefaults] setValue:[errorDict valueForKey:@"time_difference"] forKey:TIME_DIFFERENCE];
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
                            [DCSharedObject showAlertWithMessage:NSLocalizedString(@"INTERNAL_SERVER_ERRO", @"")];
                        }
                    }
                } else {
                    [self toggleActionButtons];
                }
            }
        }
    }
#if kDebug
    NSLog(@"Parse Ended");
#endif

    [self.damageTableView reloadData];
}

-(void) disableActions {
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [self.editBarButtonItem setEnabled:NO];
}

-(void) enableActions {
    [self toggleActionButtons];
}

#pragma mark - HTTPServiceDelegate methods
-(void) responseCode:(int)code {
    self.httpStatusCode = code;
}

-(void) didReceiveResponse:(NSData *)data forIdentifier:(NSString *)identifier {
    [DCSharedObject hideProgressDialogInView:self.view];
    NSString *responseString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
#if kDebug
    NSLog(@"%@", responseString);
#endif

    if (self.httpStatusCode == 200 || self.httpStatusCode == 403) {
        [self parseResponse:[DCSharedObject decodeSwedishHTMLFromString:responseString] forIdentifier:identifier];
    }
}

-(void) serviceDidFailWithError:(NSError *)error forIdentifier:(NSString *)identifier {
    if ([identifier isEqualToString:HELPDESK]) {
        [DCSharedObject hideProgressDialogInView:self.view];
        if (self.submittingDamageIndex < [self.currentDamageArray count]) {
            self.submittingDamageIndex++;
            [self submitDamageReportAtIndex:self.submittingDamageIndex];
        } else if (self.submittingDamageIndex == [self.currentDamageArray count] - 1) {
            [DCSharedObject showAlertWithMessage:NSLocalizedString(@"SUBMIT_DAMAGE_ERROR", @"")];
            [self enableActions];
            
            //update the damage list
            [self getDamageList];
        }
    } else {
        if ([error code] >= kNetworkConnectionError && [error code] <= kHostUnreachableError) {
            [DCSharedObject showAlertWithMessage:NSLocalizedString(@"NETWORK_ERROR", @"")];
        } else {
            [DCSharedObject showAlertWithMessage:NSLocalizedString(@"INTERNAL_SERVER_ERROR", @"")];
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
//    if (self.currentDamageArray) {
//        if ([self.currentDamageArray count] > 0) {
//            switch (section) {
//                case 0:
//                    return 1;
//                    break;
//                case 1:
//                    return [self.currentDamageArray count];
//                    break;
//                case 2:
//                    if (self.damageListModelArray) {
//                        return [self.damageListModelArray count];
//                    }
//                default:
//                    break;
//            }
//        }
//    }
//    
//    switch (section) {
//        case 0:
//            return 1;
//            break;
//        case 1:
//            if (self.damageListModelArray) {
//                return [self.damageListModelArray count];
//            }
//        default:
//            break;
//    }
//    return 0;
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
    DCDamageDetailViewController *damageDetailViewController;
    if (self.currentDamageArray) {
        if ([self.currentDamageArray count] > 0) {
            if (indexPath.section == 0) {
                if (!self.surveyModel.surveyTrailerId) { // the user can submit the damage report only after setting the trailer id.
                    [DCSharedObject showAlertWithMessage:NSLocalizedString(@"TRAILER_ID_NULL_ERROR", @"")];
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
                if (!self.surveyModel.surveyTrailerId) { // the user can submit the damage report only after setting the trailer id.
                    [DCSharedObject showAlertWithMessage:NSLocalizedString(@"TRAILER_ID_NULL_ERROR", @"")];
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
            if (!self.surveyModel.surveyTrailerId) { // the user can submit the damage report only after setting the trailer id.
#if kDebug
                NSLog(@"%@", self.surveyModel.surveyTrailerId);
#endif
                [DCSharedObject showAlertWithMessage:NSLocalizedString(@"TRAILER_ID_NULL_ERROR", @"")];
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
    
    [self.navigationController pushViewController:damageDetailViewController animated:YES];
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
