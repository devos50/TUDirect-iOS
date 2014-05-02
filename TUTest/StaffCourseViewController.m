//
//  StaffCourseViewController.m
//  TUTest
//
//  Created by Martijn de Vos on 08-03-13.
//  Copyright (c) 2013 Martijn de Vos. All rights reserved.
//

#import "StaffCourseViewController.h"
#import <MessageUI/MessageUI.h>
#import "UIAlertView+error.h"

@interface StaffCourseViewController () <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@end

@implementation StaffCourseViewController
{
    UIActionSheet *emailActionSheet;
    NSString *selectedEmail;
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
    
    // prepare the staff data (filter out EN)
    NSMutableArray *objtorem = [[NSMutableArray alloc] init];
    [_staff enumerateObjectsUsingBlock:^(NSDictionary *staffMember, NSUInteger idx, BOOL *stop)
    {
        if([staffMember[@"@taal"] isEqualToString:@"NL"]) [objtorem addObject:staffMember];
    }];
    
    // remove the objects
    [objtorem enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        [_staff removeObject:obj];
    }];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _staff[section][@"@label"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return _staff.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSDictionary *staffDict = _staff[section][@"medewerker"];
    if([staffDict isKindOfClass:[NSArray class]]) return ((NSArray *)staffDict).count;
    else return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StaffCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    NSDictionary *staffDict = _staff[indexPath.section][@"medewerker"];
    if([staffDict isKindOfClass:[NSArray class]])
    {
        cell.textLabel.text = _staff[indexPath.section][@"medewerker"][indexPath.row][@"naam"];
        cell.detailTextLabel.text = _staff[indexPath.section][@"medewerker"][indexPath.row][@"email"];
    }
    else
    {
        cell.textLabel.text = _staff[indexPath.section][@"medewerker"][@"naam"];
        cell.detailTextLabel.text = _staff[indexPath.section][@"medewerker"][@"email"];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *staffDict = _staff[indexPath.section][@"medewerker"];
    if([staffDict isKindOfClass:[NSArray class]])
        selectedEmail = _staff[indexPath.section][@"medewerker"][indexPath.row][@"email"];
    else
        selectedEmail = _staff[indexPath.section][@"medewerker"][@"email"];
    
    if(selectedEmail)
    {
        emailActionSheet = [[UIActionSheet alloc] initWithTitle:selectedEmail delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Send email", nil];
        [emailActionSheet showInView:self.tabBarController.view];
    }
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet == emailActionSheet && buttonIndex == 0)
    {
        if([MFMailComposeViewController canSendMail])
        {
            MFMailComposeViewController *mailComposerViewController = [[MFMailComposeViewController alloc] init];
            mailComposerViewController.mailComposeDelegate = self;
            NSArray *toSubjects = @[selectedEmail];
            [mailComposerViewController setToRecipients:toSubjects];
            [self presentViewController:mailComposerViewController animated:YES completion:nil];
        }
    }
}

#pragma mark - mail delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
