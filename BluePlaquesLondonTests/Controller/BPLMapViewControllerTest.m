/*
 Copyright (c) 2014 - 2015 Upwards Northwards Software Limited
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

#import "BPLMapViewController.h"
#import "BPLMapViewDetailViewController.h"
#import "BPLConstants.h"
#import "BPLMapViewModel.h"
#import "BPLUnitTestHelper.h"
#import "BPLMapViewDetailViewModel.h"
#import "NSObject+BPLTracking.h"
#import "NSUserDefaults+BPLState.h"

@interface BPLMapViewControllerTest : XCTestCase

@property (nonatomic) UINavigationController *navigationController;
@property (nonatomic) BPLMapViewController *controller;

@end

@interface BPLMapViewController () <UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic) GMSMapView *mapView;

@property (nonatomic) BPLMapViewModel *model;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocation *currentLocation;

- (void)navigateToPlacemark:(BPLPlacemark *)placemark;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)toggleTableView:(BOOL)show;
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations;
- (void)filterDataForSearchText:(NSString *)searchText;
- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate;
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker;
- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker;

@end

@interface BPLMapViewModel ()

@property (nonatomic, copy) NSMutableDictionary *keyToArrayPositions;
@property (nonatomic) KMLRoot *data;

@end

@implementation BPLMapViewControllerTest

- (void)setUp
{
    [super setUp];
    UIStoryboard *storybord = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    self.controller = [storybord instantiateViewControllerWithIdentifier:BPLMapViewControllerStoryboardIdentifier];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.controller];
    [self.controller view];
    self.controller.model = [[BPLMapViewModel alloc] init];
}

- (void)testPrepareForSegue
{
    UIStoryboard *storybord = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    BPLMapViewDetailViewController *destinationViewController = [storybord instantiateViewControllerWithIdentifier:BPLMapViewDetailViewControllerStoryboardIdentifier];
    UIStoryboardSegue *segue = [[UIStoryboardSegue alloc] initWithIdentifier:BPLMapDetailViewControllerSegue source:self.controller destination:destinationViewController];

    BPLPlacemark *placemark = [BPLUnitTestHelper placemarkWithIdentifier:@"1"];
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    id markerMock = OCMPartialMock(marker);
    OCMStub([markerMock userData]).andReturn(placemark);
    
    id mapMock = OCMPartialMock(self.controller.mapView);
    OCMStub([mapMock selectedMarker]).andReturn(marker);

    KMLRoot *root = [[KMLRoot alloc] init];
    root.feature = [[KMLPlacemark alloc] init];
    
    id modelMock = OCMPartialMock(self.controller.model);
    OCMStub([modelMock data]).andReturn(root);
    
    self.controller.model.keyToArrayPositions = [@{@"1.000000.00000": @[@0]} mutableCopy];
    
    [self.controller prepareForSegue:segue sender:nil];
    
    XCTAssertTrue(destinationViewController.model.markers.count == 1);
}

- (void)testClosestPlacemarkDelegateMethod
{
    BPLPlacemark *placemark = [BPLUnitTestHelper placemarkWithIdentifier:@"1"];
    
    self.controller.currentLocation = [[CLLocation alloc] initWithLatitude:[placemark.latitude doubleValue] longitude:[placemark.longitude doubleValue]];
    
    id modelMock = OCMPartialMock(self.controller.model);
    OCMStub([modelMock closestPlacemarkToCoordinate:self.controller.currentLocation.coordinate]).andReturn(placemark);
    
    id partial = [OCMockObject partialMockForObject:self.controller];
    [[[partial expect] andForwardToRealObject] navigateToPlacemark:nil];
    [[[partial expect] andForwardToRealObject] trackCategory:BPLUIActionCategory action:BPLTableRowPressedEvent label:nil];
    
    [partial tableView:self.controller.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    OCMVerifyAll(modelMock);
}

- (void)testSpecificPlacemarkDelegateMethod {
    BPLPlacemark *placemark = [BPLUnitTestHelper placemarkWithIdentifier:@"1"];
    
    self.controller.currentLocation = [[CLLocation alloc] initWithLatitude:[placemark.latitude doubleValue] longitude:[placemark.longitude doubleValue]];
    
    id modelMock = OCMPartialMock(self.controller.model);
    OCMStub([modelMock closestPlacemarkToCoordinate:self.controller.currentLocation.coordinate]).andReturn(placemark);
    
    id partial = [OCMockObject partialMockForObject:self.controller];
    [[[partial expect] andForwardToRealObject] navigateToPlacemark:nil];
    [[[partial expect] andForwardToRealObject] trackCategory:BPLUIActionCategory action:BPLTableRowPressedEvent label:nil];
    
    [partial tableView:self.controller.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];

    OCMVerifyAll(partial);
}

- (void)testSearchBarShouldEndEditing
{
    XCTAssertTrue([self.controller searchBarShouldEndEditing:self.controller.searchBar]);
}

- (void)testSearchBarTextDidBeginEditing
{
    id controllerMock = OCMPartialMock(self.controller);
    OCMExpect([controllerMock toggleTableView:YES]).andForwardToRealObject();
    
    [self.controller searchBarTextDidBeginEditing:self.controller.searchBar];
    
    XCTAssertFalse(self.controller.tableView.hidden);
    
    OCMVerifyAll(controllerMock);
}

- (void)testSearchBarShouldBeginEditing
{
    XCTAssertTrue([self.controller searchBarShouldBeginEditing:self.controller.searchBar]);
}

- (void)testSearchBarChangeTextInRange
{
    XCTAssertTrue([self.controller searchBar:self.controller.searchBar shouldChangeTextInRange:NSMakeRange(0, 1) replacementText:@""]);
    XCTAssertTrue([self.controller searchBar:self.controller.searchBar shouldChangeTextInRange:NSMakeRange(0, 2) replacementText:@""]);
    XCTAssertTrue([self.controller searchBar:self.controller.searchBar shouldChangeTextInRange:NSMakeRange(0, 3) replacementText:@""]);
}

- (void)testSearchBarCancelButtonPressed
{
    [self.controller searchBarCancelButtonClicked:self.controller.searchBar];
    
    XCTAssertTrue(self.controller.tableView.hidden);
}

- (void)testSearchBarDidEndEditing
{
    id controllerMock = OCMPartialMock(self.controller);
    OCMExpect([controllerMock filterDataForSearchText:@""]).andForwardToRealObject();
    
    [controllerMock searchBarTextDidEndEditing:self.controller.searchBar];
    
    OCMVerifyAll(controllerMock);
}

- (void)testSearchBarTextDidChange
{
    id controllerMock = OCMPartialMock(self.controller);
    OCMExpect([controllerMock filterDataForSearchText:@"123"]).andForwardToRealObject();
    
    [controllerMock searchBar:self.controller.searchBar textDidChange:@"123"];
    
    OCMVerifyAll(controllerMock);
}

- (void)testFilterData
{
    id tableMock = OCMPartialMock(self.controller.tableView);
    OCMExpect([tableMock reloadData]).andForwardToRealObject();
    
    [self.controller filterDataForSearchText:@"123"];
    
    OCMVerifyAll(tableMock);
}

- (void)testUpdateCurrentLocation
{
    CLLocation *locationOne = [[CLLocation alloc] initWithLatitude:123.30 longitude:140.11];
    CLLocation *locationTwo = [[CLLocation alloc] initWithLatitude:37.785834000000001 longitude:-122.406417];
    
    [self.controller locationManager:self.controller.locationManager didUpdateLocations:@[locationOne, locationTwo]];
    
    XCTAssertTrue(self.controller.currentLocation.coordinate.latitude == 37.785834000000001);
    XCTAssertTrue(self.controller.currentLocation.coordinate.longitude == -122.406417);
    
    CLLocationCoordinate2D lastKnownCoordinate = [NSUserDefaults standardUserDefaults].lastKnownCoordinate;
    
    XCTAssertTrue(lastKnownCoordinate.latitude == 37.785834000000001);
    XCTAssertTrue(lastKnownCoordinate.longitude == -122.406417);
}

- (void)testUserTappingOnCoodinate
{
    [self.controller mapView:self.controller.mapView didTapAtCoordinate:[NSUserDefaults standardUserDefaults].lastKnownCoordinate];
    
    XCTAssertTrue(self.controller.tableView.hidden);
}

- (void)testUserTappingOnMarker
{
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(37.785834000000001, -122.406417);
    
    BOOL returnValue = [self.controller mapView:self.controller.mapView didTapMarker:marker];
    
    CLLocationCoordinate2D lastKnown = [NSUserDefaults standardUserDefaults].lastKnownBPLCoordinate;
    
    XCTAssertFalse(returnValue);
    XCTAssertTrue(lastKnown.latitude == 37.785834000000001);
    XCTAssertTrue(lastKnown.longitude == -122.406417);
}

- (void)testUserTappingOnInfoWindow
{
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(37.785834000000001, -122.406417);
    
    id controllerMock = OCMPartialMock(self.controller);
    OCMExpect([controllerMock performSegueWithIdentifier:BPLMapDetailViewControllerSegue sender:self.controller]).andForwardToRealObject();
    
    [controllerMock mapView:self.controller.mapView didTapInfoWindowOfMarker:marker];
    
    OCMVerifyAll(controllerMock);
}

@end
