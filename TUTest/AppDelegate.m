//
//  AppDelegate.m
//  TUTest
//
//  Created by Martijn de Vos on 06-03-13.
//  Copyright (c) 2013 Martijn de Vos. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworking.h"

#define kValidGradesURL @"http://api.tudelft.nl/v0/geldendstudieresultaten"

@implementation AppDelegate
{
    TUAuthClient *b;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    b = [[TUAuthClient alloc] initWithClientID:@"tudirect" clientSecret:@"36481f4d-0188-42e9-95a4-b99b3ff35ce9" redirectURI:@"http://ios-dev.no-ip.org/tuiosapp"];
    
    return YES;
}

- (void)checkToken
{
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"AccessToken"];
    NSString *urlstr = [kValidGradesURL stringByAppendingFormat:@"?oauth_token=%@", accessToken];
    
    NSURL *url = [NSURL URLWithString:urlstr];
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:url];
    NSURLRequest *request = [client requestWithMethod:@"GET" path:url.absoluteString parameters:nil];
    NSLog(@"access token: %@", accessToken);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        if(JSON[@"error"]) [b authorize];
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        [b authorize];
    }];
    
    [operation start];
}

- (TUAuthClient *)getAuthClient;
{
    return b;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
