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

#import "BPLWikipediaViewModel.h"

#import "SimpleKMLPlacemark+Additions.h"

static NSString * const BPLWikipediaViewModelSearchURLFormat = @"http://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=%@&srprop=timestamp&format=json";
static NSString * const BPLWikipediaViewModelPageURLFormat = @"http://en.wikipedia.org/wiki/%@";

@interface BPLWikipediaViewModel()

@property (nonatomic) SimpleKMLPlacemark *placemark;

@end

@implementation BPLWikipediaViewModel

- (id)initWithPlacemark:(SimpleKMLPlacemark *)placemark
{
    self = [super init];
    if (self) {
        _placemark = placemark;
    }
    return self;
}

- (void)retrieveWikipediaUrlWithCompletionBlock:(BPLWikipediaViewURLResolutionCompletionBlock)completionBlock
{
    NSString *strUTF8 = [[NSString stringWithFormat:BPLWikipediaViewModelSearchURLFormat, self.placemark.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:strUTF8]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSError *error = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (!error) {
            NSArray *arr = json[@"query"][@"search"];
            if (arr.count) {
                NSString *title = arr[0][@"title"];
                NSString *urlString = [[NSString stringWithFormat:BPLWikipediaViewModelPageURLFormat, [title stringByReplacingOccurrencesOfString:@" " withString:@"_"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                if (completionBlock) {
                    completionBlock([NSURLRequest requestWithURL:[NSURL URLWithString:urlString]], error);
                }
            }
        }
    }];
}

@end
