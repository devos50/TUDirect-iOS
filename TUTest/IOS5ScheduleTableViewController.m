//
//  IOS5ScheduleTableViewController.m
//  TUDirect
//
//  Created by Martijn de Vos on 02-04-13.
//  Copyright (c) 2013 Martijn de Vos. All rights reserved.
//

#import "IOS5ScheduleTableViewController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "UIAlertView+error.h"

#define kScheduleURL @"http://api.tudelft.nl/v0/vakroosters/"

@interface IOS5ScheduleTableViewController ()

@end

@implementation IOS5ScheduleTableViewController
{
    UIAlertView *searchAlert;
    NSArray *schedules;
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
    
	// Do any additional setup after loading the view.
    self.navigationItem.hidesBackButton = YES;
    
    searchAlert = [[UIAlertView alloc] initWithTitle:@"Search a course" message:@"Please enter a course code (i.e. TI2200):" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Search", nil];
    searchAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[searchAlert textFieldAtIndex:0] setPlaceholder:@"Course code"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)searchPressed:(id)sender
{
    [searchAlert show];
}

- (NSString *)applyTimezoneFixForDate:(NSString *)date
{
    NSRange colonRange = [date rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@":"] options:NSBackwardsSearch];
    return [date stringByReplacingCharactersInRange:colonRange withString:@""];
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
    return schedules.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ScheduleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    NSDictionary *scheduleDict = schedules[indexPath.row];
    cell.textLabel.text = scheduleDict[@"beschrijvingNL"];
    
    // parse the date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"];
    NSDate *startDate = [dateFormatter dateFromString:[self applyTimezoneFixForDate:scheduleDict[@"startDatumTijd"]]];
    NSDate *endDate = [dateFormatter dateFromString:[self applyTimezoneFixForDate:scheduleDict[@"eindeDatumTijd"]]];
    
    NSDateFormatter *outFormatter = [[NSDateFormatter alloc] init];
    [outFormatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    NSString *startString = [outFormatter stringFromDate:startDate];
    NSString *endString = [outFormatter stringFromDate:endDate];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", startString, endString];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)searchForSchedule:(NSString *)query
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tabBarController.view animated:YES];
    hud.labelText = @"Loading";
    
    NSString *urlstr = [kScheduleURL stringByAppendingString:query];
    
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

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView == searchAlert && buttonIndex == 1)
    {
        NSString *text = [[searchAlert textFieldAtIndex:0] text];
        [self searchForSchedule:text];
    }
}

@end