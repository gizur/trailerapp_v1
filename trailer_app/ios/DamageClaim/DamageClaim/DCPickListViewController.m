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

@interface DCPickListViewController ()
@property (retain, nonatomic) IBOutlet UITableViewCell *customCellPickListView;
@property (retain, nonatomic) IBOutlet UITableView *pickListTableView;
@property (retain, nonatomic) NSArray *modelArray;
@property (retain, nonatomic) NSString *storageKey;
@property (retain, nonatomic) NSMutableArray *selectedObjects;
@property (nonatomic, getter = isSingleValue) BOOL singleValue;
@property (nonatomic) NSInteger type;

-(void) customizeNavigationBar;
-(void) storeSelectedValues;

@end

@implementation DCPickListViewController
@synthesize customCellPickListView = _customCellPickListView;
@synthesize pickListTableView = _pickListTableView;
@synthesize modelArray = _modelArray;
@synthesize storageKey = _storageKey;
@synthesize selectedObjects = _selectedObjects;
@synthesize singleValue = _singleValue;
@synthesize type = _type;
@synthesize delegate = _delegate;
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
        _modelArray = modelArrayOrNil; [_modelArray retain];
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
        _modelArray = modelArrayOrNil; [_modelArray retain];
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
    [super dealloc];
}


#pragma mark - Others
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


#pragma mark - UITableViewDataSource methods
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.modelArray) {
        return [self.modelArray count];
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
    if (self.modelArray) {
        if (indexPath.row < [self.modelArray count]) {
            nameLabel.text = [self.modelArray objectAtIndex:indexPath.row];
        }
    }
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:CUSTOM_CELL_IMAGE_PICK_LIST_VIEW_TAG];
    if (self.selectedObjects) {
        for (NSString *itemInSelectedObjects in self.selectedObjects) {
            if (self.modelArray) {
                if (indexPath.row < [self.modelArray count]) {
                    NSString *currentItem = [self.modelArray objectAtIndex:indexPath.row];
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
    if ([self isSingleValue]) {
        if ([imageView isHidden]) {
            //select this row and unselect all other rows
            imageView.hidden = NO;
            
            for (NSInteger i = 0 ; i < [self.modelArray count]; i++) {
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
            if (self.modelArray) {
                if (indexPath.row < [self.modelArray count]) {
                    [self.selectedObjects removeAllObjects];
                    [self.selectedObjects addObject:[self.modelArray objectAtIndex:indexPath.row]];
                }
            }
            if (self.delegate) {
                if ([self.delegate respondsToSelector:@selector(pickListDidPickItem:ofType:)]) {
                    [self.delegate pickListDidPickItem:[self.modelArray objectAtIndex:indexPath.row] ofType:self.type];
                }
            }
            
        }
        [self storeSelectedValues];
    } else {
        if ([imageView isHidden]) {
            //select this row and unselect all other rows
            imageView.hidden = NO;
            
            for (NSInteger i = 0 ; i < [self.modelArray count]; i++) {
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
            if (self.modelArray) {
                if (indexPath.row < [self.modelArray count]) {
                    [self.selectedObjects removeAllObjects];
                    [self.selectedObjects addObject:[self.modelArray objectAtIndex:indexPath.row]];
                }
            }
            
        } else {
            imageView.hidden = YES;
            if (self.modelArray) {
                if (indexPath.row < [self.modelArray count]) {
                    [self.selectedObjects removeObject:[self.modelArray objectAtIndex:indexPath.row]];
                }
            }
        }
    }
    
}

@end
