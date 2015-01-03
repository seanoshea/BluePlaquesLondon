/*
 Copyright 2013 - 2015 Sean O'Shea
 
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

#import "BPLPlacemark+Additions.h"

#import "NSString+BPLPlacemarkFeatureDescription.h"

static NSString *const BPLOverlayTitleDelimiter = @"<br>";
static NSString *const BPLNameDelimiter = @"(";
static NSString *const BPLEmphasisNoteOpeningTag = @"<em>";
static NSString *const BPLEmphasisNoteClosingTag = @"</em>";

@implementation BPLPlacemark (Additions)

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
}

- (NSString *)placemarkName
{
    return self.featureDescription.name;
}

- (NSString *)placemarkTitle
{
    return self.featureDescription.title;
}

- (NSString *)occupation
{
    return self.featureDescription.occupation;
}

- (NSString *)address
{
    return self.featureDescription.address;
}

- (NSString *)note
{
    return self.featureDescription.note;
}

- (NSString *)councilAndYear
{
    return  self.featureDescription.councilAndYear;
}

- (NSString *)key
{
    return [NSString stringWithFormat:@"%.5f%.5f", self.coordinate.latitude, self.coordinate.longitude];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"name: %@ title: %@ occupation: %@ address: %@ note: %@ councilAndYear: %@", self.placemarkName, self.placemarkTitle, self.occupation, self.address, self.note, self.councilAndYear];
}

@end
