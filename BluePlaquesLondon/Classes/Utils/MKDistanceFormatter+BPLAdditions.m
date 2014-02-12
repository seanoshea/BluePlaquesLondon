/*
 Copyright 2013 - 2014 Sean O' Shea
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "MKDistanceFormatter+BPLAdditions.h"

@implementation MKDistanceFormatter (BPLAdditions)

+ (NSString *)distanceFromLocation:(CLLocation *)location toLocation:(CLLocation *)toLocation
{    
    CLLocationDistance distance = [location distanceFromLocation:toLocation];
    static MKDistanceFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[MKDistanceFormatter alloc] init];
        formatter.units = MKDistanceFormatterUnitsMetric;
    });
    return [formatter stringFromDistance:distance];
}

@end
