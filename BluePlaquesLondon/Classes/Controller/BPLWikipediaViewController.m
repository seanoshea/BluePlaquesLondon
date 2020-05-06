/*
 Copyright (c) 2014 - present Upwards Northwards Software Limited
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 1. Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 3. All advertising materials mentioning features or use of this software
 must display the following acknowledgement:
 This product includes software developed by Upwards Northwards Software Limited.
 4. Neither the name of Upwards Northwards Software Limited nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY UPWARDS NORTHWARDS SOFTWARE LIMITED ''AS IS'' AND ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL UPWARDS NORTHWARDS SOFTWARE LIMITED BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "BPLWikipediaViewController.h"

#import "BPLWikipediaViewModel.h"
#import "UIColor+BPLColors.h"
#import "NSObject+BPLTracking.h"
#import "BPLConstants.h"
#import "KMLPlacemark.h"
#import "MaterialActivityIndicator.h"
#import "MDCCollectionViewCell.h"

#import <WebKit/WebKit.h>

@interface BPLWikipediaViewController() <WKNavigationDelegate>

@property (nonatomic, weak) IBOutlet WKWebView *webView;
@property (nonatomic) MDCActivityIndicator *activityIndicator;

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
  
  self.view.backgroundColor = [UIColor whiteColor];
  
  KMLPlacemark *placemark = self.markers[0];
  self.model = [[BPLWikipediaViewModel alloc] initWithName:placemark.name];
  self.navigationItem.title = NSLocalizedString(@"Wikipedia Article", nil);
  self.webView.navigationDelegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.webView.hidden = YES;
  self.activityIndicator = [[MDCActivityIndicator alloc] initWithFrame:CGRectMake(0, 0, 128, 128)];
  self.activityIndicator.center = self.view.center;
  self.activityIndicator.strokeWidth = 4.0f;
  self.activityIndicator.radius = 18.0f;
  self.activityIndicator.cycleColors = @[[UIColor BPLBlueColour]];
  [self.view addSubview:self.activityIndicator];
  [self.activityIndicator startAnimating];
  
  [[self.model retrieveWikipediaUrlWithCompletionBlock:^(NSURLRequest *urlRequest, NSError *error) {
    if (!error) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.webView loadRequest:urlRequest];
      });
    } else {
      [self displayErrorAlert];
    }
  }] resume];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [self hideActivityIndicator];
  [super viewWillDisappear:animated];
}

#pragma mark WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
  [self hideActivityIndicator];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
  [self displayErrorAlert];
}

#pragma mark Errors

- (void)displayErrorAlert
{
  [self hideActivityIndicator];
  
  NSString *title = NSLocalizedString(@"Oooops", nil);
  NSString *message = NSLocalizedString(@"There was an error loading this Wikipedia Article", nil);
  UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil];
  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                           message:message
                                                                    preferredStyle:UIAlertControllerStyleAlert];
  [alertController addAction:action];
  [self presentViewController:alertController animated:YES completion:nil];
  
  if ((self.markers).count) {
    KMLPlacemark *placemark = self.markers[0];
    [self trackCategory:BPLErrorCategory action:BPLWikipediaPageLoadErrorEvent label:placemark.name];
  }
}

- (void)hideActivityIndicator
{
  CGFloat x = self.activityIndicator.frame.origin.x;
  [UIView animateWithDuration:1.75
                        delay:0.1
                      options: UIViewAnimationOptionCurveEaseIn
                   animations:^{
                     self.activityIndicator.frame = CGRectMake(x, 0, 128, 128);
                   }
                   completion:^(BOOL finished){
                     if (finished) {
                       [self fadeInWebView];
                     }
                   }];
  [UIView animateWithDuration:1.75f animations:^{
    self.activityIndicator.alpha = 0.0f;
  } completion:^(BOOL finished) {
    if (finished) {
      
    }
  }];
}

- (void)fadeInWebView {
  self.webView.alpha = 0.0f;
  self.webView.hidden = NO;
  [UIView animateWithDuration:0.1f animations:^{
    self.webView.alpha = 1.0f;
  } completion:^(BOOL finished) {
    if (finished) {
      [self.activityIndicator stopAnimating];
      [self.activityIndicator removeFromSuperview];
    }
  }];
}

- (void)dealloc
{
  self.webView.navigationDelegate = nil;
  [self.webView stopLoading];
}

@end
