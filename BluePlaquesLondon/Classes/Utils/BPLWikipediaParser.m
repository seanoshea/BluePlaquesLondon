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

#import "BPLWikipediaParser.h"

struct BPLWikipediaParserStrings {
    __unsafe_unretained NSString *pageUrlFormat;
    __unsafe_unretained NSString *search;
    __unsafe_unretained NSString *query;
    __unsafe_unretained NSString *title;
    __unsafe_unretained NSString *domain;
};

static const struct BPLWikipediaParserStrings BPLWikipediaParserStrings = {
    .pageUrlFormat = @"https://en.wikipedia.org/wiki/%@",
    .search = @"search",
    .query = @"query",
    .title = @"title",
    .domain = @"BPLWikipediaParserStringsErrorDomain",
};

@implementation BPLWikipediaParser

+ (void)parseWikipediaData:(NSData *)data error:(NSError *)error name:(NSString *)name completionBlock:(BPLWikipediaViewURLResolutionCompletionBlock)completionBlock
{
    NSParameterAssert(completionBlock != nil);
    if (!error) {
        NSError *jsonParsingError = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonParsingError];
        if (!jsonParsingError) {
            NSArray *searchResults = json[BPLWikipediaParserStrings.query][BPLWikipediaParserStrings.search];
            if (searchResults.count) {
                __block NSString *title = [BPLWikipediaParser iterateOverSearchResults:searchResults forTitleWithName:name];
                NSString *urlString = [[NSString stringWithFormat:BPLWikipediaParserStrings.pageUrlFormat, [title stringByReplacingOccurrencesOfString:@" " withString:@"_"]] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                completionBlock([NSURLRequest requestWithURL:[NSURL URLWithString:urlString]], error);
            } else {
                NSError *error = [[NSError alloc] initWithDomain:BPLWikipediaParserStrings.domain code:404 userInfo:nil];
                completionBlock(nil, error);
            }
        } else {
            completionBlock(nil, jsonParsingError);
        }
    }  else {
        completionBlock(nil, error);
    }
}

+ (NSString *)iterateOverSearchResults:(NSArray *)searchResults forTitleWithName:(NSString *)name
{
    __block NSString *title;
    __block NSString *searchResultTitle;
    // see if we can guestimate the result
    [searchResults enumerateObjectsUsingBlock:^(NSDictionary  * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        searchResultTitle = obj[BPLWikipediaParserStrings.title];
        NSArray *titleComponents = [searchResultTitle componentsSeparatedByString:@" "];
        if (titleComponents.count) {
            if ([name rangeOfString:titleComponents[0] options:NSCaseInsensitiveSearch].location != NSNotFound) {
                title = searchResultTitle;
                *stop = true;
            }
        }
    }];
    if (title == nil) {
        // just take the first one
        title = searchResults[0][BPLWikipediaParserStrings.title];
    }
    return title;
}

@end
