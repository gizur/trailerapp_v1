//
//  DCDamageListViewController.m
//  DamageClaim
//
//  Created by Dev on 18/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//  This class shows the list of 
//  all the damages filed for a particular truck

#import "DCDamageListViewController.h"

#import "DCDamageModel.h"

#import "Const.h"

#import "DCDamageViewController.h"

@interface DCDamageListViewController ()
@property (retain, nonatomic) IBOutlet UITableView *damageTableView;
@property (nonatomic, retain) NSMutableArray *modelArray;

@end

@implementation DCDamageListViewController
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
    
    {
    DCDamageModel *damageModel = [[[DCDamageModel alloc] init] autorelease];
    damageModel.damageType = @"Type: Door";
    damageModel.damagePosition = @"Position: Right Side";
    [self.modelArray addObject:damageModel];
    }
    {
    DCDamageModel *damageModel = [[[DCDamageModel alloc] init] autorelease];
    damageModel.damageType = @"Type: Lighting";
    damageModel.damagePosition = @"Position: Rear Side";
    [self.modelArray addObject:damageModel];
    }
    {
    DCDamageModel *damageModel = [[[DCDamageModel alloc] init] autorelease];
    damageModel.damageType = @"Type: Chasis";
    damageModel.damagePosition = @"Position: Right Side";
    [self.modelArray addObject:damageModel];
    }
    {
    DCDamageModel *damageModel = [[[DCDamageModel alloc] init] autorelease];
    damageModel.damageType = @"Type: Bumper";
    damageModel.damagePosition = @"Position: Front Side";
    [self.modelArray addObject:damageModel];
    }
    {
    DCDamageModel *damageModel = [[[DCDamageModel alloc] init] autorelease];
    damageModel.damageType = @"Type: Lighting";
    damageModel.damagePosition = @"Position: Front Side";
    [self.modelArray addObject:damageModel];
    }
    {
    DCDamageModel *damageModel = [[[DCDamageModel alloc] init] autorelease];
    damageModel.damageType = @"Type: Indicator";
    damageModel.damagePosition = @"Position: Left Side";
    [self.modelArray addObject:damageModel];
    }
    
#if kDebug
    for (DCDamageModel *damage in self.modelArray) {
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

#pragma mark - UITableViewDataSource methods

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.modelArray) {
        return [self.modelArray count];
    }
    return 0;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"REPORTED_DAMAGES", @"");
    }
    return @"";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SimpleCell"];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    }
    
    
    if (!cell) {
        if (indexPath.row == 0) {
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
    
    if (indexPath.row == 0) {
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:CUSTOM_CELL_LABEL_ADD_NEW_ITEM_TAG];
        titleLabel.text = NSLocalizedString(@"REPORT_NEW_DAMAGE", @"");
    } else if (indexPath.row < [self.modelArray count]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        DCDamageModel *damageModel = [self.modelArray objectAtIndex:indexPath.row];
        
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
    if (indexPath.row == 0) {
        DCDamageViewController *damageViewController = [[[DCDamageViewController alloc] initWithNibName:@"DamageView" bundle:nil] autorelease];
        [self.navigationController pushViewController:damageViewController animated:YES];
    }
}

@end
