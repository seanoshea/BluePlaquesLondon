//
//  BPLMapViewControllerTest.m
//  BluePlaquesLondon
//
//  Created by Sean O Shea on 2/26/15.
//  Copyright (c) 2015 Sean O'Shea. All rights reserved.
//

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

@interface BPLMapViewControllerTest : XCTestCase

@property (nonatomic) BPLMapViewController *controller;

@end

@interface BPLMapViewController () <UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic) GMSMapView *mapView;

@property (nonatomic) BPLMapViewModel *model;
@property (nonatomic) CLLocation *currentLocation;

- (void)navigateToPlacemark:(BPLPlacemark *)placemark;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)toggleTableView:(BOOL)show;

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
    [self.controller view];
    self.controller.model = [[BPLMapViewModel alloc] init];
}

- (void)tearDown
{
    [super tearDown];
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
    
    id  mapMock = OCMPartialMock(self.controller.mapView);
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
    
    OCMExpect([self.controller navigateToPlacemark:placemark]);
    OCMExpect([self.controller trackCategory:BPLUIActionCategory action:BPLTableRowPressedEvent label:nil]);
    
    [self.controller tableView:self.controller.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
}

- (void)testSpecificPlacemarkDelegateMethod {
    BPLPlacemark *placemark = [BPLUnitTestHelper placemarkWithIdentifier:@"1"];
    
    self.controller.currentLocation = [[CLLocation alloc] initWithLatitude:[placemark.latitude doubleValue] longitude:[placemark.longitude doubleValue]];
    
    id modelMock = OCMPartialMock(self.controller.model);
    OCMStub([modelMock closestPlacemarkToCoordinate:self.controller.currentLocation.coordinate]).andReturn(placemark);
    
    OCMExpect([self.controller navigateToPlacemark:placemark]);
    OCMExpect([self.controller trackCategory:BPLUIActionCategory action:BPLTableRowPressedEvent label:nil]);
    
    [self.controller tableView:self.controller.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
}

- (void)testSearchBarShouldEndEditing
{
    XCTAssertTrue([self.controller searchBarShouldBeginEditing:self.controller.searchBar]);
}

- (void)testSearchBarTextDidBeginEditing
{
    id tableViewMock = OCMPartialMock(self.controller);
    OCMExpect([tableViewMock toggleTableView:YES]).andForwardToRealObject();
    
    [self.controller searchBarTextDidBeginEditing:self.controller.searchBar];
    
    XCTAssertFalse(self.controller.tableView.hidden);
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

@end
