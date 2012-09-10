//
//  DCDamageDetailViewController.m
//  DamageClaim
//
//  Created by Dev on 13/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//  This ViewController is used to submit new Damage Report

#import "DCDamageDetailViewController.h"

#import "DCDamageDetailModel.h"

#import "Const.h"

#import "DCSharedObject.h"

#import <MobileCoreServices/UTCoreTypes.h>

#import "errno.h"

#import "UIImage+Resize.h"

#import "MBProgressHUD.h"

#import "DCImageViewerViewController.h"

#import "MBProgressHUD.h"

#import "JSONKit.h"

#import "RequestHeaders.h"

#import "NSString+Base64.h"

#define NEW_DAMAGE_SECTION_ONE_ROWS 2

@interface DCDamageDetailViewController ()

@property (retain, nonatomic) IBOutlet UITableViewCell *customCellImageDamageView;
@property (retain, nonatomic) IBOutlet UITableViewCell *customCellNewImageDamageView;
@property (retain, nonatomic) IBOutlet UITableView *damageTableView;
@property (retain, nonatomic) UIImagePickerController *imagePickerController;
@property (retain, nonatomic) DCDamageDetailModel *damageDetailModel;
@property (retain, nonatomic) NSOperationQueue *opertationQueue;
@property (nonatomic, getter = isEditable) BOOL editable;
@property (nonatomic, retain) HTTPService *httpService;
@property (nonatomic) NSInteger httpStatusCode;

//The documentIds and list of images using the document Ids.
//They're not added to the model class since the images aren't stored in the persistent storage
@property (nonatomic, retain) NSMutableArray *thumbnailImagesArray;
@property (nonatomic, retain) NSMutableArray *imagesArray;
@property (nonatomic, retain) NSMutableArray *documentIdArray;

-(void) customizeNavigationBar;
-(void) addDamageDetail;
-(void) goBack;
-(void) toggleDoneButton;
-(void) getImageFromId:(NSString *) imageId;
-(void) parseResponse:(NSString *)responseString forIdentifier:(NSString *)identifier;
-(void) getDamageDetail;
-(void) getImages;
-(void) updateUI;
@end

@implementation DCDamageDetailViewController
@synthesize customCellImageDamageView = _customCellImageDamageView;
@synthesize customCellNewImageDamageView = _customCellNewImageDamageView;
@synthesize damageTableView = _damageTableView;
@synthesize imagePickerController = _imagePickerController;
@synthesize damageDetailModel = _damageDetailModel;
@synthesize editable = _editable;
@synthesize httpService = _httpService;
@synthesize httpStatusCode = _httpStatusCode;
@synthesize imagesArray = _imagesArray;
@synthesize thumbnailImagesArray = _thumbnailImagesArray;
@synthesize documentIdArray = _documentIdArray;
@synthesize opertationQueue = _opertationQueue;

#pragma mark - View LifeCycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _damageDetailModel = nil;
        _editable = NO;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil damageDetailModel:(DCDamageDetailModel *)damageDetailModelOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _damageDetailModel = damageDetailModelOrNil; [_damageDetailModel retain];
        _editable = NO;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil damageDetailModel:(DCDamageDetailModel *)damageDetailModelOrNil isEditable:(BOOL)isEditable 
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _damageDetailModel = damageDetailModelOrNil; [_damageDetailModel retain];
        _editable = isEditable;
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self customizeNavigationBar];
    [self getDamageDetail];
    
    
}

- (void)viewDidUnload
{
    [self setDamageTableView:nil];
    [self setCustomCellImageDamageView:nil];
    [self setCustomCellNewImageDamageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)dealloc {
    [_damageTableView release];
    [_customCellImageDamageView release];
    [_customCellNewImageDamageView release];
    [_imagePickerController release];
    [_damageDetailModel release];
    [_httpService release];
    [_imagesArray release];
    [_thumbnailImagesArray release];
    [_documentIdArray release];
    [_opertationQueue release];
    [super dealloc];
}

#pragma mark - Others
-(void) customizeNavigationBar {
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    if ([self isEditable]) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DONE", @"") style:UIBarButtonItemStylePlain target:self action:@selector(addDamageDetail)] autorelease];
        [self toggleDoneButton];
    }
    
    if ([self isEditable]) {
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CANCEL", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)] autorelease];
    }
    
}

//sends the damage report to the server
-(void) addDamageDetail {
    if (self.damageDetailModel) {
        [[[DCSharedObject sharedPreferences] preferences] setValue:self.damageDetailModel forKey:DAMAGE_DETAIL_MODEL];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) goBack {
//    //user cancelled damage claim procedure.
//    //delete all the locally stored images;
//    if (self.numberOfImages > 0) {
//        for (NSInteger i = 0; i < self.numberOfImages; i++) {
//            NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES);
//            if (pathArray) {
//                if ([pathArray count] > 0) {
//                    NSString *docDirURL = [pathArray objectAtIndex:0];
//                    NSString *thumbnailImageNamePath = [docDirURL stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%d.png", DAMAGE_THUMBNAIL_IMAGE_NAME, i]];
//                    NSString *imageNamePath = [docDirURL stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%d.png", DAMAGE_THUMBNAIL_IMAGE_NAME, i]];
//                    [[NSFileManager defaultManager] removeItemAtPath:imageNamePath error:nil];
//                    [[NSFileManager defaultManager] removeItemAtPath:thumbnailImageNamePath error:nil];
//                }
//            }
//        }
//    }
    if (self.opertationQueue) {
        [self.opertationQueue cancelAllOperations];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) toggleDoneButton {
    if (self.damageDetailModel.damageType && self.damageDetailModel.damagePosition) {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    } else {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
}

-(void) parseResponse:(NSString *)responseString forIdentifier:(NSString *)identifier {
    if (responseString) {
        NSDictionary *jsonDict = [responseString objectFromJSONString];
        if ([identifier isEqualToString:[NSString stringWithFormat:HELPDESK_ID, self.damageDetailModel.damageId]]) {
            if ((NSNull *)[jsonDict valueForKey:SUCCESS] != [NSNull null]) {
                if ([(NSNumber *)[jsonDict valueForKey:SUCCESS] boolValue]) {
                    if ((NSNull *)[jsonDict valueForKey:@"result"] != [NSNull null]) {
                        NSDictionary *resultDict = [jsonDict valueForKey:@"result"];
                        if ((NSNull *)[resultDict valueForKey:@"documents"] != [NSNull null]) {
                            NSArray *documentsArray = [resultDict valueForKey:@"documents"];
                            for (NSDictionary *documentDict in documentsArray) {
                                if ((NSNull *)[documentDict valueForKey:@"id"] != [NSNull null]) {
                                    if (!self.documentIdArray) {
                                        self.documentIdArray = [[[NSMutableArray alloc] init] autorelease];
                                    }
                                    
                                    [self.documentIdArray addObject:[documentDict valueForKey:@"id"]];
                                }
                            }
                            [self.damageTableView reloadData];
                            [self getImages];
                        }
                    }
                }
            }
        }
        
        if ([identifier isEqualToString:DOCUMENTATTACHMENTS_ID]) {
            if ((NSNull *)[jsonDict valueForKey:SUCCESS] != [NSNull null]) {
                if ([(NSNumber *)[jsonDict valueForKey:SUCCESS] boolValue]) {
                    if ((NSNull *)[jsonDict valueForKey:@"result"] != [NSNull null]) {
                        NSDictionary *resultDict = [jsonDict valueForKey:@"result"];
                        if ((NSNull *)[resultDict valueForKey:@"filecontent"] != [NSNull null]) {
//#if kDebug
//                            NSLog(@"Data: %@", [resultDict valueForKey:@"filecontent"]);
//#endif
                            NSData *imageData = [[resultDict valueForKey:@"filecontent"] base64DecodedData];
                            UIImage *image = [UIImage imageWithData:imageData];
                            if (!self.imagesArray) {
                                self.imagesArray = [[[NSMutableArray alloc] init] autorelease];
                            }
                            
                            if (!self.thumbnailImagesArray) {
                                self.thumbnailImagesArray = [[[NSMutableArray alloc] init] autorelease];
                            }
                            
                            [self.imagesArray addObject:image];
                            UIImage *thumbnailImage = [image thumbnailImage:THUMBNAIL_IMAGE_SIZE transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationLow];
                            [self.thumbnailImagesArray addObject:thumbnailImage];
                        }
                    }
                    
                }
            }
        }
    }
}

-(void) getDamageDetail {
    if (self.damageDetailModel.damageId) {
        [DCSharedObject makeURLCALLWithHTTPService:self.httpService extraHeaders:nil body:nil identifier:[NSString stringWithFormat:HELPDESK_ID, self.damageDetailModel.damageId] requestMethod:kRequestMethodGET model:HELPDESK delegate:self viewController:self];
    }
}


-(void) getImageFromId:(NSString *)imageId {
#if kDebug
    NSLog(@"URL: %@", [DCSharedObject createURLStringFromIdentifier:[NSString stringWithFormat:DOCUMENTATTACHMENTS_ID, imageId]]);
#endif
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[DCSharedObject createURLStringFromIdentifier:[NSString stringWithFormat:DOCUMENTATTACHMENTS_ID, imageId]]] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:TIMEOUT_INTERVAL];
    
    [request setHTTPMethod:@"GET"];
    
    for (NSString *headerKey in [RequestHeaders commonHeaders]) {
        [request setValue:[[RequestHeaders commonHeaders] objectForKey:headerKey] forHTTPHeaderField:headerKey];
    }
    
    
    NSString *signature = [DCSharedObject generateSignatureFromModel:DOCUMENTATTACHMENTS requestType:@"GET"];
    [request setValue:signature forHTTPHeaderField:X_SIGNATURE];
    if (signature) {
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (error) {
#if kDebug
            NSLog(@"%@", [error description]);
#endif
#warning Show this in the main thread
            [DCSharedObject showAlertWithMessage:NSLocalizedString(@"INTERNAL_SERVER_ERROR", @"")];
            return;
        }
        if (response) {
            if ([(NSHTTPURLResponse *)response statusCode] != 200) {
#warning Show this in the main thread
                [DCSharedObject showAlertWithMessage:NSLocalizedString(@"INTERNAL_SERVER_ERROR", @"")];
                return;
            } else {
                NSString *responseString = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
//#if kDebug
//                NSLog(@"here: %@", responseString);
//#endif
                [self parseResponse:responseString forIdentifier:DOCUMENTATTACHMENTS_ID];
                
                [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
            }
        }
    }
}

-(void) getImages {
    if (self.documentIdArray) {
        if (!self.opertationQueue) {
            self.opertationQueue = [[[NSOperationQueue alloc] init] autorelease];
        }
        [self.opertationQueue cancelAllOperations];
        
        for (NSString *imageId in self.documentIdArray) {
            NSBlockOperation *blockOperation = [[[NSBlockOperation alloc] init] autorelease];
            [blockOperation addExecutionBlock:^(void) {
                [self getImageFromId:imageId];
            }];
            [self.opertationQueue addOperation:blockOperation];
            
        }
    }
}

-(void) updateUI {
    [self.damageTableView reloadData];
}


#pragma mark - DCPickListViewControllerDelegate
-(void) pickListDidPickItem:(id)item ofType:(NSInteger)type {
    switch (type) {
        case DCPickListItemTypeDamageType:
            if (!self.damageDetailModel) {
                self.damageDetailModel = [[[DCDamageDetailModel alloc] init] autorelease];
            }
            self.damageDetailModel.damageType = item;
            //if the damage type is changed, reset the damage position since it depends on damage type
            self.damageDetailModel.damagePosition = nil;
            break;
        case DCPickListItemTypeDamagePosition:
            if (!self.damageDetailModel) {
                self.damageDetailModel = [[[DCDamageDetailModel alloc] init] autorelease];
            }
            self.damageDetailModel.damagePosition = item;
        default:
            break;
    }
    
    //damage values changed call toggle done button
    [self toggleDoneButton];
    
    [self.damageTableView reloadData];
}

-(void) pickListDidPickItems:(NSArray *)items ofType:(NSInteger)type {
    
}

#pragma mark - UITextFieldDelegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIActionSheepDelegate
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (!self.imagePickerController) {
        self.imagePickerController = [[[UIImagePickerController alloc] init] autorelease];
        self.imagePickerController.delegate = self;
    }
    
    
    switch (buttonIndex) {
        case ADD_PHOTO_CAMERA:
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                self.imagePickerController.showsCameraControls = YES;
            }
            break;
        case ADD_PHOTO_ALBUM:
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            break;
        case ADD_PHOTO_LIBRARY:
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
                self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
            break;
        case ADD_PHOTO_CANCEL:
        default:
            return;
            break;
    }
    
    
    [self presentModalViewController:self.imagePickerController animated:YES];
}

#pragma mark - UIImagePickerControllerDelegate
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
#if kDebug
        NSLog(@"%@", [image description]);
#endif
        if (image) {
            NSData *imageData = UIImagePNGRepresentation(image);
            
            UIImage *thumbnailImage = [image thumbnailImage:THUMBNAIL_IMAGE_SIZE transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationLow];
#if kDebug
            NSLog(@"Width %f, Height %f", thumbnailImage.size.width, thumbnailImage.size.height);
#endif
            NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
            //store the image in file and insert a
            //new row in UITableView
            //Also resize the image to lower resolution and save 
            //it as thumbnail. load the thumbnails instead of 
            //actual big images.
            
            NSArray *urlArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES);
            if ([urlArray count] > 0) {
                NSString *docDirPath = [urlArray objectAtIndex:0];
                NSString *imageNamePath;
                NSString *thumbnailImagePath;
                

                //retrieve the number of images already stored using NSDefaultManager
                //and name this image accordingly. number starts from 0.
                if (![[[DCSharedObject sharedPreferences] preferences] valueForKey:NUMBER_OF_IMAGES]) {
                    imageNamePath = [docDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@0.png", DAMAGE_IMAGE_NAME]];
                    thumbnailImagePath = [docDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@0.png", DAMAGE_THUMBNAIL_IMAGE_NAME]];
                } else {
                    NSInteger numberOfImages = [(NSNumber *)[[[DCSharedObject sharedPreferences] preferences] valueForKey:NUMBER_OF_IMAGES] intValue];
                    imageNamePath = [docDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%d.png", DAMAGE_IMAGE_NAME, numberOfImages]];
                    thumbnailImagePath = [docDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%d.png", DAMAGE_THUMBNAIL_IMAGE_NAME, numberOfImages]];
                }
                
                
                if ([[NSFileManager defaultManager] createFileAtPath:imageNamePath contents:imageData attributes:nil]) {
                    
                    if ([[NSFileManager defaultManager] createFileAtPath:thumbnailImagePath contents:thumbnailImageData attributes:nil]) {
                        
                        //update the number_of_images count only if images are saved properly
                        if (![[[DCSharedObject sharedPreferences] preferences] valueForKey:NUMBER_OF_IMAGES]) {
                            [[[DCSharedObject sharedPreferences] preferences] setValue:[NSNumber numberWithInt:1] forKey:NUMBER_OF_IMAGES];
                        } else {
                            NSInteger numberOfImages = [(NSNumber *)[[[DCSharedObject sharedPreferences] preferences] valueForKey:NUMBER_OF_IMAGES] intValue];
                            [[[DCSharedObject sharedPreferences] preferences] setValue:[NSNumber numberWithInt: numberOfImages + 1] forKey:NUMBER_OF_IMAGES];
                        }
                        
                        //save the image paths in the damageDetailModel object
                        if (!self.damageDetailModel) {
                            self.damageDetailModel = [[[DCDamageDetailModel alloc] init] autorelease];
                        }
                        if (!self.damageDetailModel.damageImagePaths) {
                            self.damageDetailModel.damageImagePaths = [[[NSMutableArray alloc] init] autorelease];
                            self.damageDetailModel.damageThumbnailImagePaths = [[[NSMutableArray alloc] init] autorelease];
                        }
                        
                        [self.damageDetailModel.damageImagePaths addObject:imageNamePath];
                        [self.damageDetailModel.damageThumbnailImagePaths addObject:thumbnailImagePath];
#if kDebug
                        NSLog(@"%@\n%@", self.damageDetailModel.damageImagePaths, self.damageDetailModel.damageThumbnailImagePaths);
#endif

                        
                        
                        //insert a new row in tableview
                        //always add the image as the first row after +add image button
                        NSArray *indexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:1]];
                        
                        [self.damageTableView beginUpdates];
                        [self.damageTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
                        [self.damageTableView endUpdates];
                        
                                            } else {
#if kDebug
                        NSLog(@"Some error occurred: %d, %s", errno, strerror(errno));
#endif
                    }
                    
                } else {
#if kDebug
                    NSLog(@"Some error occurred: %d, %s", errno, strerror(errno));
#endif
                }
                
                
            }
#if kDebug
            NSLog(@"%@", urlArray);
#endif
        } else {
            [DCSharedObject showAlertWithMessage:NSLocalizedString(@"ADD_PHOTO_NIL_IMAGE_MESSAGE", @"")];
        }
        
    }
    
    self.imagePickerController = nil;
    [[self modalViewController] dismissModalViewControllerAnimated:YES];
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


#pragma mark - UITableViewDelegate methods
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return NEW_DAMAGE_SECTION_ONE_ROWS;
            break;
        case 1:
            if ([self isEditable]) {
                if (self.damageDetailModel.damageThumbnailImagePaths) {
                    return [self.damageDetailModel.damageThumbnailImagePaths count] + 1;
                } else {
                    return 1;
                }
            } else {
                //the number of rows are obtained from the 
                //total number of documents available on the server
                if (self.documentIdArray) {
                    return [self.documentIdArray count];
                } else {
                    return 0;
                }
            }
            
            break;
        default:
            return 0;
            break;
    }
    
    return 0;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return NSLocalizedString(@"DAMAGE_DETAILS", @"");
            break;
        case 1:
            return NSLocalizedString(@"DAMAGE_IMAGES", @"");
            break;
        default:
            return @"";
            break;
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIView *cell;
    if (indexPath.section == 0) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"] autorelease];
    }
    
    if (indexPath.section == 1) {
        if ([self isEditable]) {
            if (self.damageDetailModel.damageThumbnailImagePaths) {
                if (indexPath.row == 0) {
                    NSArray *customCellNewImageDamageView = [[NSBundle mainBundle] loadNibNamed:@"CustomCellAddNewItemView" owner:nil options:nil];
                    if (customCellNewImageDamageView) {
                        if ([customCellNewImageDamageView count] > 0) {
                            cell = [customCellNewImageDamageView objectAtIndex:0];
                        }
                    }
                } else {
                    NSArray *customCellImageDamageDetailView = [[NSBundle mainBundle] loadNibNamed:@"CustomCellImageDamageDetailView" owner:nil options:nil];
                    if (customCellImageDamageDetailView) {
                        if ([customCellImageDamageDetailView count] > 0) {
                            cell = [customCellImageDamageDetailView objectAtIndex:0];
                        }
                    }
                }
            } else {
                NSArray *customCellAddNewItemView = [[NSBundle mainBundle] loadNibNamed:@"CustomCellAddNewItemView" owner:nil options:nil];
                if (customCellAddNewItemView) {
                    if ([customCellAddNewItemView count] > 0) {
                        cell = [customCellAddNewItemView objectAtIndex:0];
                    }
                }
            }
        } else {
            if (self.documentIdArray) {
                NSArray *customCellImageDamageDetailView = [[NSBundle mainBundle] loadNibNamed:@"CustomCellImageDamageDetailView" owner:nil options:nil];
                if (customCellImageDamageDetailView) {
                    if ([customCellImageDamageDetailView count] > 0) {
                        cell = [customCellImageDamageDetailView objectAtIndex:0];
                    }
                }
            }
        }
    }
    if (cell) {
        return cell.frame.size.height;
    }
    return 0;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SimpleCell"];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    }
        
    if (!cell) {
        if (indexPath.section == 0 && indexPath.row == 0) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SimpleCell"] autorelease];
        }
        
        if (indexPath.section == 0 && indexPath.row == 1) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SimpleCell"] autorelease];
        }
        
        if (indexPath.section == 1) {
            if ([self isEditable]) {
                if (self.damageDetailModel.damageThumbnailImagePaths) {
                    if (indexPath.row == 0) {
                        
                        NSArray *customCellNewImageDamageView = [[NSBundle mainBundle] loadNibNamed:@"CustomCellAddNewItemView" owner:nil options:nil];
                        if (customCellNewImageDamageView) {
                            if ([customCellNewImageDamageView count] > 0) {
                                cell = [customCellNewImageDamageView objectAtIndex:0];
                            }
                        }
                    } else {
                        NSArray *customCellImageDamageDetailView = [[NSBundle mainBundle] loadNibNamed:@"CustomCellImageDamageDetailView" owner:nil options:nil];
                        if (customCellImageDamageDetailView) {
                            if ([customCellImageDamageDetailView count] > 0) {
                                cell = [customCellImageDamageDetailView objectAtIndex:0];
                            }
                        }
                    }
                } else {
                    NSArray *customCellAddNewItemView = [[NSBundle mainBundle] loadNibNamed:@"CustomCellAddNewItemView" owner:nil options:nil];
                    if (customCellAddNewItemView) {
                        if ([customCellAddNewItemView count] > 0) {
                            cell = [customCellAddNewItemView objectAtIndex:0];
                        }
                    }
                }
            } else {
                NSArray *customCellImageDamageDetailView = [[NSBundle mainBundle] loadNibNamed:@"CustomCellImageDamageDetailView" owner:nil options:nil];
                if (customCellImageDamageDetailView) {
                    if ([customCellImageDamageDetailView count] > 0) {
                        cell = [customCellImageDamageDetailView objectAtIndex:0];
                    }
                }
            }
        }
    }
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        if ([self isEditable]) {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.shadowColor = [UIColor whiteColor];
        cell.textLabel.shadowOffset = CGSizeMake(1, 1);
        if (self.damageDetailModel.damageType) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"DAMAGE_TYPE", @""), self.damageDetailModel.damageType];
        } else {
            cell.textLabel.text = NSLocalizedString(@"DAMAGE_TYPE", @"");
        }
    }
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        if ([self isEditable]) {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.shadowColor = [UIColor whiteColor];
        cell.textLabel.shadowOffset = CGSizeMake(1, 1);
        if (self.damageDetailModel.damagePosition) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"DAMAGE_POSITION", @""), self.damageDetailModel.damagePosition];
        } else {
            cell.textLabel.text = NSLocalizedString(@"DAMAGE_POSITION", @"");
        }
    }
    
    if (indexPath.section == 1) {
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if ([self isEditable]) {
            if ([[[DCSharedObject sharedPreferences] preferences] valueForKey:NUMBER_OF_IMAGES]) {
                if (indexPath.row != 0) {
                    //read the contents of image file and load it in UIImageView  
                    if (self.damageDetailModel.damageThumbnailImagePaths) {
                        if (indexPath.row < [self.damageDetailModel.damageThumbnailImagePaths count] + 1) {
                            NSString *imageNamePath = [self.damageDetailModel.damageThumbnailImagePaths objectAtIndex:indexPath.row - 1];
#if kDebug
                            NSLog(@"%@", self.damageDetailModel.damageThumbnailImagePaths);
#endif
                            NSData *imageData = [[NSFileManager defaultManager] contentsAtPath:imageNamePath];
                            
                            UIImage *image = [UIImage imageWithData:imageData];
                            
                            UIImageView *imageView = (UIImageView *)[cell viewWithTag:CUSTOM_CELL_IMAGE_NEW_IMAGE_DAMAGE_TAG];
                            [imageView setImage:image];
                        }
                    }
                } else {
                    UILabel *label = (UILabel *)[cell viewWithTag:CUSTOM_CELL_LABEL_ADD_NEW_ITEM_TAG];
                    label.text = NSLocalizedString(@"ADD_NEW_IMAGE", @"");
                }
            } else {
                UILabel *label = (UILabel *)[cell viewWithTag:CUSTOM_CELL_LABEL_ADD_NEW_ITEM_TAG];
                label.text = NSLocalizedString(@"ADD_NEW_IMAGE", @"");
            }
        } else {
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:CUSTOM_CELL_IMAGE_NEW_IMAGE_DAMAGE_TAG];
            if (self.thumbnailImagesArray) {
                
                if (indexPath.row < [self.imagesArray count]) {
                    [imageView setImage:[self.imagesArray objectAtIndex:indexPath.row]];
                } else {
                    NSArray *imageArray = [NSArray arrayWithObjects:
                                           [UIImage imageNamed:@"1.tiff"],
                                           [UIImage imageNamed:@"2.tiff"], 
                                           [UIImage imageNamed:@"3.tiff"], 
                                           [UIImage imageNamed:@"4.tiff"], 
                                           [UIImage imageNamed:@"5.tiff"], 
                                           [UIImage imageNamed:@"6.tiff"], 
                                           [UIImage imageNamed:@"7.tiff"], 
                                           [UIImage imageNamed:@"8.tiff"], 
                                           [UIImage imageNamed:@"9.tiff"], 
                                           [UIImage imageNamed:@"10.tiff"], 
                                           nil];
                    
                    imageView.animationImages = imageArray;
                    imageView.animationDuration = 0.5;
                    [imageView startAnimating];
                }
            } else {
                NSArray *imageArray = [NSArray arrayWithObjects:
                                       [UIImage imageNamed:@"1.tiff"],
                                       [UIImage imageNamed:@"2.tiff"], 
                                       [UIImage imageNamed:@"3.tiff"], 
                                       [UIImage imageNamed:@"4.tiff"], 
                                       [UIImage imageNamed:@"5.tiff"], 
                                       [UIImage imageNamed:@"6.tiff"], 
                                       [UIImage imageNamed:@"7.tiff"], 
                                       [UIImage imageNamed:@"8.tiff"], 
                                       [UIImage imageNamed:@"9.tiff"], 
                                       [UIImage imageNamed:@"10.tiff"], 
                                       nil];
                
                imageView.animationImages = imageArray;
                imageView.animationDuration = 0.5;
                [imageView startAnimating];
            }
        }
    }
    
    return cell;
}
#pragma mark - UITableViewDelegate
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0 && [self isEditable]) {
        
        DCPickListViewController *pickListViewController = [[[DCPickListViewController alloc] initWithNibName:@"PickListView" bundle:nil modelArray:nil type:DCPickListItemTypeDamageType isSingleValue:YES] autorelease];
        pickListViewController.delegate = self;
        [self.navigationController pushViewController:pickListViewController animated:YES];
    }
    
    if (indexPath.section == 0 && indexPath.row == 1 && [self isEditable]) {
        if (self.damageDetailModel.damageType) {
            DCPickListViewController *pickListViewController;
            if ([[[DCSharedObject sharedPreferences] preferences] valueForKey:DAMAGE_POSITION_LABEL_DICTIONARY]) {
                NSDictionary *damagePositionLabelDictionary = [[[DCSharedObject sharedPreferences] preferences] valueForKey:DAMAGE_POSITION_LABEL_DICTIONARY];
                NSArray *damagePositionLabels = [damagePositionLabelDictionary valueForKey:self.damageDetailModel.damageType];
                if (damagePositionLabels) {
                    if ([damagePositionLabels count] > 0) {
                        pickListViewController = [[[DCPickListViewController alloc] initWithNibName:@"PickListView" bundle:nil modelArray:damagePositionLabels type:DCPickListItemTypeDamagePosition isSingleValue:YES] autorelease];
                    } else {
                        pickListViewController = [[[DCPickListViewController alloc] initWithNibName:@"PickListView" bundle:nil modelArray:nil type:DCPickListItemTypeDamagePosition isSingleValue:YES] autorelease];
                    }
                } else {
                    pickListViewController = [[[DCPickListViewController alloc] initWithNibName:@"PickListView" bundle:nil modelArray:nil type:DCPickListItemTypeDamagePosition isSingleValue:YES] autorelease];
                }
                
            } else {
                pickListViewController = [[[DCPickListViewController alloc] initWithNibName:@"PickListView" bundle:nil modelArray:nil type:DCPickListItemTypeDamagePosition isSingleValue:YES] autorelease];
            }
            
            pickListViewController.delegate = self;
            [self.navigationController pushViewController:pickListViewController animated:YES];
        } else {
            [DCSharedObject showAlertWithMessage:NSLocalizedString(@"SELECT_DAMAGE_TYPE", @"")];
        }
    }
    
    if (indexPath.section == 1) {
        if ([self isEditable]) {
            if ([[[DCSharedObject sharedPreferences] preferences] valueForKey:NUMBER_OF_IMAGES]) {
                if (indexPath.row == 0) {
                    UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"ADD_PHOTO", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"ADD_PHOTO_CAMERA", @""), NSLocalizedString(@"ADD_PHOTO_ALBUM", @""), NSLocalizedString(@"ADD_PHOTO_LIBRARY", @""), nil] autorelease];
                    [actionSheet showInView:self.view];
                } else {
                    if (self.damageDetailModel.damageImagePaths) {
                        if (indexPath.row  < [self.damageDetailModel.damageImagePaths count] + 1) {
                            
                            NSString *filePath = [self.damageDetailModel.damageImagePaths objectAtIndex:indexPath.row - 1];
                            DCImageViewerViewController *viewer = [[[DCImageViewerViewController alloc] initWithNibName:@"ImageViewerView" bundle:nil filePath:filePath] autorelease];
                            [self.navigationController pushViewController:viewer animated:YES];
                        }
                    }
                }
            } else {
                UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"ADD_PHOTO", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"ADD_PHOTO_CAMERA", @""), NSLocalizedString(@"ADD_PHOTO_ALBUM", @""), NSLocalizedString(@"ADD_PHOTO_LIBRARY", @""), nil] autorelease];
                [actionSheet showInView:self.view];
            }
        } else {
            if (self.imagesArray) {
                if (indexPath.row < [self.imagesArray count]) {
                    DCImageViewerViewController *viewer = [[[DCImageViewerViewController alloc] initWithNibName:@"ImageViewerView" bundle:nil image:[self.thumbnailImagesArray objectAtIndex:indexPath.row]] autorelease];
                    [self.navigationController pushViewController:viewer animated:YES];
                }
            }
        }
    }
}

@end
