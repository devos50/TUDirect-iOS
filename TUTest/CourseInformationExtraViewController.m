//
//  CourseInformationExtraViewController.m
//  TUTest
//
//  Created by Martijn de Vos on 08-03-13.
//  Copyright (c) 2013 Martijn de Vos. All rights reserved.
//

#import "CourseInformationExtraViewController.h"

@interface CourseInformationExtraViewController ()

@end

@implementation CourseInformationExtraViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _information[section][@"@label"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return _information.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *inhoud = _information[indexPath.section][@"inhoud"];
    
    if([inhoud isKindOfClass:[NSArray class]]) return 44.0f;
    
    CGSize labelSize = [inhoud sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(280, 10000) lineBreakMode:NSLineBreakByWordWrapping];
    return labelSize.height + 20.0f;
    
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"LargeTextCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    NSDictionary *item = _information[indexPath.section];
    if([item[@"inhoud"] isKindOfClass:[NSString class]]) cell.textLabel.text = item[@"inhoud"];
    else if([item[@"inhoud"] isKindOfClass:[NSArray class]])
    {
        NSString *str = @"";
        for(NSString *aprt in item[@"inhoud"])
        {
            str = [str stringByAppendingFormat:@"%@, ", aprt];
        }
        str = [str substringToIndex:str.length - 2];
        cell.textLabel.text = str;
    }
    
    return cell;
}

@end
