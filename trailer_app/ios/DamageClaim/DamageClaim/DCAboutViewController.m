//
//  DCAboutViewController.m
//  DamageClaim
//
//  Created by Dev on 24/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DCAboutViewController.h"

#import "DCSharedObject.h"

#import "Const.h"

#import <QuartzCore/QuartzCore.h>

@interface DCAboutViewController ()
@property (retain, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)close:(id)sender;
@end

@implementation DCAboutViewController
@synthesize webView = _webView;
@synthesize delegate = _delegate;

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
#if kDebug
    NSLog(@"%@", [DCSharedObject createURLStringFromIdentifier:ABOUT]);
#endif
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[DCSharedObject createURLStringFromIdentifier:ABOUT]]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"text/html" forHTTPHeaderField:@"Accept"];
    [request setValue:@"sv,en-us,en;q=0.5" forHTTPHeaderField:@"Accept-Language"];
    
#if kDebug
    NSLog(@"%@", [request allHTTPHeaderFields]);
#endif
    [self.webView loadRequest:request];
    self.view.layer.cornerRadius = 10;
    self.view.layer.masksToBounds = YES;
    
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [_webView release];
    _delegate = nil;
    [super dealloc];
}

#pragma mark - Others
- (IBAction)close:(id)sender {

    if ([[self delegate] respondsToSelector:@selector(aboutViewWillClose)]) {
        [[self delegate] aboutViewWillClose];
    }
    [self viewDidDisappear:YES];
    [self viewDidUnload];
    [self.view removeFromSuperview];
}
@end
