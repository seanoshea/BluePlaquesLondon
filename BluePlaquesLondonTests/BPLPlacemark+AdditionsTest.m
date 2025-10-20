#import <XCTest/XCTest.h>
#import "BPLPlacemark+Additions.h"

@interface BPLPlacemarkAdditionsTest : XCTestCase
@end

@implementation BPLPlacemarkAdditionsTest

- (void)testWikipediaURL {
    BPLPlacemark *placemark = [[BPLPlacemark alloc] init];
    placemark.name = @"Charles Darwin";
    
    NSURL *url = [placemark wikipediaURL];
    XCTAssertNotNil(url);
    XCTAssertTrue([url.absoluteString containsString:@"wikipedia.org"]);
    XCTAssertTrue([url.absoluteString containsString:@"Charles_Darwin"]);
}

- (void)testWikipediaURLWithSpaces {
    BPLPlacemark *placemark = [[BPLPlacemark alloc] init];
    placemark.name = @"Winston Churchill";
    
    NSURL *url = [placemark wikipediaURL];
    XCTAssertNotNil(url);
    XCTAssertTrue([url.absoluteString containsString:@"Winston_Churchill"]);
    XCTAssertFalse([url.absoluteString containsString:@" "]);
}

- (void)testWikipediaURLWithSpecialCharacters {
    BPLPlacemark *placemark = [[BPLPlacemark alloc] init];
    placemark.name = @"Test & Name";
    
    NSURL *url = [placemark wikipediaURL];
    XCTAssertNotNil(url);
    // Should handle URL encoding
    XCTAssertTrue([url.absoluteString containsString:@"Test"]);
}

- (void)testWikipediaURLWithNilName {
    BPLPlacemark *placemark = [[BPLPlacemark alloc] init];
    placemark.name = nil;
    
    NSURL *url = [placemark wikipediaURL];
    XCTAssertNil(url);
}

@end