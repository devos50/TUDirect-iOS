//
//  BuildingsInfoTableViewController.m
//  TUTest
//
//  Created by Martijn de Vos on 08-03-13.
//  Copyright (c) 2013 Martijn de Vos. All rights reserved.
//

#import "BuildingsInfoTableViewController.h"

@interface BuildingsInfoTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *streetLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *zipCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (weak, nonatomic) IBOutlet UILabel *buildingLabel;
@property (weak, nonatomic) IBOutlet UILabel *latLabel;
@property (weak, nonatomic) IBOutlet UILabel *longLabel;

@end

@implementation BuildingsInfoTableViewController

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

- (void)fillInTable
{
    _nameLabel.text = _buildingInfo[@"naamEN"];
    
    if([[_buildingInfo[@"fysiekAdres"] allKeys] count] == 0 || [_buildingInfo[@"fysiekAdres"][@"binnenlandsAdres"] isKindOfClass:[NSNull class]])
    {
        _streetLabel.text = @"-";
        _numberLabel.text = @"-";
        _zipCodeLabel.text = @"-";
        _placeLabel.text = @"-";
        _latLabel.text = @"-";
        _longLabel.text = @"-";
    }
    else
    {
        _streetLabel.text = _buildingInfo[@"fysiekAdres"][@"binnenlandsAdres"][@"straat"];
        _numberLabel.text = _buildingInfo[@"fysiekAdres"][@"binnenlandsAdres"][@"huisnummer"];
        _zipCodeLabel.text = _buildingInfo[@"fysiekAdres"][@"binnenlandsAdres"][@"postcode"];
        _placeLabel.text = _buildingInfo[@"fysiekAdres"][@"binnenlandsAdres"][@"plaats"];
        if(!_buildingInfo[@"gpscoordinaten"][@"@lat"]) _latLabel.text = @"-";
        else _latLabel.text = _buildingInfo[@"gpscoordinaten"][@"@lat"];
        if(!_buildingInfo[@"gpscoordinaten"][@"@lon"]) _longLabel.text = @"-";
        else _longLabel.text = _buildingInfo[@"gpscoordinaten"][@"@lon"];
    }
    _buildingLabel.text = _buildingInfo[@"locatieCode"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.row == 0)
    {
        NSString *inhoud = _buildingInfo[@"naamEN"];
        
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
