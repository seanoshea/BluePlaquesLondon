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

@implementation NSString (MapOverlayAdditions)

- (NSString *)overlayTitle
{
    NSString *title = self;
    
    static NSArray *HTMLElementsToBeStripped;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        HTMLElementsToBeStripped = @[@"<em>", @"</em>"];
    });
    
    int location = [self rangeOfString:BPLOverlayTitleDelimiter].location;
    if (location != NSNotFound) {
        title = [self substringWithRange:NSMakeRange(0, location)];
    }
    
    for (NSString *element in HTMLElementsToBeStripped) {
        title = [title stringByReplacingOccurrencesOfString:element withString:@""];
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

+ (NSString *)trimWhitespaceFromString:(NSString *)input
{
    input = [input stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    return [input stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
