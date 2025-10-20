#import <XCTest/XCTest.h>
#import "BPLAboutViewModel.h"

@interface BPLAboutViewModelTest : XCTestCase
@end

@implementation BPLAboutViewModelTest

- (void)testViewModelCreation {
    BPLAboutViewModel *viewModel = [[BPLAboutViewModel alloc] init];
    XCTAssertNotNil(viewModel);
}

- (void)testMapsOpenSourceLicenseInfo {
    BPLAboutViewModel *viewModel = [[BPLAboutViewModel alloc] init];
    NSString *licenseInfo = viewModel.mapsOpenSourceLicenseInfo;
    XCTAssertNotNil(licenseInfo);
    XCTAssertTrue(licenseInfo.length > 0);
}

- (void)testVersionString {
    BPLAboutViewModel *viewModel = [[BPLAboutViewModel alloc] init];
    NSString *version = viewModel.versionString;
    XCTAssertNotNil(version);
    XCTAssertTrue([version containsString:@"Version"]);
}

- (void)testBuildString {
    BPLAboutViewModel *viewModel = [[BPLAboutViewModel alloc] init];
    NSString *build = viewModel.buildString;
    XCTAssertNotNil(build);
    XCTAssertTrue([build containsString:@"Build"]);
}

@end