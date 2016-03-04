/*
 Copyright (c) 2014 - 2015 Upwards Northwards Software Limited
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 1. Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 3. All advertising materials mentioning features or use of this software
 must display the following acknowledgement:
 This product includes software developed by Upwards Northwards Software Limited.
 4. Neither the name of Upwards Northwards Software Limited nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY UPWARDS NORTHWARDS SOFTWARE LIMITED ''AS IS'' AND ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL UPWARDS NORTHWARDS SOFTWARE LIMITED BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "NSString+BPLPlacemarkFeatureDescription.h"

#import "GTMNSString+HTML.h"

static NSString *const BPLOverlayTitleDelimiter = @"<br>";
static NSString *const BPLNameDelimiter = @"(";
static NSString *const BPLEmphasisNoteOpeningTag = @"<em>";
static NSString *const BPLEmphasisNoteClosingTag = @"</em>";

@implementation NSString (BPLPlacemarkFeatureDescription)

- (NSString *)name
{
    NSString *name = self.title;
    NSRange startOfYears = [name rangeOfString:BPLNameDelimiter];
    if (startOfYears.location != NSNotFound) {
        name = [name stringByReplacingOccurrencesOfString:BPLEmphasisNoteOpeningTag withString:@""];
        name = [name stringByReplacingOccurrencesOfString:BPLEmphasisNoteClosingTag withString:@""];
        name = [name substringToIndex:startOfYears.location];
    }
    return [NSString trimWhitespaceFromString:name];
}

- (NSString *)title
{
    NSString *title = self;
    
    NSUInteger location = [self rangeOfString:BPLOverlayTitleDelimiter].location;
    if (location != NSNotFound) {
        title = [self substringWithRange:NSMakeRange(0, location)];
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:title];
    NSString *strippedString = nil;
    if (![scanner scanUpToString:BPLEmphasisNoteOpeningTag intoString:&strippedString]) {
        strippedString = title;
    }
    
    return [NSString trimWhitespaceFromString:title];
}

- (NSString *)occupation
{
    NSString *occupation = self;
    NSUInteger location = [self rangeOfString:BPLOverlayTitleDelimiter].location;
    if (location != NSNotFound) {
        occupation = [self substringFromIndex:location];
        NSRange startRange = [occupation rangeOfString:BPLOverlayTitleDelimiter options:NSCaseInsensitiveSearch range:NSMakeRange(0, occupation.length - 1)];
        if (startRange.location == 0) {
            NSUInteger delimiterLength = BPLOverlayTitleDelimiter.length;
            NSRange endRange = [occupation rangeOfString:BPLOverlayTitleDelimiter options:NSCaseInsensitiveSearch range:NSMakeRange(delimiterLength, occupation.length - delimiterLength - 1)];
            occupation = [occupation substringWithRange:NSMakeRange(delimiterLength, endRange.location - delimiterLength)];
            // check to see whether we have a valid occupation here or if this is actually a date range
            if ([NSString trimWhitespaceFromString:occupation].length == 9) {
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[0-9]{4}-[0-9]{4}" options:0 error:nil];
                NSTextCheckingResult *match = [regex firstMatchInString:occupation options:0 range:NSMakeRange(0, occupation.length)];
                if (match.range.location != NSNotFound) {
                    NSArray *components = [self componentsSeparatedByString:BPLOverlayTitleDelimiter];
                    if (components.count && components.count > 3) {
                        occupation = [NSString trimWhitespaceFromString:components[2]];
                    }
                }
            }
        }
        
    }
    return [NSString trimWhitespaceFromString:occupation];
}

- (NSString *)address
{
    NSString *address;
    NSArray *components = [self componentsSeparatedByString:BPLOverlayTitleDelimiter];
    if (components.count) {
        switch (components.count) {
            case 2:
            case 3:{
                address = [NSString trimWhitespaceFromString:components[1]];
            } break;
            case 4:
            case 5: {
                address = [NSString trimWhitespaceFromString:components[2]];
            } break;
            case 6: {
                address = [NSString trimWhitespaceFromString:components[3]];
            } break;
            case 7: {
                address = [NSString trimWhitespaceFromString:components[4]];
            } break;
            default:
                break;
        }
    }
    return address;
}

- (NSString *)note
{
    NSString *note;
    NSRange startOfEmphasis = [self rangeOfString:BPLEmphasisNoteOpeningTag];
    if (startOfEmphasis.location != NSNotFound) {
        NSRange endOfEmphasis = [self rangeOfString:BPLEmphasisNoteClosingTag];
        if (endOfEmphasis.location == NSNotFound) {
            // some notes don't have the correct closing tag ... search for the starting tag again
            NSUInteger locationOfLastEmphasis = [self rangeOfString:BPLEmphasisNoteOpeningTag options:NSBackwardsSearch].location;
            if (locationOfLastEmphasis != startOfEmphasis.location) {
                endOfEmphasis.location = self.length - BPLEmphasisNoteOpeningTag.length;
            } else {
                endOfEmphasis.location = self.length;
            }
        }
        note = [self substringWithRange:NSMakeRange(startOfEmphasis.location + BPLEmphasisNoteOpeningTag.length, endOfEmphasis.location - startOfEmphasis.location - BPLEmphasisNoteClosingTag.length + 1)];
        note = [NSString trimWhitespaceFromString:note];
    }
    return note;
}

- (NSString *)councilAndYear
{
    NSString *councilAndYear;
    NSString *withoutNote = [self removeNoteFromString:self];
    NSArray *components = [withoutNote componentsSeparatedByString:BPLOverlayTitleDelimiter];
    if (components.count && components.count > 2) {
        councilAndYear = [NSString trimWhitespaceFromString:components.lastObject];
    }
    return councilAndYear;
}

- (NSString *)removeNoteFromString:(NSString *)input
{
    NSString *note = self.note;
    if (note.length) {
        input = [NSString trimWhitespaceFromString:input];
        input = [input stringByReplacingOccurrencesOfString:BPLEmphasisNoteOpeningTag withString:@""];
        input = [input stringByReplacingOccurrencesOfString:note withString:@""];
        input = [input stringByReplacingOccurrencesOfString:BPLEmphasisNoteClosingTag withString:@""];
        // check for a trailing delimiter
        NSUInteger locationOfFinalDelimiter = [input rangeOfString:BPLOverlayTitleDelimiter options:NSBackwardsSearch].location;
        if (locationOfFinalDelimiter != NSNotFound && locationOfFinalDelimiter == input.length - BPLOverlayTitleDelimiter.length) {
            input = [input substringToIndex:locationOfFinalDelimiter];
        }
    }
    return input;
}

+ (NSString *)trimWhitespaceFromString:(NSString *)input
{
    input = [input stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    input = [input stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange range = [input rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
    return [[input stringByReplacingCharactersInRange:range withString:@""] gtm_stringByUnescapingFromHTML];
}

@end
