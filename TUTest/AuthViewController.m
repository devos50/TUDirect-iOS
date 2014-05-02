//
//  AuthViewController.m
//  TUDirect
//
//  Created by Martijn de Vos on 09-04-13.
//  Copyright (c) 2013 Martijn de Vos. All rights reserved.
//

#import "AuthViewController.h"

@interface AuthViewController ()

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end

@implementation AuthViewController

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

- (void)loadURL:(NSURL *)url
{
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (UIWebView *)getWebView
{
    return _webView;
}

- (IBAction)closePressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
