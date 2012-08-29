//
//  DCDamageViewController.m
//  DamageClaim
//
//  Created by Dev on 18/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//  This class shows the list of 
//  all the damages filed for a particular truck

#import "DCDamageViewController.h"

#import "DCDamageDetailModel.h"

#import "Const.h"

#import "DCDamageDetailViewController.h"

@interface DCDamageViewController ()
@property (retain, nonatomic) IBOutlet UITableView *damageTableView;
@property (nonatomic, retain) NSMutableArray *modelArray;

-(void) customizeNavigationBar;
-(void) logout;
-(void) submitDamageReport;
@end

@implementation DCDamageViewController
@synthesize damageTableView = _damageTableView;
@synthesize modelArray = _modelArray;


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
    self.modelArray = [[[NSMutableArray alloc] init] autorelease];
    
    [self customizeNavigationBar];
    
    {
    DCDamageDetailModel *damageModel = [[[DCDamageDetailModel alloc] init] autorelease];
    damageModel.damageType = @"Type: Door";
    damageModel.damagePosition = @"Position: Right Side";
    [self.modelArray addObject:damageModel];
    }
    {
    DCDamageDetailModel *damageModel = [[[DCDamageDetailModel alloc] init] autorelease];
    damageModel.damageType = @"Type: Lighting";
    damageModel.damagePosition = @"Position: Rear Side";
    [self.modelArray addObject:damageModel];
    }
    {
    DCDamageDetailModel *damageModel = [[[DCDamageDetailModel alloc] init] autorelease];
    damageModel.damageType = @"Type: Chasis";
    damageModel.damagePosition = @"Position: Right Side";
    [self.modelArray addObject:damageModel];
    }
    {
    DCDamageDetailModel *damageModel = [[[DCDamageDetailModel alloc] init] autorelease];
    damageModel.damageType = @"Type: Bumper";
    damageModel.damagePosition = @"Position: Front Side";
    [self.modelArray addObject:damageModel];
    }
    {
    DCDamageDetailModel *damageModel = [[[DCDamageDetailModel alloc] init] autorelease];
    damageModel.damageType = @"Type: Lighting";
    damageModel.damagePosition = @"Position: Front Side";
    [self.modelArray addObject:damageModel];
    }
    {
    DCDamageDetailModel *damageModel = [[[DCDamageDetailModel alloc] init] autorelease];
    damageModel.damageType = @"Type: Indicator";
    damageModel.damagePosition = @"Position: Left Side";
    [self.modelArray addObject:damageModel];
    }
    
#if kDebug
    for (DCDamageDetailModel *damage in self.modelArray) {
        NSLog(@"%@", damage.damageType);
    }
    
#endif
    
    [self.damageTableView reloadData];
}

- (void)viewDidUnload
{
    [self setDamageTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [_damageTableView release];
    [_modelArray release];
    [super dealloc];
}

#pragma mark - Others
-(void) logout {
    
}

-(void) customizeNavigationBar {
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SUBMIT", @"") style:UIBarButtonItemStylePlain target:self action:@selector(submitDamageReport)] autorelease];
    //self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CANCEL", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)] autorelease];
    
//    if (self.navigationItem) {
//        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"LOGOUT", @"") style:UIBarButtonItemStylePlain target:self action:@selector(logout)] autorelease];
//    }
}

//sends the damage report to the server
-(void) submitDamageReport {
    
}



#pragma mark - UITableViewDataSource methods

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            if (self.modelArray) {
                return [self.modelArray count];
            }
        default:
            break;
    }
    
    return 0;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return NSLocalizedString(@"DAMAGE_DETAILS", @"");
    }
    return @"";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
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
        titleLabel.text = NSLocalizedString(@"ADD_NEW_DAMAGE_DETAIL", @"");
    } else if (indexPath.row < [self.modelArray count]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        DCDamageDetailModel *damageModel = [self.modelArray objectAtIndex:indexPath.row];
        
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
    if (indexPath.section == 0) {
        DCDamageDetailViewController *damageDetailViewController = [[[DCDamageDetailViewController alloc] initWithNibName:@"DamageDetailView" bundle:nil] autorelease];
        [self.navigationController pushViewController:damageDetailViewController animated:YES];
    }
}

@end
