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

#import "KMLPlacemark+BPLAdditions.h"
#import <MapKit/MapKit.h>
#import "KML.h"
#import "NSString+BPLPlacemarkFeatureDescription.h"

static NSString *const BPLOverlayTitleDelimiter = @"<br>";
static NSString *const BPLNameDelimiter = @"(";
static NSString *const BPLEmphasisNoteOpeningTag = @"<em>";
static NSString *const BPLEmphasisNoteClosingTag = @"</em>";

@implementation KMLPlacemark (BPLAdditions)

- (NSString *)name
{
    return self.descriptionValue.name;
}

- (NSString *)title
{
    return self.descriptionValue.title;
}

- (NSString *)occupation
{
    return self.descriptionValue.occupation;
}

- (NSString *)address
{
    return self.descriptionValue.address;
}

- (NSString *)note
{
    return self.descriptionValue.note;
}

- (NSString *)councilAndYear
{
    return self.descriptionValue.councilAndYear;
}

- (NSString *)key
{
    KMLPoint *geometry = (KMLPoint *)self.geometry;
    return [NSString stringWithFormat:@"%.5f%.5f", geometry.coordinate.latitude, geometry.coordinate.longitude];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"name: %@ title: %@ occupation: %@ address: %@ note: %@ councilAndYear: %@", self.name, self.title, self.occupation, self.address, self.note, self.councilAndYear];
}

@end
