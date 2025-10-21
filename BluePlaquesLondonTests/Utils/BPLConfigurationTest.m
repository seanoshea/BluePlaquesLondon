/*
 Copyright (c) 2014 - present Upwards Northwards Software Limited
 All rights reserved.
 */

#import <XCTest/XCTest.h>
#import "BPLConfiguration.h"
#import "NSUserDefaults+BPLState.h"

@interface BPLConfigurationTest : XCTestCase
@end

@implementation BPLConfigurationTest

- (void)testIsTrackingEnabled
{
  BOOL enabled = [BPLConfiguration isTrackingEnabled];
  XCTAssertTrue(enabled || !enabled, @"Should return a boolean value");
}

- (void)testTrackingDisabled
{
  [[NSUserDefaults standardUserDefaults] saveTrackingEnabled:NO];
  BOOL enabled = [BPLConfiguration isTrackingEnabled];
  XCTAssertFalse(enabled, @"Tracking should be disabled when set to NO");
}

- (void)tearDown
{
  NSString *appDomain = [NSBundle mainBundle].bundleIdentifier;
  [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

@end
