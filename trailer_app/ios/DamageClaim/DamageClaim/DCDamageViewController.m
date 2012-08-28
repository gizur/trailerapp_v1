//
//  DCDamageViewController.m
//  DamageClaim
//
//  Created by Dev on 13/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//  This ViewController is used to submit new Damage Report

#import "DCDamageViewController.h"

#import "Const.h"

#import "DCPickListViewController.h"

#import "DCSharedObject.h"

#import <MobileCoreServices/UTCoreTypes.h>

#import "errno.h"

#import "UIImage+Resize.h"

#import "MBProgressHUD.h"


#define NEW_DAMAGE_SECTION_ONE_ROWS 2

#define NEW_DAMAGE_NUMBER_OF_IMAGES @"NEW_DAMAGE_NUMBER_OF_IMAGES"

@interface DCDamageViewController ()

@property (retain, nonatomic) IBOutlet UITableViewCell *customCellImageDamageView;
@property (retain, nonatomic) IBOutlet UITableViewCell *customCellNewImageDamageView;
@property (retain, nonatomic) IBOutlet UITableView *damageTableView;
@property (retain, nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic) NSInteger numberOfImages;
-(void) customizeNavigationBar;
-(void) submitDamageReport;
-(void) goBack;
@end

@implementation DCDamageViewController
@synthesize customCellImageDamageView = _customCellImageDamageView;
@synthesize customCellNewImageDamageView = _customCellNewImageDamageView;
@synthesize damageTableView = _damageTableView;
@synthesize imagePickerController = _imagePickerController;
@synthesize numberOfImages = _numberOfImages;

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
    self.numberOfImages = 0;
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
    [super dealloc];
}

#pragma mark - Others
-(void) customizeNavigationBar {
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SUBMIT", @"") style:UIBarButtonItemStylePlain target:self action:@selector(submitDamageReport)] autorelease];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CANCEL", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)] autorelease];
}

//sends the damage report to the server
-(void) submitDamageReport {
    
}

-(void) goBack {
    //user cancelled damage claim procedure.
    //delete all the locally stored images;
    if (self.numberOfImages > 0) {
        for (NSInteger i = 0; i < self.numberOfImages; i++) {
            NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES);
            if (pathArray) {
                if ([pathArray count] > 0) {
                    NSString *docDirURL = [pathArray objectAtIndex:0];
                    NSString *thumbnailImageNamePath = [docDirURL stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%d.png", DAMAGE_THUMBNAIL_IMAGE_NAME, i]];
                    NSString *imageNamePath = [docDirURL stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%d.png", DAMAGE_THUMBNAIL_IMAGE_NAME, i]];
                    [[NSFileManager defaultManager] removeItemAtPath:imageNamePath error:nil];
                    [[NSFileManager defaultManager] removeItemAtPath:thumbnailImageNamePath error:nil];
                }
            }
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
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
            
            NSArray *urlArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES);;
            if ([urlArray count] > 0) {
                NSString *docDirPath = [urlArray objectAtIndex:0];
                NSString *imageNamePath;
                NSString *thumbnailImagePath;
                
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.labelText = NSLocalizedString(@"SAVING_MESSAGE", @"");
                hud.animationType = MBProgressHUDAnimationZoom;
                //retrieve the number of images already stored using NSDefaultManager
                //and name this image accordingly. number starts from 0.
                imageNamePath = [docDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%d.png", DAMAGE_IMAGE_NAME, self.numberOfImages]];
                thumbnailImagePath = [docDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%d.png", DAMAGE_THUMBNAIL_IMAGE_NAME, self.numberOfImages]];
                
#if kDebug
                NSLog(@"%@\n%@", imageNamePath, thumbnailImagePath);
#endif
                if (![[NSFileManager defaultManager] createFileAtPath:imageNamePath contents:imageData attributes:nil]) {
#if kDebug
                    NSLog(@"Some error occurred: %d, %s", errno, strerror(errno));
#endif
                }
                
                if (![[NSFileManager defaultManager] createFileAtPath:thumbnailImagePath contents:thumbnailImageData attributes:nil]) {
#if kDebug
                    NSLog(@"Some error occurred: %d, %s", errno, strerror(errno));
#endif
                }
                
                self.numberOfImages++;
                
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                //insert a new row in tableview
                //always add the image as the first row after +add image button
                NSArray *indexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:1]];
                
                [self.damageTableView beginUpdates];
                [self.damageTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
                [self.damageTableView endUpdates];
            }
#if kDebug
            NSLog(@"%@", urlArray);
#endif
        } else {
            [DCSharedObject showAlertWithMessage:NSLocalizedString(@"ADD_PHOTO_NIL_IMAGE_MESSAGE", @"")];
        }
        
    }
    
    
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
            if (self.numberOfImages > 0 ) {
                return self.numberOfImages + 1; //+ 1 for +add new image
            } else {
                return 1;
            }
            break;
        default:
            return 0;
            break;
    }
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
        if (self.numberOfImages > 0) {
            if (indexPath.row == 0) {
                NSArray *customCellNewImageDamageView = [[NSBundle mainBundle] loadNibNamed:@"CustomCellAddNewItemView" owner:nil options:nil];
                if (customCellNewImageDamageView) {
                    if ([customCellNewImageDamageView count] > 0) {
                        cell = [customCellNewImageDamageView objectAtIndex:0];
                    }
                }
            } else {
                NSArray *customCellImageDamageView = [[NSBundle mainBundle] loadNibNamed:@"CustomCellImageDamageView" owner:nil options:nil];
                if (customCellImageDamageView) {
                    if ([customCellImageDamageView count] > 0) {
                        cell = [customCellImageDamageView objectAtIndex:0];
                    }
                }
            }
        } else {
            NSArray *customCellImageDamageView = [[NSBundle mainBundle] loadNibNamed:@"CustomCellAddNewItemView" owner:nil options:nil];
            if (customCellImageDamageView) {
                if ([customCellImageDamageView count] > 0) {
                    cell = [customCellImageDamageView objectAtIndex:0];
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
            if (self.numberOfImages) {
                if (indexPath.row == 0) {
                    
                    NSArray *customCellNewImageDamageView = [[NSBundle mainBundle] loadNibNamed:@"CustomCellAddNewItemView" owner:nil options:nil];
                    if (customCellNewImageDamageView) {
                        if ([customCellNewImageDamageView count] > 0) {
                            cell = [customCellNewImageDamageView objectAtIndex:0];
                        }
                    }
                } else {
                    NSArray *customCellImageDamageView = [[NSBundle mainBundle] loadNibNamed:@"CustomCellImageDamageView" owner:nil options:nil];
                    if (customCellImageDamageView) {
                        if ([customCellImageDamageView count] > 0) {
                            cell = [customCellImageDamageView objectAtIndex:0];
                        }
                    }
                }
            } else {
                NSArray *customCellImageDamageView = [[NSBundle mainBundle] loadNibNamed:@"CustomCellAddNewItemView" owner:nil options:nil];
                if (customCellImageDamageView) {
                    if ([customCellImageDamageView count] > 0) {
                        cell = [customCellImageDamageView objectAtIndex:0];
                    }
                }
            }
        }
    }
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.shadowColor = [UIColor whiteColor];
        cell.textLabel.shadowOffset = CGSizeMake(1, 1);
        if ([[[DCSharedObject sharedPreferences] preferences] valueForKey:DAMAGE_TYPE_KEY]) {
            NSArray *damageArray = [[[DCSharedObject sharedPreferences] preferences] valueForKey:DAMAGE_TYPE_KEY];
            if ([damageArray count] > 0) {
                cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"DAMAGE_TYPE", @""), [damageArray objectAtIndex:0]];
            }
            
        } else {
            cell.textLabel.text = NSLocalizedString(@"DAMAGE_TYPE", @"");
        }
    }
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.shadowColor = [UIColor whiteColor];
        cell.textLabel.shadowOffset = CGSizeMake(1, 1);
        if ([[[DCSharedObject sharedPreferences] preferences] valueForKey:DAMAGE_POSITION_KEY]) {
            NSArray *damageArray = [[[DCSharedObject sharedPreferences] preferences] valueForKey:DAMAGE_POSITION_KEY];
            if ([damageArray count] > 0) {
                cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"DAMAGE_POSITION", @""), [damageArray objectAtIndex:0]];
            }
            
        } else {
            cell.textLabel.text = NSLocalizedString(@"DAMAGE_POSITION", @"");
        }
    }
    
    if (indexPath.section == 1) {
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        if (self.numberOfImages > 0) {
            if (indexPath.row != 0) {
                //read the contents of image file and load it in UIImageView
//                UITextField *captionTextField = (UITextField *)[cell viewWithTag:CUSTOM_CELL_TEXT_FIELD_NEW_IMAGE_DAMAGE_TAG];
//                captionTextField.delegate = self;
//                captionTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
//                captionTextField.clearButtonMode = UITextFieldViewModeAlways;
//                captionTextField.returnKeyType = UIReturnKeyDone;
                
                NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES);
                if (pathArray) {
                    if ([pathArray count] > 0) {
                        NSString *docDirURL = [pathArray objectAtIndex:0];
                        NSString *imageNamePath = [docDirURL stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%d.png", DAMAGE_THUMBNAIL_IMAGE_NAME, indexPath.row - 1]];
#if kDebug
                        NSLog(@"%@", imageNamePath);
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
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        NSArray *array = [NSArray arrayWithObjects:@"Doors", @"Undercover", @"Lighting", @"Breaks", @"Outriggers", nil];
        DCPickListViewController *pickListViewController = [[[DCPickListViewController alloc] initWithNibName:@"PickListView" bundle:nil modelArray:array storageKey:DAMAGE_TYPE_KEY isSingleValue:YES] autorelease];
        [self.navigationController pushViewController:pickListViewController animated:YES];
    }
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        NSArray *array = [NSArray arrayWithObjects:@"Left Side",@"Right Side", @"Front Side", @"Device Hood", @"Top Side", @"Bottom Side", nil];
        DCPickListViewController *pickListViewController = [[[DCPickListViewController alloc] initWithNibName:@"PickListView" bundle:nil modelArray:array storageKey:DAMAGE_POSITION_KEY isSingleValue:YES] autorelease];
        [self.navigationController pushViewController:pickListViewController animated:YES];
    }
    
    if (indexPath.section == 1) {
        if (self.numberOfImages > 0) {
            if (indexPath.row == 0) {
                UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"ADD_PHOTO", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"ADD_PHOTO_CAMERA", @""), NSLocalizedString(@"ADD_PHOTO_ALBUM", @""), NSLocalizedString(@"ADD_PHOTO_LIBRARY", @""), nil] autorelease];
                [actionSheet showInView:self.view];
            } else {
                //handle this case
            }
        } else {
            UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"ADD_PHOTO", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"ADD_PHOTO_CAMERA", @""), NSLocalizedString(@"ADD_PHOTO_ALBUM", @""), NSLocalizedString(@"ADD_PHOTO_LIBRARY", @""), nil] autorelease];
            [actionSheet showInView:self.view];
        }
    }
}

@end
