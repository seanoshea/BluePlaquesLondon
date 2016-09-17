//
//  UnitTestHelper.m
//  BluePlaquesLondon
//
//  Created by Sean O Shea on 2/28/15.
//  Copyright (c) 2015 Sean O'Shea. All rights reserved.
//

#import "BPLUnitTestHelper.h"

@class BPLPlacemark;

@implementation BPLUnitTestHelper

+ (BPLPlacemark *)placemarkWithIdentifier:(NSString *)identifier {
  BPLPlacemark *placemark = [[BPLPlacemark alloc] init];
  placemark.featureDescription = [NSString stringWithFormat:@"Feature Description %@", identifier];
  placemark.name = [NSString stringWithFormat:@"Name %@", identifier];
  placemark.title = [NSString stringWithFormat:@"Title %@", identifier];
  placemark.styleUrl = [NSString stringWithFormat:@"Style URL %@", identifier];
  placemark.longitude = @(0);
  placemark.latitude = @(1);
  placemark.placemarkPinType = @(1);
  return placemark;
}

@end
