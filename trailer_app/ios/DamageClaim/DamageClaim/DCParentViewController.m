//
//  DCParentViewController.m
//  DamageClaim
//
//  Created by Dev on 03/10/12.
//
//

#import "DCParentViewController.h"

@interface DCParentViewController ()

@end

@implementation DCParentViewController
@synthesize alertViewShown = _alertViewShown;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Others
-(void)showAlertWithMessage:(NSString *)alertMessage
{
    if (!self.alertViewShown) {
        [self setAlertViewShown:YES];
        UIAlertView *alertView;
        if ([alertMessage isEqualToString:NSLocalizedString(@"INTERNAL_SERVER_ERROR", @"")]) {
            alertView = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(alertMessage, @"") delegate:self cancelButtonTitle:NSLocalizedString(@"LOGOUT", @"") otherButtonTitles:NSLocalizedString(@"OK", @""), nil] autorelease];
        } else {
            alertView = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(alertMessage, @"") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil] autorelease];
        }
        [alertView show];
    }
}

#pragma mark - UIAlertViewDelegate methods

-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self setAlertViewShown:NO];
}


@end
