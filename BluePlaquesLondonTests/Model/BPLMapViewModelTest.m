//
//  BPLMapViewModelTest.m
//  BluePlaquesLondon
//
//  Created by Sean O Shea on 2/25/15.
//  Copyright (c) 2015 Sean O'Shea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "BPLMapViewModel.h"
#import "OCMock.h"

@interface BPLMapViewModelTest : XCTestCase

@property (nonatomic) BPLMapViewModel *model;

@end

@interface BPLMapViewModel()

@property (nonatomic) KMLRoot *data;
@property (nonatomic, copy) NSMutableDictionary *coordinateToMarker;
@property (nonatomic, copy) NSMutableDictionary *keyToArrayPositions;

- (void)loadBluePlaquesData;

@end

@implementation BPLMapViewModelTest

- (void)setUp {
    [super setUp];
    self.model = [[BPLMapViewModel alloc] initWithKMLFileParsedCallback:^{
        
    }];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInitialisation {
    
    XCTAssertTrue(self.model.coordinateToMarker != nil);
    XCTAssertTrue(self.model.keyToArrayPositions != nil);
    XCTAssertTrue(self.model.massagedData != nil);
    XCTAssertTrue(self.model.kmlFileParsedCallback != nil);
}

@end
