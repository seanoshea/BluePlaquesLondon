#import <XCTest/XCTest.h>
#import "NSString+BPLPlacemarkFeatureDescription.h"

@interface NSStringBPLPlacemarkFeatureDescriptionTest : XCTestCase
@end

@implementation NSStringBPLPlacemarkFeatureDescriptionTest

- (void)testOccupationExtraction {
    NSString *description = @"<description>Writer and poet</description>";
    NSString *occupation = [description BPLOccupationFromFeatureDescription];
    
    XCTAssertNotNil(occupation);
    XCTAssertEqualObjects(occupation, @"Writer and poet");
}

- (void)testOccupationWithComplexHTML {
    NSString *description = @"<description><b>Writer</b> and <i>poet</i></description>";
    NSString *occupation = [description BPLOccupationFromFeatureDescription];
    
    XCTAssertNotNil(occupation);
    XCTAssertTrue([occupation containsString:@"Writer"]);
    XCTAssertTrue([occupation containsString:@"poet"]);
}

- (void)testOccupationWithNoDescription {
    NSString *description = @"No description tags here";
    NSString *occupation = [description BPLOccupationFromFeatureDescription];
    
    XCTAssertNotNil(occupation);
    XCTAssertEqualObjects(occupation, @"No description tags here");
}

- (void)testOccupationWithEmptyDescription {
    NSString *description = @"<description></description>";
    NSString *occupation = [description BPLOccupationFromFeatureDescription];
    
    XCTAssertNotNil(occupation);
    XCTAssertEqualObjects(occupation, @"");
}

- (void)testOccupationWithNilString {
    NSString *occupation = [nil BPLOccupationFromFeatureDescription];
    XCTAssertNil(occupation);
}

@end