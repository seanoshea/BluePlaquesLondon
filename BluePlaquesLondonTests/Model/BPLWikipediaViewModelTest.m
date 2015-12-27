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

#import <XCTest/XCTest.h>

#import "BPLURLResourceLoader.h"
#import "BPLWikipediaViewModel.h"

@interface BPLWikipediaViewModelTest : XCTestCase

@property (nonatomic, strong) BPLWikipediaViewModel *model;

@end

@implementation BPLWikipediaViewModelTest

- (void)setUp
{
    [super setUp];
    self.model = [[BPLWikipediaViewModel alloc] initWithName:@"Churchill, Winston"];
}

- (void)testRetrieveWikipediaURL
{
    [NSURLProtocol registerClass:[BPLURLResourceLoader class]];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing [WikipediaViewModel retrieveWikipediaUrlWithCompletionBlock]"];

    [self.model retrieveWikipediaUrlWithCompletionBlock:^(NSURLRequest *urlRequest, NSError *error) {
        if (error == nil) {
            XCTAssert([urlRequest.URL.absoluteString isEqualToString:@"https://en.wikipedia.org/wiki/Winston_Churchill"], @"The absolute URLs should be equal");
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

- (void)tearDown
{
    [NSURLProtocol unregisterClass:[BPLURLResourceLoader class]];
}

@end
