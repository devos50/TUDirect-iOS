//
//  RoomsInfoTableViewController.m
//  TUTest
//
//  Created by Martijn de Vos on 19-03-13.
//  Copyright (c) 2013 Martijn de Vos. All rights reserved.
//

#import "RoomInfoTableViewController.h"

@interface RoomInfoTableViewController ()

@end

@implementation RoomInfoTableViewController
{
    NSMutableArray *events;
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

    if([_roomInfo[@"evenementLijst"] isKindOfClass:[NSNull class]]) events = [[NSMutableArray alloc] init];
    else if([_roomInfo[@"evenementLijst"][@"evenement"] isKindOfClass:[NSDictionary class]]) events = [@[_roomInfo[@"evenementLijst"][@"evenement"]] mutableCopy];
    else events = _roomInfo[@"evenementLijst"][@"evenement"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) return 44.0f;
    return 68.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0) return @"Computer usage";
    return @"Events";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(section == 0) return 2;
    return events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = indexPath.section == 0 ? @"ComputersCell" : @"EventCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if(indexPath.section == 0 && indexPath.row == 0)
    {
        cell.textLabel.text = @"Computers available";
        int computersUsed = [_roomInfo[@"computerGebruik"][@"aantalInGebruik"] intValue];
        int totalComputers = [_roomInfo[@"computerGebruik"][@"aantalBeschikbaar"] intValue];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d/%d", totalComputers - computersUsed, totalComputers];
    }
    else if(indexPath.section == 0 && indexPath.row == 1)
    {
        // parse the date
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"];
        NSDate *checkDate = [dateFormatter dateFromString:[self applyTimezoneFixForDate:_roomInfo[@"computerGebruik"][@"momentopnameDatumTijd"]]];
        
        NSDateFormatter *outFormatter = [[NSDateFormatter alloc] init];
        [outFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
        NSString *dateString = [outFormatter stringFromDate:checkDate];
        
        cell.textLabel.text = @"Last check";
        cell.detailTextLabel.text = dateString;
    }
    else
    {
        UILabel *nameLabel = (UILabel *) [cell viewWithTag:1];
        UILabel *startLabel = (UILabel *) [cell viewWithTag:2];
        UILabel *endLabel = (UILabel *) [cell viewWithTag:3];
        
        // parse the date
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"];
        NSDate *startDate = [dateFormatter dateFromString:[self applyTimezoneFixForDate:events[indexPath.row][@"startDatumTijd"]]];
        NSDate *endDate = [dateFormatter dateFromString:[self applyTimezoneFixForDate:events[indexPath.row][@"eindeDatumTijd"]]];
        
        NSDateFormatter *outFormatter = [[NSDateFormatter alloc] init];
        [outFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
        NSString *startString = [outFormatter stringFromDate:startDate];
        NSString *endString = [outFormatter stringFromDate:endDate];
        startLabel.text = startString;
        endLabel.text = endString;
        nameLabel.text = events[indexPath.row][@"cursus"][@"langenaamNL"];
    }
    
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
