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

#import "SimpleKMLPlacemark+Additions.h"

@interface BPLWikipediaViewController() <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end

@implementation BPLWikipediaViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Wikipedia Article";
    self.webView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    SimpleKMLPlacemark *placemark = (SimpleKMLPlacemark *)self.marker.userData;
    
    NSString *strUTF8 = [[NSString stringWithFormat:@"http://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=%@&srprop=timestamp&format=json", placemark.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:strUTF8]] queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
    }];
    
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
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

- (void)dealloc
{
    [self.webView stopLoading];
    self.webView.delegate = nil;
}

@end
