//
//  BuildingsTableViewController.m
//  TUTest
//
//  Created by Martijn de Vos on 06-03-13.
//  Copyright (c) 2013 Martijn de Vos. All rights reserved.
//

#import "BuildingsTableViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "UIAlertView+error.h"
#import "BuildingsInfoTableViewController.h"
#import "BuildingsMapViewController.h"
#import "WorkplacesInfoTableViewController.h"

#define kBuildingsURL @"http://api.tudelft.nl/v0/gebouwen"
#define kWorkspacesURL @"http://api.tudelft.nl/v0/gebouwen?computerlokaal=true"

@interface BuildingsTableViewController ()

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedBar;

@end

@implementation BuildingsTableViewController
{
    NSMutableArray *buildings;
    NSMutableArray *workspaces;
    NSMutableArray *currentData;
    int selectedIndex;
    BOOL showBuildings;
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
        
    showBuildings = YES;
    [self loadBuildings];
}

- (void)loadBuildings
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tabBarController.view animated:YES];
    hud.labelText = @"Loading";
    
    NSURL *url = [NSURL URLWithString:kBuildingsURL];
    if(!showBuildings) { url = [NSURL URLWithString:kWorkspacesURL]; }
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:url];
    NSURLRequest *request = [client requestWithMethod:@"POST" path:url.absoluteString parameters:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        if(showBuildings)
        {
            buildings = [[NSMutableArray alloc] init];
            NSArray *arr = [JSON[@"findAllLocatiesResponse"][@"locatieLijst"][@"locatie"] mutableCopy];
            [arr enumerateObjectsUsingBlock:^(NSDictionary *building, NSUInteger idx, BOOL *stop)
            {
                NSMutableDictionary *newBuilding = [building mutableCopy];
                
                if([building isKindOfClass:[NSDictionary class]]) [buildings addObject:newBuilding];
                
                if([building[@"naamEN"] length] == 0 && [building[@"naamNL"] length] == 0)
                {
                    newBuilding[@"naamEN"] = [NSString stringWithFormat:@"Building %@", building[@"locatieCode"]];
                }
            }];
            
            // order alphabetically
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"naamEN" ascending:YES];
            buildings = [[buildings sortedArrayUsingDescriptors:@[sort]] mutableCopy];
            
            NSLog(@"buildings: %@", buildings);
            currentData = buildings;
        }
        else
        {
            workspaces = [[NSMutableArray alloc] init];
            NSArray *arr = [JSON[@"getLocatiesMetComputerRuimtesResponse"][@"locatieLijst"][@"locatie"] mutableCopy];
            NSLog(@"arr: %@", arr);
            [arr enumerateObjectsUsingBlock:^(NSDictionary *workspace, NSUInteger idx, BOOL *stop)
             {
                 if([workspace isKindOfClass:[NSDictionary class]]) [workspaces addObject:workspace];
             }];
            currentData = workspaces;
        }
        
        [MBProgressHUD hideHUDForView:self.tabBarController.view animated:YES];
        [self.tableView reloadData];
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        [UIAlertView error:@"Error while loading the buildings."];
        [MBProgressHUD hideHUDForView:self.tabBarController.view animated:YES];
    }];
    
    [operation start];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"BuildingInfo"])
    {
        BuildingsInfoTableViewController *vc = segue.destinationViewController;
        vc.buildingInfo = currentData[selectedIndex];
    }
    if([segue.identifier isEqualToString:@"WorkplaceInfo"])
    {
        WorkplacesInfoTableViewController *vc = segue.destinationViewController;
        vc.workplaceInfo = currentData[selectedIndex];
    }
    else if([segue.identifier isEqualToString:@"MapSegue"])
    {
        UINavigationController *nvc = segue.destinationViewController;
        BuildingsMapViewController *vc = (BuildingsMapViewController *) [nvc viewControllers][0];
        vc.buildings = currentData;
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
    return currentData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BuildingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    cell.textLabel.text = currentData[indexPath.row][@"naamEN"];
    
    return cell;
}

- (IBAction)barClicked:(id)sender
{
    if(_segmentedBar.selectedSegmentIndex == 0)
    {
        showBuildings = YES;
        currentData = buildings;
        [self.tableView reloadData];
    }
    else if(_segmentedBar.selectedSegmentIndex == 1 && !workspaces)
    {
        showBuildings = NO;
        [self loadBuildings];
    }
    else if(_segmentedBar.selectedSegmentIndex == 1)
    {
        showBuildings = NO;
        currentData = workspaces;
        [self.tableView reloadData];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndex = indexPath.row;
    if(showBuildings) { [self performSegueWithIdentifier:@"BuildingInfo" sender:self]; }
    else { [self performSegueWithIdentifier:@"WorkplaceInfo" sender:self]; }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
