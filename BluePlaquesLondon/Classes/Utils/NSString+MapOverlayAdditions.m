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

#import "NSString+MapOverlayAdditions.h"

#import "GTMNSString+HTML.h"

static NSString *const BPLOverlayTitleDelimiter = @"<br>";
static NSString *const BPLEmphasisNoteOpeningTag = @"<em>";
static NSString *const BPLEmphasisNoteClosingTag = @"</em>";

@implementation NSString (MapOverlayAdditions)

- (NSString *)overlayTitle
{
    NSString *title = self;
    
    int location = [self rangeOfString:BPLOverlayTitleDelimiter].location;
    if (location != NSNotFound) {
        title = [self substringWithRange:NSMakeRange(0, location)];
    }

    NSScanner *scanner = [NSScanner scannerWithString:title];
    NSString *strippedString = nil;
    if (![scanner scanUpToString:BPLEmphasisNoteOpeningTag intoString:&strippedString]) {
        strippedString = title;
    }
    
    return [[NSString trimWhitespaceFromString:title] gtm_stringByUnescapingFromHTML];
}

- (NSString *)overlaySubtitle
{
    NSString *subtitle = self;
    int location = [self rangeOfString:BPLOverlayTitleDelimiter].location;
    if (location != NSNotFound) {
        subtitle = [self substringFromIndex:location];
    }
    subtitle = [subtitle stringByReplacingOccurrencesOfString:BPLOverlayTitleDelimiter withString:@" "];
    return [[NSString trimWhitespaceFromString:subtitle] gtm_stringByUnescapingFromHTML];
}

- (NSString *)occupation
{
    NSString *occupation = self;
    int location = [self rangeOfString:BPLOverlayTitleDelimiter].location;
    if (location != NSNotFound) {
        occupation = [self substringFromIndex:location];
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
    NSArray *components = [self componentsSeparatedByString:BPLOverlayTitleDelimiter];
    if (components.count && components.count > 3) {
        address = [NSString trimWhitespaceFromString:components[2]];
    }
    return address;
}

- (NSString *)note
{
    NSString *note;
    NSRange startOfEmphasis = [self rangeOfString:BPLEmphasisNoteOpeningTag];
    if (startOfEmphasis.location != NSNotFound) {
        NSRange endOfEmphasis = [self rangeOfString:BPLEmphasisNoteClosingTag];
        note = [self substringWithRange:NSMakeRange(startOfEmphasis.location + BPLEmphasisNoteOpeningTag.length, endOfEmphasis.location - startOfEmphasis.location - BPLEmphasisNoteClosingTag.length + 1)];
        note = [NSString trimWhitespaceFromString:note];
    }
    return note;
}

+ (NSString *)trimWhitespaceFromString:(NSString *)input
{
    input = [input stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    input = [input stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange range = [input rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
    return [input stringByReplacingCharactersInRange:range withString:@""];
}

@end
