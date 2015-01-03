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

#import "BPLWikipediaViewModel.h"

static NSString * const BPLWikipediaViewModelSearchURLFormat = @"http://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=%@&srprop=timestamp&format=json";
static NSString * const BPLWikipediaViewModelPageURLFormat = @"http://en.wikipedia.org/wiki/%@";

@interface BPLWikipediaViewModel()

@property (nonatomic, copy) NSString *name;

@end

@implementation BPLWikipediaViewModel

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
    NSString *encodedURLString = [[NSString stringWithFormat:BPLWikipediaViewModelSearchURLFormat, self.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:encodedURLString]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSError *error = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (!error) {
                NSArray *searchResults = json[@"query"][@"search"];
                if (searchResults.count) {
                    // take the first result ...
                    NSString *title = searchResults[0][@"title"];
                    NSString *urlString = [[NSString stringWithFormat:BPLWikipediaViewModelPageURLFormat, [title stringByReplacingOccurrencesOfString:@" " withString:@"_"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    if (completionBlock) {
                        completionBlock([NSURLRequest requestWithURL:[NSURL URLWithString:urlString]], error);
                    }
                }
            }
        }
    }];
}

@end
