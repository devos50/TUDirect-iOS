//
//  GradesTableViewController.m
//  TUTest
//
//  Created by Martijn de Vos on 08-03-13.
//  Copyright (c) 2013 Martijn de Vos. All rights reserved.
//

#import "GradesTableViewController.h"
#import "MBProgressHUD.h"
#import "UIAlertView+error.h"
#import "AFNetworking.h"
#import "CourseInformationTableViewController.h"
#import "TUAuthClient.h"
#import "AppDelegate.h"

#define kAllGradesURL @"http://api.tudelft.nl/v0/studieresultaten"
#define kValidGradesURL @"http://api.tudelft.nl/v0/geldendstudieresultaten"
#define kTempToken @"3840d774-3b47-4df5-abd9-d3e941cc5388"

@interface GradesTableViewController ()

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedBar;

@end

@implementation GradesTableViewController
{
    NSArray *allGrades;
    NSArray *validGrades;
    NSArray *grades;
    int selectedIndex;
    BOOL showValid;
    
    int weightedDecimals;
    int unweightedDecimals;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    showValid = YES;
    weightedDecimals = 2;
    unweightedDecimals = 2;
    
    [self loadGrades];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadGrades) name:@"com.devos.TUDirect.reloadGrades" object:nil];
}

- (void)loadGrades
{
    self.navigationItem.rightBarButtonItem = nil;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tabBarController.view animated:YES];
    hud.labelText = @"Loading";
    
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"AccessToken"];
    NSString *urlstr = [kAllGradesURL stringByAppendingFormat:@"?oauth_token=%@", accessToken];
    if(showValid) urlstr = [kValidGradesURL stringByAppendingFormat:@"?oauth_token=%@", accessToken];
    
    NSURL *url = [NSURL URLWithString:urlstr];
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:url];
    NSURLRequest *request = [client requestWithMethod:@"POST" path:url.absoluteString parameters:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        if(showValid)
        {
            validGrades = JSON[@"studieresultaatLijst"][@"studieresultaat"];
            validGrades = [validGrades sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *grade1, NSDictionary *grade2)
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                NSDate *date1 = [dateFormatter dateFromString:grade1[@"mutatiedatum"]];
                NSDate *date2 = [dateFormatter dateFromString:grade2[@"mutatiedatum"]];
                return [date2 compare:date1];
            }];
            grades = validGrades;
        }
        else
        {
            allGrades = JSON[@"studieresultaatLijst"][@"studieresultaat"];
            allGrades = [allGrades sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *grade1, NSDictionary *grade2)
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                NSDate *date1 = [dateFormatter dateFromString:grade1[@"mutatiedatum"]];
                NSDate *date2 = [dateFormatter dateFromString:grade2[@"mutatiedatum"]];
                return [date2 compare:date1];
            }];
            grades = allGrades;
        }
        
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

- (void)loginPressed
{
    TUAuthClient *b = [(AppDelegate *)[[UIApplication sharedApplication] delegate] getAuthClient];
    [b authorizeOnViewController:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"CourseInformationSegue"])
    {
        CourseInformationTableViewController *vc = segue.destinationViewController;
        vc.courseId = grades[selectedIndex][@"cursusid"];
        vc.hideSearchBar = YES;
    }
}

- (double)getAverage
{
    __block double average = 0.0;
    __block int counter = 0;
    [grades enumerateObjectsUsingBlock:^(NSDictionary *gradeDict, NSUInteger idx, BOOL *stop)
    {
            // double grade = [gradeDict[@"resultaat"] doubleValue];
            NSString *gradeString = [gradeDict[@"resultaat"] stringByReplacingOccurrencesOfString:@"," withString:@"."];
            double grade = [gradeString doubleValue];
        
            if(grade == 0.0) return;
            average += grade;
            counter++;
    }];
    
    if(counter == 0) return 0.0;
    average = average / (double)counter;
    return average;
}

- (double)getWeightedAverage
{
    __block double average = 0.0;
    __block int counter = 0;
    [grades enumerateObjectsUsingBlock:^(NSDictionary *gradeDict, NSUInteger idx, BOOL *stop)
     {
         NSString *gradeString = [gradeDict[@"resultaat"] stringByReplacingOccurrencesOfString:@"," withString:@"."];
         double grade = [gradeString doubleValue];
         NSString *ectsString = [gradeDict[@"ectspunten"] stringByReplacingOccurrencesOfString:@"," withString:@"."];
         double ects = [ectsString doubleValue];
         
         if(grade == 0.0) return;
         average += grade * ects;
         counter += ects;
     }];
    
    if(counter == 0) return 0.0;
    average = average / (double)counter;
    return average;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if(showValid) return 2;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(showValid)
    {
        if(section == 0) return 2;
        return grades.count;
    }
    else
        return grades.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0) return nil;
    return @"Grades";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = (indexPath.section == 0 && showValid) ? @"AverageCell" : @"GradeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if(indexPath.section == 0 && showValid)
    {
        cell.textLabel.text = indexPath.row == 0 ? @"Weighted average" : @"Unweighted average";
        
        double avg = [self getAverage];
        double weighAvg = [self getWeightedAverage];
        
        if(indexPath.row == 0)
        {
            if(weightedDecimals == 0)
                cell.detailTextLabel.text = weighAvg != 0.0 ? [NSString stringWithFormat:@"%.0f", weighAvg] : @"-";
            else if(weightedDecimals == 1)
                cell.detailTextLabel.text = weighAvg != 0.0 ? [NSString stringWithFormat:@"%.1f", weighAvg] : @"-";
            else if(weightedDecimals == 2)
                cell.detailTextLabel.text = weighAvg != 0.0 ? [NSString stringWithFormat:@"%.2f", weighAvg] : @"-";
            else if(weightedDecimals == 3)
                cell.detailTextLabel.text = weighAvg != 0.0 ? [NSString stringWithFormat:@"%.3f", weighAvg] : @"-";
            else if(weightedDecimals == 4)
                cell.detailTextLabel.text = weighAvg != 0.0 ? [NSString stringWithFormat:@"%.4f", weighAvg] : @"-";
        }
        else
        {
            if(unweightedDecimals == 0)
                cell.detailTextLabel.text = avg != 0 ? [NSString stringWithFormat:@"%.0f", avg] : @"-";
            else if(unweightedDecimals == 1)
                cell.detailTextLabel.text = avg != 0 ? [NSString stringWithFormat:@"%.1f", avg] : @"-";
            else if(unweightedDecimals == 2)
                cell.detailTextLabel.text = avg != 0 ? [NSString stringWithFormat:@"%.2f", avg] : @"-";
            else if(unweightedDecimals == 3)
                cell.detailTextLabel.text = avg != 0 ? [NSString stringWithFormat:@"%.3f", avg] : @"-";
            else if(unweightedDecimals == 4)
                cell.detailTextLabel.text = avg != 0 ? [NSString stringWithFormat:@"%.4f", avg] : @"-";
        }
    }
    else
    {
        UILabel *nameLabel = (UILabel *) [cell viewWithTag:1];
        UILabel *mutationLabel = (UILabel *) [cell viewWithTag:2];
        UILabel *gradeLabel = (UILabel *) [cell viewWithTag:3];
        
        NSDictionary *gradeDict = grades[indexPath.row];
        
        BOOL voldoende = [gradeDict[@"voldoende"] boolValue];
        if(voldoende) gradeLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:204.0/255.0 blue:102.0/255.0 alpha:1.0];
        else gradeLabel.textColor = [UIColor redColor];
        
        // change the date to something more friendly
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *checkDate = [dateFormatter dateFromString:gradeDict[@"mutatiedatum"]];
        
        NSDateFormatter *outFormatter = [[NSDateFormatter alloc] init];
        [outFormatter setDateFormat:@"dd-MM-yyyy"];
        NSString *dateString = [outFormatter stringFromDate:checkDate];
        
        nameLabel.text = gradeDict[@"cursusid"];
        gradeLabel.text = gradeDict[@"resultaat"];
        
        if(showValid) mutationLabel.text = [NSString stringWithFormat:@"%@ (%d ects)", dateString, [gradeDict[@"ectspunten"] intValue]];
        else mutationLabel.text = [NSString stringWithFormat:@"%@", dateString];
    }
    return cell;
}

- (IBAction)barClicked:(id)sender
{
    if(_segmentedBar.selectedSegmentIndex == 0)
    {
        showValid = YES;
        grades = validGrades;
        [self.tableView reloadData];
    }
    else if(_segmentedBar.selectedSegmentIndex == 1 && !allGrades)
    {
        showValid = NO;
        [self loadGrades];
    }
    else if(_segmentedBar.selectedSegmentIndex == 1)
    {
        showValid = NO;
        grades = allGrades;
        [self.tableView reloadData];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(showValid && indexPath.section == 0 && indexPath.row == 0)
    {
        weightedDecimals = (weightedDecimals + 1) % 5;
        [self.tableView reloadData];
    }
    else if(showValid && indexPath.section == 0 && indexPath.row == 1)
    {
        unweightedDecimals = (unweightedDecimals + 1) % 5;
        [self.tableView reloadData];
    }
    
    if(indexPath.section == 1 || (!showValid && indexPath.section == 0))
    {
        selectedIndex = indexPath.row;
        [self performSegueWithIdentifier:@"CourseInformationSegue" sender:self];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
