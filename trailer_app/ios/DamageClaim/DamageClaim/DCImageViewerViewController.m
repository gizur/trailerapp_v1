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
@property (retain, nonatomic) UIImage *image;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation DCImageViewerViewController
@synthesize image = _image;
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;

#pragma mark - View LifeCycle methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil image:(UIImage *)image
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _image = image;[_image retain];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if (self.image) {
        [self.imageView setImage:self.image];
        self.scrollView.maximumZoomScale = 5;
//        [self.imageView setBounds:CGRectMake(0, 0, self.image.size.width, self.image.size.height)];
//        self.scrollView.contentSize = self.image.size;
    }
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)dealloc {
    [_image release];
    [_scrollView release];
    [_imageView release];
    [super dealloc];
}


#pragma mark - UIScrollViewDelegate methods


-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}
@end
