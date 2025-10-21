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

#import <XCTest/XCTest.h>

#import "BPLWikipediaParser.h"

@interface BPLWikipediaParserTest : XCTestCase

@end

@implementation BPLWikipediaParserTest

- (void)testHTTPError
{
  XCTestExpectation *expectation = [self expectationWithDescription:@"HTTP error handled"];
  NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"wikipedia_malformed" ofType:@"json"];
  NSData *data = [NSData dataWithContentsOfFile:path];
  NSError *httpError = [[NSError alloc] initWithDomain:@"Domain" code:123 userInfo:nil];
  [BPLWikipediaParser parseWikipediaData:data error:httpError name:@"Churchill" completionBlock:^(NSURLRequest *urlRequest, NSError *error) {
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, 123);
    XCTAssertEqualObjects(error.domain, @"Domain");
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testMalformedJSON
{
  XCTestExpectation *expectation = [self expectationWithDescription:@"Malformed JSON handled"];
  NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"wikipedia_malformed" ofType:@"json"];
  NSData *data = [NSData dataWithContentsOfFile:path];
  NSError *error = nil;
  [BPLWikipediaParser parseWikipediaData:data error:error name:@"Churchill" completionBlock:^(NSURLRequest *urlRequest, NSError *error) {
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, 3840);
    XCTAssertEqualObjects(error.domain, @"NSCocoaErrorDomain");
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testEmptySearchResponseJSON
{
  XCTestExpectation *expectation = [self expectationWithDescription:@"Empty search handled"];
  NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"wikipedia_empty" ofType:@"json"];
  NSData *data = [NSData dataWithContentsOfFile:path];
  NSError *error = nil;
  [BPLWikipediaParser parseWikipediaData:data error:error name:@"Churchill" completionBlock:^(NSURLRequest *urlRequest, NSError *error) {
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, 404);
    XCTAssertEqualObjects(error.domain, @"BPLWikipediaParserStringsErrorDomain");
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testNameMissing
{
  XCTestExpectation *expectation = [self expectationWithDescription:@"Name missing handled"];
  NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"wikipedia" ofType:@"json"];
  NSData *data = [NSData dataWithContentsOfFile:path];
  NSError *error = nil;
  [BPLWikipediaParser parseWikipediaData:data error:error name:@"Thatcher" completionBlock:^(NSURLRequest *urlRequest, NSError *error) {
    XCTAssertNil(error);
    XCTAssertEqualObjects(urlRequest.URL.absoluteString, @"https://en.wikipedia.org/wiki/Winston_Churchill");
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testSargent
{
  XCTestExpectation *expectation = [self expectationWithDescription:@"Sargent parsed"];
  NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"wikipedia_sargent" ofType:@"json"];
  NSData *data = [NSData dataWithContentsOfFile:path];
  NSError *error = nil;
  [BPLWikipediaParser parseWikipediaData:data error:error name:@"SARGENT, Sir Malcolm" completionBlock:^(NSURLRequest *urlRequest, NSError *error) {
    XCTAssertNil(error);
    XCTAssertEqualObjects(urlRequest.URL.absoluteString, @"https://en.wikipedia.org/wiki/Malcolm_Sargent");
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

@end
