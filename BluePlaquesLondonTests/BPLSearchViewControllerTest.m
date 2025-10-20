#import <XCTest/XCTest.h>
#import "BPLSearchViewController.h"

@interface BPLSearchViewControllerTest : XCTestCase
@property (nonatomic) BPLSearchViewController *viewController;
@end

@implementation BPLSearchViewControllerTest

- (void)setUp {
    [super setUp];
    self.viewController = [[BPLSearchViewController alloc] init];
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

- (void)testTableViewDataSource {
    [self.viewController viewDidLoad];
    
    // Test basic table view data source methods don't crash
    if ([self.viewController respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
        XCTAssertNoThrow([self.viewController tableView:nil numberOfRowsInSection:0]);
    }
}

- (void)testSearchFunctionality {
    [self.viewController viewDidLoad];
    
    // Test search methods don't crash
    if ([self.viewController respondsToSelector:@selector(searchBar:textDidChange:)]) {
        XCTAssertNoThrow([self.viewController searchBar:nil textDidChange:@"test"]);
    }
}

@end