//
//  DCPickListViewController.m
//  DamageClaim
//
//  Created by Dev on 14/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  This is a generic view controller which selects a 
//list of objects and stores them as array in the DCSharedObject
//singleton class's dictionary

#import "DCPickListViewController.h"

#import "DCSharedObject.h"

#import "Const.h"

#import "MBProgressHUD.h"

#import "JSONKit.h"

#import "DCDamageDetailModel.h"

@interface DCPickListViewController ()
@property (retain, nonatomic) IBOutlet UITableViewCell *customCellPickListView;
@property (retain, nonatomic) IBOutlet UITableView *pickListTableView;
@property (retain, nonatomic) NSMutableArray *modelArray;
@property (retain, nonatomic) NSMutableArray *labelArray;
@property (retain, nonatomic) NSMutableArray *valueArray;
@property (retain, nonatomic) NSString *storageKey;
@property (retain, nonatomic) NSMutableArray *selectedObjects;
@property (nonatomic, getter = isSingleValue) BOOL singleValue;
@property (nonatomic) NSInteger type;
@property (nonatomic) NSInteger httpStatusCode;
@property (nonatomic, retain) HTTPService *httpService;

-(void) customizeNavigationBar;
-(void) storeSelectedValues;
-(void) makeURLCall;
-(void) parseResponse:(NSString *)responseString forIdentifier:(NSString *)identifier;

@end

@implementation DCPickListViewController
@synthesize customCellPickListView = _customCellPickListView;
@synthesize pickListTableView = _pickListTableView;
@synthesize modelArray = _modelArray;
@synthesize labelArray = _labelArray;
@synthesize valueArray = _valueArray;
@synthesize storageKey = _storageKey;
@synthesize selectedObjects = _selectedObjects;
@synthesize singleValue = _singleValue;
@synthesize type = _type;
@synthesize delegate = _delegate;
@synthesize httpService = _httpService;
@synthesize httpStatusCode = _httpStatusCode;

#pragma mark - ViewLifeCycle methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil modelArray:(NSArray *)modelArrayOrNil storageKey:(NSString *)key isSingleValue:(BOOL)singleValue{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _labelArray = [modelArrayOrNil mutableCopy];
        _valueArray = [modelArrayOrNil mutableCopy];
        _storageKey = key; [_storageKey retain];
        _singleValue = singleValue;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil modelArray:(NSArray *)modelArrayOrNil type:(NSInteger) type isSingleValue:(BOOL) singleValue {
    // Custom initialization
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _labelArray = [modelArrayOrNil mutableCopy];
        _valueArray = [modelArrayOrNil mutableCopy];
        _type = type;
        _singleValue = singleValue;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self customizeNavigationBar];
    [self makeURLCall];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.httpService cancelHTTPService];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [DCSharedObject hideProgressDialogInView:self.view];
    self.httpService = nil;
}


- (void)viewDidUnload
{
    [self setCustomCellPickListView:nil];
    [self setPickListTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    _delegate = nil;
    [_customCellPickListView release];
    [_pickListTableView release];
    [_modelArray release];
    [_storageKey release];
    [_selectedObjects release];
    [_httpService release];
    [_labelArray release];
    [_valueArray release];
    [super dealloc];
}


#pragma mark - Others
#pragma warning - Change the datatype of status
-(void) parseResponse:(NSString *)responseString forIdentifier:(NSString *)identifier {
    //logout irrespective of the response
    if ([identifier isEqualToString:AUTHENTICATE_LOGOUT]) {
        [DCSharedObject processLogout:self.navigationController];
        return;
    } else
    if (responseString) {
        NSDictionary *jsonDict = [responseString objectFromJSONString];
        if ((NSNull *)[jsonDict valueForKey:SUCCESS] != [NSNull null]) {
            NSNumber *status = [jsonDict valueForKey:SUCCESS];
            if ([status boolValue]) {
                
                if ([identifier isEqualToString:ASSETS]) {
                    if ((NSNull *)[jsonDict valueForKey:@"result"] != [NSNull null]) {
                        NSArray *assetsArray = [jsonDict valueForKey:@"result"];
                        for (NSDictionary *assetDict in assetsArray) {
                            if ((NSNull *)[assetDict valueForKey:@"id"] != [NSNull null]) {
                                NSString *trailerId = [assetDict valueForKey:@"id"];
                                
                                if (!self.labelArray) {
                                    self.labelArray = [[[NSMutableArray alloc] init] autorelease];
                                }
                                [self.labelArray addObject:trailerId];
                                
                                if (!self.valueArray) {
                                    self.valueArray = [[[NSMutableArray alloc] init] autorelease];
                                }
                                [self.valueArray addObject:trailerId];
                            }
                        }
                    }
                }
                
                if ([identifier isEqualToString:HELPDESK_DAMAGETYPE]) {
                    //since  damage positions are associated with a damage type, the damage type and its respective applicable 
                    //positions are stored in an NSMutableDictionary with damage type as key and applicable damage positions as an array of values.
                    //This NSMutableDictionary is then shared across the screen using the Singleton class DCSharedObject
                    if ((NSNull *)[jsonDict valueForKey:@"result"] != [NSNull null]) {
                        NSArray *damageTypeArray = [jsonDict valueForKey:@"result"];
                        for (NSDictionary *damageTypeDict in damageTypeArray) {
                            NSString *label;
                            NSString *value;
                            if ((NSNull *)[damageTypeDict valueForKey:@"label"] != [NSNull null]) {
                                label = [damageTypeDict valueForKey:@"label"];
                                if (!self.labelArray) {
                                    self.labelArray = [[[NSMutableArray alloc] init] autorelease];
                                }
                                [self.labelArray addObject:label];
                            }
                            if ((NSNull *)[damageTypeDict valueForKey:@"value"] != [NSNull null]) {
                                value = [damageTypeDict valueForKey:@"value"];
                                if (!self.valueArray) {
                                    self.valueArray = [[[NSMutableArray alloc] init] autorelease];
                                }
                                [self.valueArray addObject:value];
                            }
                            
                            NSMutableArray *damagePositionLabelArray = [[[NSMutableArray alloc] init] autorelease];
                            NSMutableArray *damagePositionValueArray = [[[NSMutableArray alloc] init] autorelease];
                            
                            if ((NSNull *)[damageTypeDict valueForKey:@"dependency"] != [NSNull null]) {
                                NSDictionary *dependencyDict = [damageTypeDict valueForKey:@"dependency"];
                                if ((NSNull *)[dependencyDict valueForKey:@"damageposition"] != [NSNull null]) {
                                    NSArray *damagePositionArray = [dependencyDict valueForKey:@"damageposition"];
                                    for (NSDictionary *damagePositionDict in damagePositionArray) {
                                        
                                        if ((NSNull *)[damagePositionDict valueForKey:@"label"] != [NSNull null]) {
                                            NSString *label = [damagePositionDict valueForKey:@"label"];
                                            [damagePositionLabelArray addObject:label];
                                        }
                                        
                                        if ((NSNull *)[damagePositionDict valueForKey:@"value"] != [NSNull null]) {
                                            NSString *label = [damagePositionDict valueForKey:@"value"];
                                            [damagePositionValueArray addObject:label];
                                        }
                                    }
                                    if (label && [damagePositionLabelArray count] > 0) {
                                        
                                        NSMutableDictionary *damagePositionLabelDictionary;
                                        NSMutableDictionary *damagePositionValueDictionary;
                                        
                                        if ([[[DCSharedObject sharedPreferences] preferences] valueForKey:DAMAGE_POSITION_LABEL_DICTIONARY]) {
                                            damagePositionLabelDictionary = [[[DCSharedObject sharedPreferences] preferences] valueForKey:DAMAGE_POSITION_LABEL_DICTIONARY];
                                            [damagePositionLabelDictionary setValue:damagePositionLabelArray forKey:label];
                                            
                                            damagePositionValueDictionary = [[[DCSharedObject sharedPreferences] preferences] valueForKey:DAMAGE_POSITION_VALUE_DICTIONARY];
                                            [damagePositionValueDictionary setValue:damagePositionValueArray forKey:value];
                                        } else {
                                            damagePositionLabelDictionary = [[[NSMutableDictionary alloc] init] autorelease];
                                            [damagePositionLabelDictionary setValue:damagePositionLabelArray forKey:label];
                                            
                                            damagePositionValueDictionary = [[[NSMutableDictionary alloc] init] autorelease];
                                            [damagePositionValueDictionary setValue:damagePositionValueArray forKey:value];
                                        }
                                        [[[DCSharedObject sharedPreferences] preferences] setValue:damagePositionLabelDictionary forKey:DAMAGE_POSITION_LABEL_DICTIONARY];
                                        [[[DCSharedObject sharedPreferences] preferences] setValue:damagePositionValueDictionary forKey:DAMAGE_POSITION_VALUE_DICTIONARY];
                                    }
                                }
                            }
                        }
#if kDebug
                NSLog(@"%@", [[[[DCSharedObject sharedPreferences] preferences] valueForKey:DAMAGE_POSITION_VALUE_DICTIONARY] description]);
#endif
                    }
                }
                
                if ([identifier isEqualToString:HELPDESK_DAMAGEPOSITION]) {
                    if ((NSNull *)[jsonDict valueForKey:@"result"] != [NSNull null]) {
                        NSArray *damageTypeArray = [jsonDict valueForKey:@"result"];
                        for (NSDictionary *damageTypeDict in damageTypeArray) {
                            if ((NSNull *)[damageTypeDict valueForKey:@"label"] != [NSNull null]) {
                                NSString *label = [damageTypeDict valueForKey:@"label"];
                                if (!self.labelArray) {
                                    self.labelArray = [[[NSMutableArray alloc] init] autorelease];
                                }
                                [self.labelArray addObject:label];
                            }
                            if ((NSNull *)[damageTypeDict valueForKey:@"value"] != [NSNull null]) {
                                NSString *value = [damageTypeDict valueForKey:@"value"];
                                if (!self.valueArray) {
                                    self.valueArray = [[[NSMutableArray alloc] init] autorelease];
                                }
                                [self.valueArray addObject:value];
                            }
                        }
                    }
                }
                
                
                [self.pickListTableView reloadData];
            } else if ((NSNull *)[jsonDict valueForKey:@"error"] != [NSNull null]) {
                NSDictionary *errorDict = [jsonDict valueForKey:@"error"];
                if ((NSNull *)[errorDict valueForKey:@"code"] != [NSNull null]) {
                    NSString *errorCode = [errorDict valueForKey:@"code"];
                    if ([errorCode isEqualToString:TIME_NOT_IN_SYNC]) {
                        if ((NSNull *)[errorDict valueForKey:@"time_difference"] != [NSNull null]) {
                            [[[DCSharedObject sharedPreferences] preferences] setValue:[errorDict valueForKey:@"time_difference"] forKey:TIME_DIFFERENCE];
                            //[[NSUserDefaults standardUserDefaults] setValue:[errorDict valueForKey:@"time_difference"] forKey:TIME_DIFFERENCE];                             //timestamp is adjusted. call the same url again
                            
                            if ([identifier isEqualToString:ASSETS]) {
                                [DCSharedObject makeURLCALLWithHTTPService:self.httpService extraHeaders:nil bodyDictionary:nil identifier:ASSETS requestMethod:kRequestMethodGET model:ASSETS delegate:self viewController:self];                            }
                            
                            if ([identifier isEqualToString:HELPDESK_DAMAGEPOSITION]) {
                                [DCSharedObject makeURLCALLWithHTTPService:self.httpService extraHeaders:nil bodyDictionary:nil identifier:HELPDESK_DAMAGEPOSITION requestMethod:kRequestMethodGET model:HELPDESK delegate:self viewController:self];
                            }
                            
                            if ([identifier isEqualToString:HELPDESK_DAMAGETYPE]) {
                                [DCSharedObject makeURLCALLWithHTTPService:self.httpService extraHeaders:nil bodyDictionary:nil identifier:HELPDESK_DAMAGETYPE requestMethod:kRequestMethodGET model:HELPDESK delegate:self viewController:self];
                            }
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
-(void) customizeNavigationBar {
//    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
//    if (self.navigationItem) {
//        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DONE", @"") style:UIBarButtonItemStylePlain target:self action:@selector(storeSelectedValues)] autorelease];
//    }
    
}

-(void) storeSelectedValues {
    if (self.selectedObjects && self.storageKey) {
        if ([self isSingleValue]) {
            if ([self.selectedObjects count] > 0) {
#if kDebug
                NSLog(@"%@", [self.selectedObjects description]);
#endif
                [[[DCSharedObject sharedPreferences] preferences] setValue:[self.selectedObjects objectAtIndex:0] forKey:self.storageKey];
            }
        } else {
#if kDebug
            NSLog(@"%@", [self.selectedObjects description]);
#endif
            [[[DCSharedObject sharedPreferences] preferences] setValue:self.selectedObjects forKey:self.storageKey];
            
        }
    }
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(pickListDidPickItems:ofType:)]) {
            [self.delegate pickListDidPickItems:self.selectedObjects ofType:self.type];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) makeURLCall {
    switch (self.type) {
        case DCPickListItemSurveyTrailerId:
            [DCSharedObject makeURLCALLWithHTTPService:self.httpService extraHeaders:nil bodyDictionary:nil identifier:ASSETS requestMethod:kRequestMethodGET model:ASSETS delegate:self viewController:self];
            break;
        case DCPickListItemTypeDamagePosition:
            //If somehow, the applicable list of damage positions could not be fetched from the server, make a URL call to fetch all the 
            //positions from the server and let the user choose the appropriate position
            if (![[[DCSharedObject sharedPreferences] preferences] valueForKey:DAMAGE_POSITION_LABEL_DICTIONARY]) {
                [DCSharedObject makeURLCALLWithHTTPService:self.httpService extraHeaders:nil bodyDictionary:nil identifier:HELPDESK_DAMAGEPOSITION requestMethod:kRequestMethodGET model:HELPDESK delegate:self viewController:self];

            }
            break;
        case DCPickListItemTypeDamageType:
            
            [DCSharedObject makeURLCALLWithHTTPService:self.httpService extraHeaders:nil bodyDictionary:nil identifier:HELPDESK_DAMAGETYPE requestMethod:kRequestMethodGET model:HELPDESK delegate:self viewController:self];
            
            break;
        default:
            break;
    }
}

#pragma mark - UIAlertViewDelegate methods
-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [super alertView:alertView didDismissWithButtonIndex:buttonIndex];
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"LOGOUT", @"")]) {
        [DCSharedObject makeURLCALLWithHTTPService:self.httpService extraHeaders:nil body:nil identifier:AUTHENTICATE_LOGOUT requestMethod:kRequestMethodGET model:AUTHENTICATE delegate:self viewController:self];
    }
}


#pragma mark - HTTPServiceDelegate methods

-(void) responseCode:(int)code {
    self.httpStatusCode = code;
}

-(void) didReceiveResponse:(NSData *)data forIdentifier:(NSString *)identifier {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSString *responseString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
#if kDebug
    NSLog(@"%@", responseString);
#endif
    

    if (self.httpStatusCode == 200 || self.httpStatusCode == 403) {
        [self parseResponse:[DCSharedObject decodeSwedishHTMLFromString:responseString] forIdentifier:identifier];
    } else if ([identifier isEqualToString:AUTHENTICATE_LOGOUT]) {
        [DCSharedObject processLogout:self.navigationController];
        
    } else {
        [self showAlertWithMessage:NSLocalizedString(@"INTERNAL_SERVER_ERROR", @"")];
    }
}

-(void) serviceDidFailWithError:(NSError *)error forIdentifier:(NSString *)identifier {
    [DCSharedObject hideProgressDialogInView:self.view];
    if ([error code] >= kNetworkConnectionError && [error code] <= kHostUnreachableError) {
        [self showAlertWithMessage:NSLocalizedString(@"NETWORK_ERROR", @"")];
    } else if ([identifier isEqualToString:AUTHENTICATE_LOGOUT]) {
        [DCSharedObject processLogout:self.navigationController];
        
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

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.labelArray) {
        return [self.labelArray count];
    }
    return 0;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        NSArray *customCellPickListView = [[NSBundle mainBundle] loadNibNamed:@"CustomCellPickListView" owner:nil options:nil];
        if (customCellPickListView) {
            if ([customCellPickListView count] > 0) {
                cell = [customCellPickListView objectAtIndex:0];
            }
        }
    }
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:CUSTOM_CELL_NAME_PICK_LIST_VIEW_TAG];
    nameLabel.text = @"";
    if (self.labelArray) {
        if (indexPath.row < [self.labelArray count]) {
            nameLabel.text = [self.labelArray objectAtIndex:indexPath.row];
        }
    }
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:CUSTOM_CELL_IMAGE_PICK_LIST_VIEW_TAG];
    if (self.selectedObjects) {
        for (NSString *itemInSelectedObjects in self.selectedObjects) {
            if (self.labelArray) {
                if (indexPath.row < [self.labelArray count]) {
                    NSString *currentItem = [self.labelArray objectAtIndex:indexPath.row];
                    if ([[currentItem lowercaseString] isEqualToString:[itemInSelectedObjects lowercaseString]]) {
#if kDebug
                        NSLog(@"%@, %@", currentItem, itemInSelectedObjects);
#endif
                        imageView.hidden = NO;
                    }
                }
            }
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate methods
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIImageView *imageView = (UIImageView *)[[tableView cellForRowAtIndexPath:indexPath] viewWithTag:CUSTOM_CELL_IMAGE_PICK_LIST_VIEW_TAG];
    
    //value array is used to return the selected item
    if ([self isSingleValue]) {
        if ([imageView isHidden]) {
            //select this row and unselect all other rows
            imageView.hidden = NO;
            
            for (NSInteger i = 0 ; i < [self.valueArray count]; i++) {
                if (i != indexPath.row) {
                    UITableViewCell *cell = [self.pickListTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                    UIImageView *otherImageView = (UIImageView *)[cell viewWithTag:CUSTOM_CELL_IMAGE_PICK_LIST_VIEW_TAG];
                    if (![otherImageView isHidden]) {
                        otherImageView.hidden = YES;
                    }
                }
                
            }
            if (!self.selectedObjects) {
                self.selectedObjects = [[[NSMutableArray alloc] init] autorelease];
            }
            if (self.valueArray) {
                if (indexPath.row < [self.valueArray count]) {
                    [self.selectedObjects removeAllObjects];
                    [self.selectedObjects addObject:[self.valueArray objectAtIndex:indexPath.row]];
                }
            }
            if (self.delegate) {
                if ([self.delegate respondsToSelector:@selector(pickListDidPickItem:ofType:)]) {
                    [self.delegate pickListDidPickItem:[self.valueArray objectAtIndex:indexPath.row] ofType:self.type];
                }
            }
        }
        [self storeSelectedValues];
    } else {
        if ([imageView isHidden]) {
            //select this row and unselect all other rows
            imageView.hidden = NO;
            
            for (NSInteger i = 0 ; i < [self.valueArray count]; i++) {
                if (i != indexPath.row) {
                    UITableViewCell *cell = [self.pickListTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                    UIImageView *otherImageView = (UIImageView *)[cell viewWithTag:CUSTOM_CELL_IMAGE_PICK_LIST_VIEW_TAG];
                    if (![otherImageView isHidden]) {
                        otherImageView.hidden = YES;
                    }
                }
            }
            if (!self.selectedObjects) {
                self.selectedObjects = [[[NSMutableArray alloc] init] autorelease];
            }
            if (self.valueArray) {
                if (indexPath.row < [self.valueArray count]) {
                    [self.selectedObjects removeAllObjects];
                    [self.selectedObjects addObject:[self.valueArray objectAtIndex:indexPath.row]];
                }
            }
            
        } else {
            imageView.hidden = YES;
            if (self.valueArray) {
                if (indexPath.row < [self.valueArray count]) {
                    [self.selectedObjects removeObject:[self.valueArray objectAtIndex:indexPath.row]];
                }
            }
        }
    }
    
}

@end
