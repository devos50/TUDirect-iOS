//
//  CourseInformationTableViewController.m
//  TUTest
//
//  Created by Martijn de Vos on 08-03-13.
//  Copyright (c) 2013 Martijn de Vos. All rights reserved.
//

#import "CourseInformationTableViewController.h"
#import "MBProgressHUD.h"
#import "UIAlertView+error.h"
#import "AFNetworking.h"
#import "StaffCourseViewController.h"
#import "CourseInformationExtraViewController.h"
#import "IOS5ScheduleTableViewController.h"

#define kCourseInformationURL @"http://api.tudelft.nl/v0/vakken/"

@interface CourseInformationTableViewController () <UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UILabel *cursusLabel;
@property (nonatomic, weak) IBOutlet UILabel *cursusCodeLabel;
@property (nonatomic, weak) IBOutlet UILabel *ectsLabel;
@property (nonatomic, weak) IBOutlet UILabel *studiejaarLabel;

@end

@implementation CourseInformationTableViewController
{
    NSDictionary *courseInformation;
    UITapGestureRecognizer *recognizer;
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
    
    [_searchBar setBackgroundImage:[UIImage new]];
    [_searchBar setTranslucent:YES];
    if(_hideSearchBar)
    {
        _searchBar.hidden = YES;
        [self.tableView setTableHeaderView:nil];
        [self getCourseInformation];
    }
    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewPressed:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"StaffSegue"])
    {
        StaffCourseViewController *vc = segue.destinationViewController;
        vc.staff = [courseInformation[@"extraUnsupportedInfo"][@"vakMedewerkers"] mutableCopy];
    }
    else if([segue.identifier isEqualToString:@"InformationSegue"])
    {
        CourseInformationExtraViewController *vc = segue.destinationViewController;
        vc.information = [courseInformation[@"extraUnsupportedInfo"][@"vakUnsupportedInfoVelden"] mutableCopy];
    }
    else if([segue.identifier isEqualToString:@"ScheduleSegue"])
    {
        IOS5ScheduleTableViewController *vc = segue.destinationViewController;
        vc.courseCode = courseInformation[@"cursusid"];
    }
}

- (void)fillInTable
{
    _cursusLabel.text = courseInformation[@"kortenaamEN"];
    _cursusCodeLabel.text = courseInformation[@"cursusid"];
    _ectsLabel.text = courseInformation[@"ects"];
    _studiejaarLabel.text = courseInformation[@"studiejaar"][@"naam"];
}

- (void)getCourseInformation
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tabBarController.view animated:YES];
    hud.labelText = @"Loading";
    
    NSString *urlstr = [kCourseInformationURL stringByAppendingString:_courseId];
    NSLog(@"url string: %@", urlstr);
    NSURL *url = [NSURL URLWithString:urlstr];
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:url];
    NSURLRequest *request = [client requestWithMethod:@"POST" path:url.absoluteString parameters:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        courseInformation = JSON[@"vak"];
        [MBProgressHUD hideHUDForView:self.tabBarController.view animated:YES];
        [self fillInTable];
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        NSLog(@"error: %@", error);
        [UIAlertView error:@"Error while fetching the course information."];
        [MBProgressHUD hideHUDForView:self.tabBarController.view animated:YES];
    }];
    
    [operation start];
}

- (void)tableViewPressed:(id)sender
{
    [_searchBar resignFirstResponder];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 2 && indexPath.row == 0) { [self performSegueWithIdentifier:@"StaffSegue" sender:self]; }
    else if(indexPath.section == 2 && indexPath.row == 1) { [self performSegueWithIdentifier:@"InformationSegue" sender:self]; }
    else if(indexPath.section == 2 && indexPath.row == 2) { [self performSegueWithIdentifier:@"ScheduleSegue" sender:self]; }
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
    _courseId = [searchBar.text uppercaseString];
    [self getCourseInformation];
    [searchBar resignFirstResponder];
}

@end
