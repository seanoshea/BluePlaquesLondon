//
//  BPLWikipediaViewControllerTest.m
//  BluePlaquesLondon
//
//  Created by Sean O Shea on 2/28/15.
//  Copyright (c) 2015 Sean O'Shea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "BPLWikipediaViewController.h"
#import "BPLUnitTestHelper.h"
#import "BPLWikipediaViewModel.h"
#import "SVProgressHUD.h"

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
    UIStoryboard *storybord = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    self.controller = [storybord instantiateViewControllerWithIdentifier:@"BPLWikipediaViewController"];
    self.controller.markers = @[[BPLUnitTestHelper placemarkWithIdentifier:@"1"]];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.controller];
    [self.controller view];
}

- (void)tearDown
{
    [super tearDown];
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
    XCTAssertTrue([self.controller webView:self.controller.webView shouldStartLoadWithRequest:nil navigationType:UIWebViewNavigationTypeLinkClicked]);
}

- (void)testWebViewFinishLoadFailure
{
    id partial = [OCMockObject partialMockForObject:self.controller];
    [[[partial expect] andForwardToRealObject] displayErrorAlert];
    
    NSError *error = [[NSError alloc] initWithDomain:@"DOMAIN" code:500 userInfo:@{}];
    [partial webView:self.controller.webView didFailLoadWithError:error];
    
    OCMVerifyAll(partial);
}

@end
