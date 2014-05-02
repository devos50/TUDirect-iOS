//
//  WorkplacesInfoTableViewController.m
//  TUTest
//
//  Created by Martijn de Vos on 08-03-13.
//  Copyright (c) 2013 Martijn de Vos. All rights reserved.
//

#import "WorkplacesInfoTableViewController.h"
#import "RoomsTableViewController.h"

@interface WorkplacesInfoTableViewController ()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *streetLabel;
@property (nonatomic, weak) IBOutlet UILabel *numberLabel;
@property (nonatomic, weak) IBOutlet UILabel *zipCodeLabel;
@property (nonatomic, weak) IBOutlet UILabel *placeLabel;
@property (nonatomic, weak) IBOutlet UILabel *latLabel;
@property (nonatomic, weak) IBOutlet UILabel *longLabel;


@end

@implementation WorkplacesInfoTableViewController

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
    
    [self fillInTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"RoomsSegue"])
    {
        RoomsTableViewController *vc = segue.destinationViewController;
        vc.locationCode = _workplaceInfo[@"locatieCode"];
    }
}

- (void)fillInTable
{
    _nameLabel.text = _workplaceInfo[@"naamEN"];
    _streetLabel.text = _workplaceInfo[@"fysiekAdres"][@"binnenlandsAdres"][@"straat"];
    _numberLabel.text = _workplaceInfo[@"fysiekAdres"][@"binnenlandsAdres"][@"huisnummer"];
    _zipCodeLabel.text = _workplaceInfo[@"fysiekAdres"][@"binnenlandsAdres"][@"postcode"];
    _placeLabel.text = _workplaceInfo[@"fysiekAdres"][@"binnenlandsAdres"][@"plaats"];
    if(!_workplaceInfo[@"gpscoordinaten"][@"@lat"]) _latLabel.text = @"-";
    else _latLabel.text = _workplaceInfo[@"gpscoordinaten"][@"@lat"];
    if(!_workplaceInfo[@"gpscoordinaten"][@"@lon"]) _longLabel.text = @"-";
    else _longLabel.text = _workplaceInfo[@"gpscoordinaten"][@"@lon"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.row == 0)
    {
        NSString *inhoud = _workplaceInfo[@"naamEN"];
        
        CGSize labelSize = [inhoud sizeWithFont:[UIFont systemFontOfSize:17.0f] constrainedToSize:CGSizeMake(280, 10000) lineBreakMode:NSLineBreakByWordWrapping];
        
        return labelSize.height + 30.0f > 44.0f ? labelSize.height + 23.0f : 44.0f;
    }
    return 44.0f;
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

@end
