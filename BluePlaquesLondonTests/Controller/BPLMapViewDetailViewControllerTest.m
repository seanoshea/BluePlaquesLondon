//
//  BPLMapViewDetailViewControllerTest.m
//  BluePlaquesLondon
//
//  Created by Sean O Shea on 2/26/15.
//  Copyright (c) 2015 Sean O'Shea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "BPLMapViewDetailViewController.h"
#import "BPLMapViewDetailViewModel.h"
#import "BPLLabel.h"
#import "BPLButton.h"
#import "BPLPlacemark.h"
#import "BPLUnitTestHelper.h"

@interface BPLMapViewDetailViewControllerTest : XCTestCase

@property (nonatomic) BPLMapViewDetailViewController *controller;

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

@end

@implementation BPLMapViewDetailViewControllerTest

- (void)setUp
{
    [super setUp];
    UIStoryboard *storybord = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    self.controller = [storybord instantiateViewControllerWithIdentifier:BPLMapViewDetailViewControllerStoryboardIdentifier];
    [self.controller view];

    BPLPlacemark *marker1 = [BPLUnitTestHelper placemarkWithIdentifier:@"1"];
    BPLMapViewDetailViewModel *model = [[BPLMapViewDetailViewModel alloc] init];
    model.markers = @[marker1];
    
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

@end
