/*
 Copyright 2013 - 2014 Sean O' Shea
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "BPLWikipediaViewController.h"

#import <SVProgressHUD/SVProgressHUD.h>

#import "BPLWikipediaViewModel.h"
#import "UIColor+BPLColors.h"
#import "NSObject+BPLTracking.h"
#import "BPLConstants.h"

@interface BPLWikipediaViewController() <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@property (nonatomic) BPLWikipediaViewModel *model;

@end

@implementation BPLWikipediaViewController

#pragma mark Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"Wikipedia Screen";

    self.webView.backgroundColor = [UIColor BPLGreyColour];
    self.webView.opaque = NO;
    
    KMLPlacemark *placemark = self.markers[0];
    self.model = [[BPLWikipediaViewModel alloc] initWithName:placemark.name];
    self.navigationItem.title = NSLocalizedString(@"Wikipedia Article", nil);
    self.webView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [SVProgressHUD show];
    [self.model retrieveWikipediaUrlWithCompletionBlock:^(NSURLRequest *urlRequest, NSError *error) {
        if (!error) {
            [self.webView loadRequest:urlRequest];
        } else {
            [self displayErrorAlert];
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [SVProgressHUD dismiss];
    [super viewWillDisappear:animated];
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self displayErrorAlert];
}

#pragma mark Errors

- (void)displayErrorAlert
{
    [SVProgressHUD dismiss];
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oooops", nil)
                                message:NSLocalizedString(@"There was an error loading this Wikipedia Article", nil)
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                      otherButtonTitles:nil] show];
    if (self.markers.count) {
        KMLPlacemark *placemark = self.markers[0];
        [self trackCategory:BPLErrorCategory action:BPLWikipediaPageLoadErrorEvent label:placemark.name];
    }
}

- (void)dealloc
{
    self.webView.delegate = nil;
    [self.webView stopLoading];
}

@end
