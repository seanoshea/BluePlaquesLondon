#import <XCTest/XCTest.h>
#import "BPLAboutViewController.h"

@interface BPLAboutViewControllerTest : XCTestCase
@property (nonatomic) BPLAboutViewController *viewController;
@end

@implementation BPLAboutViewControllerTest

- (void)setUp {
    [super setUp];
    self.viewController = [[BPLAboutViewController alloc] init];
}

- (void)testViewControllerCreation {
    XCTAssertNotNil(self.viewController);
    XCTAssertTrue([self.viewController isKindOfClass:[UIViewController class]]);
}

- (void)testViewDidLoad {
    XCTAssertNoThrow([self.viewController viewDidLoad]);
}

- (void)testViewWillAppear {
    XCTAssertNoThrow([self.viewController viewWillAppear:YES]);
    XCTAssertNoThrow([self.viewController viewWillAppear:NO]);
}

- (void)testViewDidAppear {
    XCTAssertNoThrow([self.viewController viewDidAppear:YES]);
    XCTAssertNoThrow([self.viewController viewDidAppear:NO]);
}

- (void)testTitle {
    [self.viewController viewDidLoad];
    XCTAssertNotNil(self.viewController.title);
}

@end