/*
 Copyright 2012 - 2013 UpwardsNorthwards
 
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

#import "SimpleKMLPlacemark+Additions.h"

#import "NSString+MapOverlayAdditions.h"
#import "SimpleKMLPoint.h"

static NSString *const BPLOverlayTitleDelimiter = @"<br>";
static NSString *const BPLEmphasisNoteOpeningTag = @"<em>";
static NSString *const BPLEmphasisNoteClosingTag = @"</em>";

@implementation SimpleKMLPlacemark (Additions)

- (NSString *)title
{
    NSString *title = self.featureDescription;
    
    int location = [self.featureDescription rangeOfString:BPLOverlayTitleDelimiter].location;
    if (location != NSNotFound) {
        title = [self.featureDescription substringWithRange:NSMakeRange(0, location)];
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:title];
    NSString *strippedString = nil;
    if (![scanner scanUpToString:BPLEmphasisNoteOpeningTag intoString:&strippedString]) {
        strippedString = title;
    }
    
    return [NSString trimWhitespaceFromString:title];
}

- (NSString *)subtitle
{
    NSString *subtitle = self.featureDescription;
    int location = [self.featureDescription rangeOfString:BPLOverlayTitleDelimiter].location;
    if (location != NSNotFound) {
        subtitle = [self.featureDescription substringFromIndex:location];
        subtitle = [self removeNoteFromString:subtitle];
        if (self.councilAndYear) {
            subtitle = [subtitle stringByReplacingOccurrencesOfString:self.councilAndYear withString:@""];
        }
    }
    return [NSString trimWhitespaceFromString:[subtitle stringByReplacingOccurrencesOfString:BPLOverlayTitleDelimiter withString:@" "]];
}

- (NSString *)occupation
{
    NSString *occupation = self.featureDescription;
    int location = [self.featureDescription rangeOfString:BPLOverlayTitleDelimiter].location;
    if (location != NSNotFound) {
        occupation = [self.featureDescription substringFromIndex:location];
        NSRange startRange = [occupation rangeOfString:BPLOverlayTitleDelimiter options:NSCaseInsensitiveSearch range:NSMakeRange(0, occupation.length - 1)];
        if (startRange.location == 0) {
            int delimiterLength = BPLOverlayTitleDelimiter.length;
            NSRange endRange = [occupation rangeOfString:BPLOverlayTitleDelimiter options:NSCaseInsensitiveSearch range:NSMakeRange(delimiterLength, occupation.length - delimiterLength - 1)];
            occupation = [occupation substringWithRange:NSMakeRange(delimiterLength, endRange.location - delimiterLength)];
        }
        
    }
    return [NSString trimWhitespaceFromString:occupation];
}

- (NSString *)address
{
    NSString *address;
    NSArray *components = [self.featureDescription componentsSeparatedByString:BPLOverlayTitleDelimiter];
    if (components.count && components.count > 3) {
        address = [NSString trimWhitespaceFromString:components[2]];
    }
    return address;
}

- (NSString *)note
{
    NSString *note;
    NSRange startOfEmphasis = [self.featureDescription rangeOfString:BPLEmphasisNoteOpeningTag];
    if (startOfEmphasis.location != NSNotFound) {
        NSRange endOfEmphasis = [self.featureDescription rangeOfString:BPLEmphasisNoteClosingTag];
        if (endOfEmphasis.location == NSNotFound) {
            endOfEmphasis.location = self.featureDescription.length;
        }
        note = [self.featureDescription substringWithRange:NSMakeRange(startOfEmphasis.location + BPLEmphasisNoteOpeningTag.length, endOfEmphasis.location - startOfEmphasis.location - BPLEmphasisNoteClosingTag.length + 1)];
        note = [NSString trimWhitespaceFromString:note];
    }
    return note;
}

- (NSString *)councilAndYear
{
    NSString *councilAndYear;
    
    NSString *description = description = [self removeNoteFromString:self.featureDescription];
    NSArray *components = [description componentsSeparatedByString:BPLOverlayTitleDelimiter];
    if (components.count && components.count > 4) {
        councilAndYear = [NSString trimWhitespaceFromString:components[components.count - 1]];
    }
    
    return councilAndYear;
}

- (NSString *)council
{
    return [self extractStringComponentAtPosition:0];
}

- (NSString *)yearErrected
{
    return [self extractStringComponentAtPosition:1];
}

- (NSString *)extractStringComponentAtPosition:(NSInteger)position
{
    NSString *extractedString;
    NSString *councilAndYear = self.councilAndYear;
    if (councilAndYear) {
        NSMutableArray *components = [[councilAndYear componentsSeparatedByString:@" "] mutableCopy];
        if (components.count > position) {
            if (position == 0) {
                [components removeObject:components.lastObject];
                extractedString = [components componentsJoinedByString:@" "];
            } else {
                extractedString = components.lastObject;
            }
        }
    }
    return extractedString;
}

- (NSString *)removeNoteFromString:(NSString *)input
{
    NSString *note = self.note;
    if (note) {
        input = [input stringByReplacingOccurrencesOfString:BPLEmphasisNoteOpeningTag withString:@""];
        input = [input stringByReplacingOccurrencesOfString:note withString:@""];
        input = [input stringByReplacingOccurrencesOfString:BPLEmphasisNoteClosingTag withString:@""];
    }
    return input;
}

- (NSString *)key
{
    return [NSString stringWithFormat:@"%.12f%.12f", self.point.coordinate.latitude, self.point.coordinate.longitude];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"title: %@ subtitle: %@ occupation: %@ address: %@ note: %@", self.title, self.subtitle, self.occupation, self.address, self.note];
}

@end
