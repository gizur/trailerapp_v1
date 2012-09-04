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


@interface DCDamageListViewController ()
@property (retain, nonatomic) IBOutlet UITableView *damageTableView;
@property (retain, nonatomic) NSMutableArray *currentDamageArray;
@property (nonatomic, retain) NSMutableArray *damageListModelArray;

-(void) customizeNavigationBar;
-(void) logout;
-(void) submitDamageReport;
-(NSInteger) checkDuplicateModel:(DCDamageDetailModel *) model;
-(void) tranferImagesFromOldModel:(DCDamageDetailModel *)oldModel toNewModel:(DCDamageDetailModel *)newModel;

@end

@implementation DCDamageListViewController
@synthesize damageTableView = _damageTableView;
@synthesize damageListModelArray = _damageListModelArray;
@synthesize currentDamageArray = _currentDamageArray;

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
    //fill array with dummy values
    self.damageListModelArray = [[[NSMutableArray alloc] init] autorelease];
    
    [self customizeNavigationBar];
    
    {
        DCDamageDetailModel *damageModel = [[[DCDamageDetailModel alloc] init] autorelease];
        damageModel.damageType = @"Doors";
        damageModel.damagePosition = @"Left Side";
        [self.damageListModelArray addObject:damageModel];
    }
    {
        DCDamageDetailModel *damageModel = [[[DCDamageDetailModel alloc] init] autorelease];
        damageModel.damageType = @"Outriggers";
        damageModel.damagePosition = @"Top Side";
        [self.damageListModelArray addObject:damageModel];
    }
    {
        DCDamageDetailModel *damageModel = [[[DCDamageDetailModel alloc] init] autorelease];
        damageModel.damageType = @"Undercover";
        damageModel.damagePosition = @"Right Side";
        [self.damageListModelArray addObject:damageModel];
    }
    {
        DCDamageDetailModel *damageModel = [[[DCDamageDetailModel alloc] init] autorelease];
        damageModel.damageType = @"Lighting";
        damageModel.damagePosition = @"Front Side";
        [self.damageListModelArray addObject:damageModel];
    }
    {
        DCDamageDetailModel *damageModel = [[[DCDamageDetailModel alloc] init] autorelease];
        damageModel.damageType = @"Breaks";
        damageModel.damagePosition = @"Device Hood";
        [self.damageListModelArray addObject:damageModel];
    }
    {
        DCDamageDetailModel *damageModel = [[[DCDamageDetailModel alloc] init] autorelease];
        damageModel.damageType = @"Doors";
        damageModel.damagePosition = @"Right Side";
        [self.damageListModelArray addObject:damageModel];
    }
    
#if kDebug
    for (DCDamageDetailModel *damage in self.damageListModelArray) {
        NSLog(@"%@", damage.damageType);
    }
    
#endif
    
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
        
    }
}


- (void)viewDidUnload
{
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
    [super dealloc];

}

#pragma mark - Others
-(void) customizeNavigationBar {
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SUBMIT", @"") style:UIBarButtonItemStylePlain target:self action:@selector(submitDamageReport)] autorelease];
    //[self.navigationItem.rightBarButtonItem setEnabled:NO];
}

-(void) logout {
    
}


//sends the damage report to the server
-(void) submitDamageReport {
    
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


#pragma mark - UITableViewDataSource methods

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.currentDamageArray) {
        if ([self.currentDamageArray count] > 0) {
            return 3;
        }
    }
    return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.currentDamageArray) {
        if ([self.currentDamageArray count] > 0) {
            switch (section) {
                case 0:
                    return 1;
                    break;
                case 1:
                    return [self.currentDamageArray count];
                    break;
                case 2:
                    if (self.damageListModelArray) {
                        return [self.damageListModelArray count];
                    }
                default:
                    break;
            }
        }
    }
    
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            if (self.damageListModelArray) {
                return [self.damageListModelArray count];
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
    return cell;
}

#pragma mark - UITableViewDelegate methods
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DCDamageDetailViewController *damageDetailViewController;
    if (self.currentDamageArray) {
        if ([self.currentDamageArray count] > 0) {
            if (indexPath.section == 0) {
                damageDetailViewController = [[[DCDamageDetailViewController alloc] initWithNibName:@"DamageDetailView" bundle:nil damageDetailModel:nil isEditable:YES] autorelease];
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
                damageDetailViewController = [[[DCDamageDetailViewController alloc] initWithNibName:@"DamageDetailView" bundle:nil damageDetailModel:nil isEditable:YES] autorelease];
                
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
            damageDetailViewController = [[[DCDamageDetailViewController alloc] initWithNibName:@"DamageDetailView" bundle:nil damageDetailModel:nil isEditable:YES] autorelease];
            
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



@end
