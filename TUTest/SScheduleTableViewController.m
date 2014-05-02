//
//  ScheduleTableViewController.m
//  TUTest
//
//  Created by Martijn de Vos on 08-03-13.
//  Copyright (c) 2013 Martijn de Vos. All rights reserved.
//

#import "SScheduleTableViewController.h"
#import "MBProgressHUD.h"
#import "UIAlertView+error.h"
#import "AFNetworking.h"

#define kProgressURL @"http://api.tudelft.nl/v0/vakroosters/"

@interface SScheduleTableViewController () <UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;

@end

@implementation SScheduleTableViewController
{
    NSArray *schedules;
    UITapGestureRecognizer *recognizer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _searchBar.delegate = self;
    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewPressed:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchForSchedule:(NSString *)query
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tabBarController.view animated:YES];
    hud.labelText = @"Loading";
    
    NSString *urlstr = [kProgressURL stringByAppendingString:query];
    
    NSURL *url = [NSURL URLWithString:urlstr];
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:url];
    NSURLRequest *request = [client requestWithMethod:@"POST" path:url.absoluteString parameters:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        if([JSON[@"rooster"][@"evenementLijst"] isKindOfClass:[NSNull class]])
        {
            schedules = [[NSArray alloc] init];
            [UIAlertView error:@"No results found. Please enter a valid course id."];
            [MBProgressHUD hideHUDForView:self.tabBarController.view animated:YES];
            return;
        }
        schedules = JSON[@"rooster"][@"evenementLijst"][@"evenement"];
        [MBProgressHUD hideHUDForView:self.tabBarController.view animated:YES];
        [self.tableView reloadData];
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        NSLog(@"error: %@", error);
        [UIAlertView error:@"No results found. Please enter a valid course id."];
        [MBProgressHUD hideHUDForView:self.tabBarController.view animated:YES];
    }];
    
    [operation start];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 87.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return schedules.count;
}

- (NSString *)applyTimezoneFixForDate:(NSString *)date
{
    NSRange colonRange = [date rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@":"] options:NSBackwardsSearch];
    return [date stringByReplacingCharactersInRange:colonRange withString:@""];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ScheduleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *item = schedules[indexPath.row];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
    nameLabel.text = item[@"beschrijvingNL"];
    
    // parse the date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"];
    NSDate *startDate = [dateFormatter dateFromString:[self applyTimezoneFixForDate:item[@"startDatumTijd"]]];
    NSDate *endDate = [dateFormatter dateFromString:[self applyTimezoneFixForDate:item[@"eindeDatumTijd"]]];
    
    NSDateFormatter *outFormatter = [[NSDateFormatter alloc] init];
    [outFormatter setDateFormat:@"yy-MM-dd HH:mm:ss"];
    NSString *startString = [outFormatter stringFromDate:startDate];
    NSString *endString = [outFormatter stringFromDate:endDate];
    
    UILabel *startLabel = (UILabel *)[cell viewWithTag:2];
    startLabel.text = startString;
    UILabel *endLabel = (UILabel *)[cell viewWithTag:3];
    endLabel.text = endString;
    UILabel *locationLabel = (UILabel *)[cell viewWithTag:4];
    locationLabel.text = [NSString stringWithFormat:@"%@ (%@)", item[@"ruimte"][@"naamNL"], item[@"evenementSoort"]];
    
    return cell;
}

- (void)tableViewPressed:(id)sender
{
    [_searchBar resignFirstResponder];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - search bar delegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self.tableView addGestureRecognizer:recognizer];
    
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [self.tableView removeGestureRecognizer:recognizer];
    
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchtext = searchBar.text;
    [searchBar resignFirstResponder];
    schedules = [[NSArray alloc] init];
    [self.tableView reloadData];
    [self searchForSchedule:searchtext];
}

@end
