/*
 Copyright (c) 2014 - 2016 Upwards Northwards Software Limited
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "BPLWikipediaViewController.h"
#import "BPLUnitTestHelper.h"
#import "BPLWikipediaViewModel.h"

@interface BPLWikipediaViewControllerTest : XCTestCase

@property (nonatomic) UINavigationController *navigationController;
@property (nonatomic) BPLWikipediaViewController *controller;

@end

@interface BPLWikipediaViewController () <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic) BPLWikipediaViewModel *model;

- (void)displayErrorAlert;

@end

@implementation BPLWikipediaViewControllerTest

- (void)setUp {
    [super setUp];
    UIStoryboard *storybord = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.controller = [storybord instantiateViewControllerWithIdentifier:@"BPLWikipediaViewController"];
    self.controller.markers = @[[BPLUnitTestHelper placemarkWithIdentifier:@"1"]];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.controller];
    __unused id view = (self.controller).view;
}

- (void)testInitialisation
{
    XCTAssertTrue([self.controller.navigationItem.title isEqual:@"Wikipedia Article"]);
    XCTAssertTrue(self.controller.model != nil);
    XCTAssertTrue(self.controller.webView != nil);
}

- (void)testLoadWikipediaModel
{
    id partial = [OCMockObject partialMockForObject:self.controller.model];
    [[[partial expect] andForwardToRealObject] retrieveWikipediaUrlWithCompletionBlock:[OCMArg any]];
    
    [self.controller viewWillAppear:YES];
    
    OCMVerifyAll(partial);
}

- (void)testShouldLoadMethod
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://wikipedia.org"]];
    XCTAssertTrue([self.controller webView:self.controller.webView shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeLinkClicked]);
}

- (void)testWebViewFinishLoadFailure
{
    id alertControllerMock = OCMClassMock([UIAlertController class]);
    [OCMStub([alertControllerMock alertControllerWithTitle:NSLocalizedString(@"Oooops", nil) message:NSLocalizedString(@"There was an error loading this Wikipedia Article", nil) preferredStyle:UIAlertControllerStyleAlert]) andReturn:alertControllerMock];
    [[alertControllerMock expect] addAction:OCMOCK_ANY];
    
    id partial = [OCMockObject partialMockForObject:self.controller];
    [[[partial expect] andForwardToRealObject] displayErrorAlert];
    [[[partial expect] andForwardToRealObject] presentViewController:alertControllerMock animated:YES completion:nil];
    
    NSError *error = [[NSError alloc] initWithDomain:@"DOMAIN" code:500 userInfo:@{}];
    [partial webView:self.controller.webView didFailLoadWithError:error];
    
    OCMVerifyAll(partial);
    OCMVerifyAll(alertControllerMock);
}

@end
