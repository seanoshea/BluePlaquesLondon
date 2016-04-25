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

#import <XCTest/XCTest.h>

#import "BPLWikipediaViewModel.h"

#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OHHTTPStubs/OHPathHelpers.h>

@interface BPLWikipediaViewModelTest : XCTestCase

@property (nonatomic, strong) BPLWikipediaViewModel *model;

@end

@implementation BPLWikipediaViewModelTest

- (void)setUp
{
    [super setUp];
//    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
//        return [request.URL.host isEqualToString:@"https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=Churchill,%20Winston&srprop=timestamp&format=json"];
//    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
//        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFile(@"wikipedia.json",self.class)
//                                                statusCode:200
//                                                   headers:@{@"Content-Type":@"application/json"}];
//    }];
    self.model = [[BPLWikipediaViewModel alloc] initWithName:@"Churchill, Winston"];
}

- (void)testRetrieveWikipediaURL
{
    
    NSURL *URL = [NSURL URLWithString:@"https://www.google.com/"];
    NSString *description = [NSString stringWithFormat:@"GET %@", URL];
    XCTestExpectation *expectation = [self expectationWithDescription:description];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:URL
                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                  {
                                      XCTAssertNotNil(data, "data should not be nil");
                                      XCTAssertNil(error, "error should be nil");
                                      
                                      if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                          XCTAssertEqual(httpResponse.statusCode, 200, @"HTTP response status code should be 200");
                                          XCTAssertEqualObjects(httpResponse.URL.absoluteString, URL.absoluteString, @"HTTP response URL should be equal to original URL");
                                          XCTAssertEqualObjects(httpResponse.MIMEType, @"text/html", @"HTTP response content type should be text/html");
                                      } else {
                                          XCTFail(@"Response was not NSHTTPURLResponse");
                                      }
                                      
                                      [expectation fulfill];
                                  }];
    
    [task resume];
    
    [self waitForExpectationsWithTimeout:task.originalRequest.timeoutInterval handler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);    
        }
        [task cancel];
    }];
    
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//    
//    [self.model retrieveWikipediaUrlWithCompletionBlock:^(NSURLRequest *urlRequest, NSError *error) {
//        if (error == nil) {
//            XCTAssert([urlRequest.URL.absoluteString isEqualToString:@"https://en.wikipedia.org/wiki/Winston_Churchill"], @"The absolute URLs should be equal");
//        } else {
//            XCTFail(@"There was an error while retrieving the wikipedia URL: %@", error);
//        }
//        dispatch_semaphore_signal(semaphore);
//    }];
//    
//    long rc = dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 10.0 * NSEC_PER_SEC));
//    XCTAssertEqual(rc, 0, @"Failed to make network request");
}

@end
