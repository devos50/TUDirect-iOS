/*
 * Copyright (c) 2012, Betable Limited
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of Betable Limited nor the names of its contributors
 *       may be used to endorse or promote products derived from this software
 *       without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL BETABLE LIMITED BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "TUAuthClient.h"
#import "AuthViewController.h"

NSString const *TUAuthorizeURL = @"https://oauth.tudelft.nl/oauth2/authorize";
NSString *TUTokenURL = @"https://oauth.tudelft.nl/oauth2/token";

@interface TUAuthClient () <UIWebViewDelegate>
- (NSString *)urlEncode:(NSString*)string;
- (void)checkAccessToken;
+ (NSString*)base64forData:(NSData*)theData;

@end

@implementation TUAuthClient
{
    AuthViewController *authViewController;
}

- (TUAuthClient *)init
{
    self = [super init];
    if (self)
    {
        _clientID = nil;
        _clientSecret = nil;
        _redirectURI = nil;
        _accessToken = nil;
        _queue = [[NSOperationQueue alloc] init];
        
        authViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"AuthViewController"];
    }
    return self;
}

- (TUAuthClient *)initWithClientID:(NSString*)aClientID clientSecret:(NSString*)aClientSecret redirectURI:(NSString*)aRedirectURI
{
    self = [self init];
    if (self) {
        _clientID = aClientID;
        _clientSecret = aClientSecret;
        _redirectURI = aRedirectURI;
    }
    return self;
}

- (void)authorizeOnViewController:(UIViewController *)vc
{
    NSString* urlFormat = @"%@?client_id=%@&redirect_uri=%@&response_type=code";
    NSString *authURL = [NSString stringWithFormat:urlFormat,
                         TUAuthorizeURL,
                         [self urlEncode:_clientID],
                         [self urlEncode:_redirectURI]];
    
    // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:authURL]];
    [vc presentViewController:authViewController animated:YES completion:nil];
    [authViewController loadURL:[NSURL URLWithString:authURL]];
    [[authViewController getWebView] setDelegate:self];
}

- (void)token:(NSString*)code onComplete:(TUAccessTokenHandler)onComplete onFailure:(TUFailureHandler)onFailure
{
    NSURL *apiURL = [NSURL URLWithString:TUTokenURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", _clientID, _clientSecret];
    NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [TUAuthClient base64forData:authData]];
    [request setAllHTTPHeaderFields:[NSDictionary dictionaryWithObject:authValue forKey:@"Authorization"]];
    
    [request setHTTPMethod:@"POST"]; 
    NSString *body = [NSString stringWithFormat:@"grant_type=authorization_code&redirect_uri=%@&code=%@",
                      [self urlEncode:_redirectURI],
                      code];

    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:request queue:_queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (error) {
            onFailure(response, responseBody, error);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            _accessToken = dict[@"access_token"];
            onComplete(self.accessToken);
        }
    }];
}
- (void)checkAccessToken {
    if (self.accessToken == nil) {
        [NSException raise:@"User is not authorized"
                    format:@"User must have an access token to use this feature"];
    }
}

- (NSString*)urlEncode:(NSString*)string {
    NSString *encoded = (__bridge NSString*)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)string,
                                                               NULL,
                                                               (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                               CFStringConvertNSStringEncodingToEncoding(NSASCIIStringEncoding));
    return encoded;
}

+ (NSString*)base64forData:(NSData*)theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

- (void)dealloc {
    _accessToken = nil;
    _clientSecret = nil;
    _clientID = nil;
    _redirectURI = nil;
    _queue = nil;
}

#pragma mark - UIWebView delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if(![[request.URL.absoluteString substringToIndex:11] isEqualToString:@"tuiosapp://"]) return YES;
    
    NSString *code = [[request.URL absoluteString] substringFromIndex:11];
    NSLog(@"code: %@", code);
    [self token:code onComplete:^(NSString *accessToken) {
        [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"AccessToken"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.devos.TUDirect.reloadGrades" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.devos.TUDirect.reloadProgress" object:nil];
        
    } onFailure:^(NSURLResponse *response, NSString *responseBody, NSError *error) {
        NSLog(@"failure!");
    }];
    
    [authViewController dismissModalViewControllerAnimated:YES];
    NSLog(@"lurl: %@", request.URL.absoluteString);
    
    return YES;
}

@end
