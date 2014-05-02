//
//  ProgressTableViewController.m
//  TUTest
//
//  Created by Martijn de Vos on 08-03-13.
//  Copyright (c) 2013 Martijn de Vos. All rights reserved.
//

#import "SpecificProgressTableViewController.h"

@interface SpecificProgressTableViewController ()

@property (nonatomic, weak) IBOutlet UILabel *opleidingLabel;
@property (nonatomic, weak) IBOutlet UILabel *examenTypeLabel;
@property (nonatomic, weak) IBOutlet UILabel *specialisatieLabel;
@property (nonatomic, weak) IBOutlet UILabel *examenProgrammaLabel;
@property (nonatomic, weak) IBOutlet UILabel *minPointsLabel;
@property (nonatomic, weak) IBOutlet UILabel *gotPointsLabel;
@property (nonatomic, weak) IBOutlet UILabel *voldaanLabel;

@end

@implementation SpecificProgressTableViewController

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
    
    [self fillInData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fillInData
{
    _opleidingLabel.text = _progress[@"opleiding_naam_en"];
    _examenTypeLabel.text = _progress[@"examentype_omschrijving_en"];
    _specialisatieLabel.text = _progress[@"specialisatie_naam_en"];
    if([_progress[@"specialisatie_naam_en"] isEqualToString:@""] || !_progress[@"specialisatie_naam_en"]) _specialisatieLabel.text = @"-";
    _examenProgrammaLabel.text = _progress[@"examenprogramma_naam_en"];
    _minPointsLabel.text = _progress[@"minimum_punten_examenprogramma"];
    _gotPointsLabel.text = _progress[@"behaalde_punten_basisprogramma"];
    _voldaanLabel.text = [_progress[@"voldaan"] isEqualToString:@"J"] ? @"Yes" : @"No";
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
