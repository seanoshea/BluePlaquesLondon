/*
 Copyright 2012 - 2013 UpwardsNorthwards
 
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

#import <DACircularProgress/DACircularProgressView.h>

#import "SimpleKMLPlacemark+Additions.h"
#import "BPLWikipediaViewModel.h"
#import "UIColor+BluePlaquesLondon.h"

@interface BPLWikipediaViewController() <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (strong, nonatomic) DACircularProgressView *progressView;
@property (strong, nonatomic) NSTimer *timer;

@property (nonatomic) BPLWikipediaViewModel *model;

@end

@implementation BPLWikipediaViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.progressView = [[DACircularProgressView alloc] initWithFrame:CGRectMake(140.0f, 140.0f, 40.0f, 40.0f)];
    self.progressView.roundedCorners = YES;
    self.progressView.trackTintColor = [UIColor darkBlueColour];
    [self.view addSubview:self.progressView];
    
    self.model = [[BPLWikipediaViewModel alloc] initWithPlacemark:self.markers[0]];
    self.navigationItem.title = NSLocalizedString(@"Wikipedia Article", nil);
    self.webView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startAnimation];
    [self.model retrieveWikipediaUrlWithCompletionBlock:^(NSURLRequest *urlRequest, NSError *error) {
        if (!error) {
            [self.webView loadRequest:urlRequest];
        } else {
            [self stopAnimation];
        }
    }];    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopAnimation];
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
    [self stopAnimation];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self stopAnimation];
}

- (void)progressChange
{
    CGFloat progress = ![self.timer isValid] ? 30 / 10.0f : self.progressView.progress + 0.01f;
    [self.progressView setProgress:progress animated:YES];
    if (self.progressView.progress >= 1.0f && [self.timer isValid]) {
        [self.progressView setProgress:0.f animated:YES];
    }
}

- (void)startAnimation
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(progressChange) userInfo:nil repeats:YES];
}

- (void)stopAnimation
{
    [self.timer invalidate];
    self.progressView.hidden = YES;
}

- (void)dealloc
{
    [self.webView stopLoading];
    self.webView.delegate = nil;
}

@end
