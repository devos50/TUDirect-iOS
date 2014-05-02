//
//  DetermineScheduleViewController.m
//  TUDirect
//
//  Created by Martijn de Vos on 02-04-13.
//  Copyright (c) 2013 Martijn de Vos. All rights reserved.
//

#import "DetermineScheduleViewController.h"
#import "IOS5ScheduleTableViewController.h"

@interface DetermineScheduleViewController () <UITabBarControllerDelegate>

@end

@implementation DetermineScheduleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    IOS5ScheduleTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"IOS5ScheduleViewController"];
    [self.navigationController pushViewController:vc animated:NO];
    
    self.tabBarController.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITabBarController delegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if(self.tabBarController.selectedIndex != 3) return YES;
    
    if(viewController == self.navigationController) return NO;
    return YES;
}

@end
