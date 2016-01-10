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

#import "BPLWikipediaViewModel.h"

struct BPLWikipediaViewModelStrings {
    __unsafe_unretained NSString *searchUrlFormat;
    __unsafe_unretained NSString *pageUrlFormat;
    __unsafe_unretained NSString *query;
    __unsafe_unretained NSString *search;
    __unsafe_unretained NSString *title;
};

static const struct BPLWikipediaViewModelStrings BPLWikipediaViewModelStrings = {
    .searchUrlFormat = @"https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=%@&srprop=timestamp&format=json",
    .pageUrlFormat = @"https://en.wikipedia.org/wiki/%@",
    .query = @"query",
    .search = @"search",
    .title = @"title",
};

@interface BPLWikipediaViewModel()

@property (nonatomic, copy) NSString *name;

@end

@implementation BPLWikipediaViewModel

- (instancetype)init
{
    return [self initWithName:@""];
}

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _name = [name copy];
    }
    return self;
}

- (void)retrieveWikipediaUrlWithCompletionBlock:(BPLWikipediaViewURLResolutionCompletionBlock)completionBlock
{
    NSString *encodedURLString = [[NSString stringWithFormat:BPLWikipediaViewModelStrings.searchUrlFormat, self.name] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate:nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:encodedURLString]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSError *jsonParsingError = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonParsingError];
            if (!jsonParsingError) {
                NSArray *searchResults = json[BPLWikipediaViewModelStrings.query][BPLWikipediaViewModelStrings.search];
                if (searchResults.count) {
                    // take the first result ...
                    NSString *title = searchResults[0][BPLWikipediaViewModelStrings.title];
                    NSString *urlString = [[NSString stringWithFormat:BPLWikipediaViewModelStrings.pageUrlFormat, [title stringByReplacingOccurrencesOfString:@" " withString:@"_"]] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                    if (completionBlock) {
                        completionBlock([NSURLRequest requestWithURL:[NSURL URLWithString:urlString]], error);
                    }
                }
            }
        }
    }];
    [dataTask resume];
}

@end
