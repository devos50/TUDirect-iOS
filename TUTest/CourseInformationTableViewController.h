//
//  CourseInformationTableViewController.h
//  TUTest
//
//  Created by Martijn de Vos on 08-03-13.
//  Copyright (c) 2013 Martijn de Vos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourseInformationTableViewController : UITableViewController

@property (nonatomic, strong) NSString *courseId;
@property (nonatomic, assign) BOOL hideSearchBar;

@end
