//
//  ProgressTableViewController.m
//  TUTest
//
//  Created by Martijn de Vos on 08-03-13.
//  Copyright (c) 2013 Martijn de Vos. All rights reserved.
//

#import "ProgressTableViewController.h"
#import "MBProgressHUD.h"
#import "UIAlertView+error.h"
#import "AFNetworking.h"
#import "SpecificProgressTableViewController.h"
#import "TUAuthClient.h"
#import "AppDelegate.h"

#define kProgressURL @"http://api.tudelft.nl/v0/studievoortgang"

@interface ProgressTableViewController ()

@end

@implementation ProgressTableViewController
{
    NSArray *progress;
    int selectedIndex;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadProgress];
    
    // add observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadProgress) name:@"com.devos.TUDirect.reloadProgress" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loginPressed
{
    TUAuthClient *b = [(AppDelegate *)[[UIApplication sharedApplication] delegate] getAuthClient];
    [b authorizeOnViewController:self];
}

- (void)loadProgress
{
    self.navigationItem.rightBarButtonItem = nil;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tabBarController.view animated:YES];
    hud.labelText = @"Loading";
    
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"AccessToken"];
    NSString *urlstr = [kProgressURL stringByAppendingFormat:@"?oauth_token=%@", accessToken];
    
    NSURL *url = [NSURL URLWithString:urlstr];
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:url];
    NSURLRequest *request = [client requestWithMethod:@"POST" path:url.absoluteString parameters:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        NSLog(@"progress: %@", JSON);
        
        progress = JSON[@"studievoortgangLijst"][@"studievoortgang"];
        [MBProgressHUD hideHUDForView:self.tabBarController.view animated:YES];
        [self.tableView reloadData];
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        // show a login button to the right
        UIBarButtonItem *loginItem = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleBordered target:self action:@selector(loginPressed)];
        self.navigationItem.rightBarButtonItem = loginItem;
        
        // authorize
        TUAuthClient *b = [(AppDelegate *)[[UIApplication sharedApplication] delegate] getAuthClient];
        [b authorizeOnViewController:self];
        
        [MBProgressHUD hideHUDForView:self.tabBarController.view animated:YES];
    }];
    
    [operation start];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ProgressSegue"])
    {
        SpecificProgressTableViewController *vc = segue.destinationViewController;
        vc.progress = progress[selectedIndex];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return progress.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ProgressCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    cell.textLabel.text = progress[indexPath.row][@"examenprogramma_naam_en"];
    cell.detailTextLabel.text = progress[indexPath.row][@"examentype_omschrijving_en"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndex = indexPath.row;
    [self performSegueWithIdentifier:@"ProgressSegue" sender:self];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
