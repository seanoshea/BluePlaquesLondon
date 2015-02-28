//
//  UnitTestHelper.h
//  BluePlaquesLondon
//
//  Created by Sean O Shea on 2/28/15.
//  Copyright (c) 2015 Sean O'Shea. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BPLPlacemark.h"

@interface BPLUnitTestHelper : NSObject

+ (BPLPlacemark *)placemarkWithIdentifier:(NSString *)identifier;

@end
