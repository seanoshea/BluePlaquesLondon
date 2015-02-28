//
//  BPLMapViewDetailViewControllerTest.m
//  BluePlaquesLondon
//
//  Created by Sean O Shea on 2/26/15.
//  Copyright (c) 2015 Sean O'Shea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "BPLMapViewDetailViewController.h"
#import "BPLMapViewDetailViewModel.h"
#import "BPLLabel.h"
#import "BPLButton.h"
#import "BPLPlacemark.h"
#import "BPLUnitTestHelper.h"
#import "BPLConstants.h"
#import "BPLWikipediaViewController.h"
#import "BPLDetailChooserViewController.h"
#import "BPLStreetViewViewController.h"

@interface BPLMapViewDetailViewControllerTest : XCTestCase

@property (nonatomic) UINavigationController *navigationController;
@property (nonatomic) BPLMapViewDetailViewController *controller;
@property (nonatomic) BPLPlacemark *marker1;

@end

@interface BPLMapViewDetailViewController()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic, weak) IBOutlet BPLLabel *occupationLabel;
@property (nonatomic, weak) IBOutlet BPLLabel *addressLabel;
@property (nonatomic, weak) IBOutlet BPLLabel *noteLabel;
@property (nonatomic, weak) IBOutlet BPLLabel *councilAndYearLabel;

@property (nonatomic, weak) IBOutlet BPLButton *streetButton;
@property (nonatomic, weak) IBOutlet BPLButton *wikipediaButton;
@property (nonatomic, weak) IBOutlet BPLButton *moreButton;
@property (nonatomic, weak) IBOutlet BPLButton *directionsButton;

- (IBAction)directionsButtonTapped:(id)sender;
- (void)buttonTappedForPlacemark:(BPLPlacemark *)placemark withAction:(NSString *)action;
- (void)detailChooserViewControllerRowSelected:(NSNotification *)notification;

@end

@implementation BPLMapViewDetailViewControllerTest

- (void)setUp
{
    [super setUp];
    UIStoryboard *storybord = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    self.controller = [storybord instantiateViewControllerWithIdentifier:BPLMapViewDetailViewControllerStoryboardIdentifier];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.controller];
    [self.controller view];

    self.marker1 = [BPLUnitTestHelper placemarkWithIdentifier:@"1"];
    BPLMapViewDetailViewModel *model = [[BPLMapViewDetailViewModel alloc] init];
    model.markers = @[self.marker1];
    
    self.controller.model = model;
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testInitialisation
{
    XCTAssertTrue([self.controller.screenName isEqualToString:@"Map Detail Screen"]);
    
    XCTAssertTrue(self.controller.occupationLabel != nil);
    XCTAssertTrue(self.controller.addressLabel != nil);
    XCTAssertTrue(self.controller.noteLabel != nil);
    XCTAssertTrue(self.controller.councilAndYearLabel != nil);
    XCTAssertTrue(self.controller.streetButton != nil);
    XCTAssertTrue(self.controller.wikipediaButton != nil);
    XCTAssertTrue(self.controller.moreButton != nil);
    XCTAssertTrue(self.controller.directionsButton != nil);
}

- (void)testPlacemarkInitialisation
{
    [self.controller viewWillAppear:YES];

    [self.controller.occupationLabel.text isEqualToString:@"Feature Description 1"];
    [self.controller.councilAndYearLabel.text isEqualToString:@"Council and Year"];
    
    XCTAssertTrue(self.controller.councilAndYearLabel.hidden == NO);
    XCTAssertTrue(self.controller.noteLabel.hidden == YES);
    XCTAssertTrue(self.controller.moreButton.hidden == YES);
}

- (void)testPrepareForWikipediaSegue
{
    UIStoryboard *storybord = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    BPLWikipediaViewController *destinationViewController = [storybord instantiateViewControllerWithIdentifier:@"BPLWikipediaViewController"];
    
    UIStoryboardSegue *segue = [[UIStoryboardSegue alloc] initWithIdentifier:BPLWikipediaViewControllerSegue source:self.controller destination:destinationViewController];

    id controllerMock = OCMPartialMock(self.controller);
    OCMExpect([controllerMock buttonTappedForPlacemark:self.marker1 withAction:BPLWikipediaButtonPressedEvent]).andForwardToRealObject();
    
    [controllerMock prepareForSegue:segue sender:self.controller.wikipediaButton];
    
    OCMVerifyAll(controllerMock);
}

- (void)testPrepareForDetailChooserSegue
{
    UIStoryboard *storybord = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    BPLDetailChooserViewController *destinationViewController = [storybord instantiateViewControllerWithIdentifier:@"BPLDetailChooserViewController"];
    
    UIStoryboardSegue *segue = [[UIStoryboardSegue alloc] initWithIdentifier:BPLDetailChooserViewControllerSegue source:self.controller destination:destinationViewController];
    
    id controllerMock = OCMPartialMock(self.controller);
    OCMExpect([controllerMock buttonTappedForPlacemark:self.marker1 withAction:BPLDetailsButtonPressedEvent]).andForwardToRealObject();
    
    [controllerMock prepareForSegue:segue sender:self.controller.moreButton];
    
    OCMVerifyAll(controllerMock);
}

- (void)testPrepareForStreetMapSegue
{
    UIStoryboard *storybord = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    BPLStreetViewViewController *destinationViewController = [storybord instantiateViewControllerWithIdentifier:@"BPLStreetViewViewController"];
    
    UIStoryboardSegue *segue = [[UIStoryboardSegue alloc] initWithIdentifier:BPLStreetMapViewControllerSegue source:self.controller destination:destinationViewController];
    
    id controllerMock = OCMPartialMock(self.controller);
    OCMExpect([controllerMock buttonTappedForPlacemark:self.marker1 withAction:BPLStreetViewButtonPressedEvent]).andForwardToRealObject();
    
    [controllerMock prepareForSegue:segue sender:self.controller.streetButton];
    
    OCMVerifyAll(controllerMock);
}

- (void)testDirectionsButton
{
    id controllerMock = OCMPartialMock(self.controller);
    OCMExpect([controllerMock buttonTappedForPlacemark:self.marker1 withAction:BPLDirectionsButtonPressedEvent]).andForwardToRealObject();
    
    [controllerMock directionsButtonTapped:self.controller.directionsButton];
    
    OCMVerifyAll(controllerMock);
}

- (void)testDetailRowSelected
{
    BPLPlacemark *one = [BPLUnitTestHelper placemarkWithIdentifier:@"1"];
    BPLPlacemark *two = [BPLUnitTestHelper placemarkWithIdentifier:@"2"];
    BPLPlacemark *three = [BPLUnitTestHelper placemarkWithIdentifier:@"3"];
    
    self.controller.model.markers = @[one, two, three];
    
    NSNotification *notification = [[NSNotification alloc] initWithName:BPLDetailChooserViewControllerRowSelected object:@1 userInfo:@{}];
    
    [self.controller detailChooserViewControllerRowSelected:notification];
    
    BPLPlacemark *newFirstPlacemark = self.controller.model.markers[0];
    
    XCTAssertTrue([newFirstPlacemark isEqual:two]);
}

@end
