//
//  AuthViewController.h
//  TUDirect
//
//  Created by Martijn de Vos on 09-04-13.
//  Copyright (c) 2013 Martijn de Vos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AuthViewController : UIViewController

- (void)loadURL:(NSURL *)url;
- (UIWebView *)getWebView;

@end
