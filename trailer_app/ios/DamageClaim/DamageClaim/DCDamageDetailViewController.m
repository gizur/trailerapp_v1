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


#define NEW_DAMAGE_SECTION_ONE_ROWS 2

@interface DCDamageDetailViewController ()

@property (retain, nonatomic) IBOutlet UITableViewCell *customCellImageDamageView;
@property (retain, nonatomic) IBOutlet UITableViewCell *customCellNewImageDamageView;
@property (retain, nonatomic) IBOutlet UITableView *damageTableView;
@property (retain, nonatomic) UIImagePickerController *imagePickerController;
@property (retain, nonatomic) DCDamageDetailModel *damageDetailModel;
@property (nonatomic) NSInteger numberOfImages;
@property (nonatomic, getter = isEditable) BOOL editable;
-(void) customizeNavigationBar;
-(void) addDamageDetail;
-(void) goBack;
@end

@implementation DCDamageDetailViewController
@synthesize customCellImageDamageView = _customCellImageDamageView;
@synthesize customCellNewImageDamageView = _customCellNewImageDamageView;
@synthesize damageTableView = _damageTableView;
@synthesize imagePickerController = _imagePickerController;
@synthesize numberOfImages = _numberOfImages;
@synthesize damageDetailModel = _damageDetailModel;
@synthesize editable = _editable;

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
    [self.damageTableView reloadData];
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
    [super dealloc];
}

#pragma mark - Others
-(void) customizeNavigationBar {
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    if ([self isEditable]) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DONE", @"") style:UIBarButtonItemStylePlain target:self action:@selector(addDamageDetail)] autorelease];
    }
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CANCEL", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)] autorelease];
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
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - DCPickListViewControllerDelegate
-(void) pickListDidPickItem:(id)item ofType:(NSInteger)type {
    switch (type) {
        case DCPickListItemTypeDamageType:
            if (!self.damageDetailModel) {
                self.damageDetailModel = [[[DCDamageDetailModel alloc] init] autorelease];
            }
            self.damageDetailModel.damageType = item;
            break;
        case DCPickListItemTypeDamagePosition:
            if (!self.damageDetailModel) {
                self.damageDetailModel = [[[DCDamageDetailModel alloc] init] autorelease];
            }
            self.damageDetailModel.damagePosition = item;
        default:
            break;
    }
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
                if (self.damageDetailModel.damageThumbnailImagePaths) {
                    return [self.damageDetailModel.damageThumbnailImagePaths count];
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
        }
    }
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        if ([self isEditable]) {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
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
            
            if ([[[DCSharedObject sharedPreferences] preferences] valueForKey:NUMBER_OF_IMAGES]) {
                if (self.damageDetailModel.damageThumbnailImagePaths) {
                    if (indexPath.row < [self.damageDetailModel.damageThumbnailImagePaths count] + 1) {
                        ;
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
            }
        }
    }
    
    return cell;
}
#pragma mark -
//TODO: Change NSSet to NSMutableArray
#pragma mark - UITableViewDelegate
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0 && [self isEditable]) {
        NSArray *array = [NSArray arrayWithObjects:@"Doors", @"Undercover", @"Lighting", @"Breaks", @"Outriggers", nil];
        DCPickListViewController *pickListViewController = [[[DCPickListViewController alloc] initWithNibName:@"PickListView" bundle:nil modelArray:array type:DCPickListItemTypeDamageType isSingleValue:YES] autorelease];
        pickListViewController.delegate = self;
        [self.navigationController pushViewController:pickListViewController animated:YES];
    }
    
    if (indexPath.section == 0 && indexPath.row == 1 && [self isEditable]) {
        NSArray *array = [NSArray arrayWithObjects:@"Left Side",@"Right Side", @"Front Side", @"Device Hood", @"Top Side", @"Bottom Side", nil];
        DCPickListViewController *pickListViewController = [[[DCPickListViewController alloc] initWithNibName:@"PickListView" bundle:nil modelArray:array type:DCPickListItemTypeDamagePosition isSingleValue:YES] autorelease];
        pickListViewController.delegate = self;
        [self.navigationController pushViewController:pickListViewController animated:YES];
    }
    
    if (indexPath.section == 1) {
        if ([[[DCSharedObject sharedPreferences] preferences] valueForKey:NUMBER_OF_IMAGES]) {
            if (indexPath.row == 0 && [self isEditable]) {
                UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"ADD_PHOTO", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"ADD_PHOTO_CAMERA", @""), NSLocalizedString(@"ADD_PHOTO_ALBUM", @""), NSLocalizedString(@"ADD_PHOTO_LIBRARY", @""), nil] autorelease];
                [actionSheet showInView:self.view];
            } else {
                if (self.damageDetailModel.damageImagePaths) {
                    if (indexPath.row  < [self.damageDetailModel.damageImagePaths count] + 1) {
                        
                        NSString *filePath = [self.damageDetailModel.damageImagePaths objectAtIndex:indexPath.row - 1];
                        DCImageViewerViewController *v = [[[DCImageViewerViewController alloc] initWithNibName:@"ImageViewerView" bundle:nil filePath:filePath] autorelease];
                        [self.navigationController pushViewController:v animated:YES];
                    }
                }
            }
        } else if ([self isEditable]){
            UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"ADD_PHOTO", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"ADD_PHOTO_CAMERA", @""), NSLocalizedString(@"ADD_PHOTO_ALBUM", @""), NSLocalizedString(@"ADD_PHOTO_LIBRARY", @""), nil] autorelease];
            [actionSheet showInView:self.view];
        }
    }
}

@end
