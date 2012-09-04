//
//  DCImageViewerViewController.m
//  DamageClaim
//
//  Created by Dev on 03/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DCImageViewerViewController.h"

#import "Const.h"

@interface DCImageViewerViewController ()
@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) NSString *filePath;

@end

@implementation DCImageViewerViewController
@synthesize webView = _webView;
@synthesize filePath = _filePath;
#pragma mark - View LifeCycle methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil filePath:(NSString *)filePathOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _filePath = filePathOrNil;[_filePath retain];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if (self.filePath) {
#if kDebug
        NSLog(@"%@", [NSURL fileURLWithPath:self.filePath]);
#endif
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:self.filePath]]];
    }
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)dealloc {
    [_webView release];
    [_filePath release];
    [super dealloc];
}

#pragma mark - UIWebViewDelegate methods
-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

-(void) webViewDidStartLoad:(UIWebView *)webView {
    
}

-(void) webViewDidFinishLoad:(UIWebView *)webView {
    
}

-(void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}
@end
