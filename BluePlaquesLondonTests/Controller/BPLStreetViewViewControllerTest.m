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

#import <UIKit/UIKit.h>

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <GoogleMaps/GoogleMaps.h>

#import "BPLStreetViewViewController.h"
#import "BPLUnitTestHelper.h"
#import "BPLConstants.h"
#import "NSObject+BPLTracking.h"

@interface BPLStreetViewViewController () <GMSPanoramaViewDelegate>

@end

@interface BPLStreetViewViewControllerTest : XCTestCase

@property (nonatomic) UINavigationController *navigationController;
@property (nonatomic) BPLStreetViewViewController *controller;

@end

@implementation BPLStreetViewViewControllerTest

- (void)setUp
{
  [super setUp];
  UIStoryboard *storybord = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  self.controller = [storybord instantiateViewControllerWithIdentifier:@"BPLStreetViewViewController"];
  self.controller.placemark = [BPLUnitTestHelper placemarkWithIdentifier:@"1"];
  self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.controller];
  __unused id view = (self.controller).view;
}

- (void)testInitialisation
{
  XCTAssertTrue([self.controller.title isEqualToString:@"Street View"]);
  XCTAssertTrue([self.controller.screenName isEqualToString:@"Street View Screen"]);
}

- (void)testAlertControllerError
{
  id alertControllerMock = OCMClassMock([UIAlertController class]);
  [OCMStub([alertControllerMock alertControllerWithTitle:NSLocalizedString(@"Oooops", nil) message:NSLocalizedString(@"Could not load Street View", nil) preferredStyle:UIAlertControllerStyleAlert]) andReturn:alertControllerMock];
  [[alertControllerMock expect] addAction:OCMOCK_ANY];
  
  GMSPanorama *mockPanorama = [OCMockObject mockForClass:[GMSPanorama class]];
  [OCMStub([mockPanorama panoramaID]) andReturn:nil];
  
  id partial = [OCMockObject partialMockForObject:self.controller];
  [[[partial expect] andForwardToRealObject] presentViewController:alertControllerMock animated:YES completion:nil];
  [[[partial expect] andForwardToRealObject] trackCategory:BPLErrorCategory action:BPLStreetMapsPageLoadErrorEvent label:OCMOCK_ANY];
  
  [partial panoramaView:(GMSPanoramaView *)self.controller.view didMoveToPanorama:mockPanorama];
  
  OCMVerifyAll(partial);
  OCMVerifyAll(alertControllerMock);
}

@end
