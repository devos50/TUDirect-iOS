//
//  AppDelegate.h
//  TUTest
//
//  Created by Martijn de Vos on 06-03-13.
//  Copyright (c) 2013 Martijn de Vos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUAuthClient.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (TUAuthClient *)getAuthClient;

@end
