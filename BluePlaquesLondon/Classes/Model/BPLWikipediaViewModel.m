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
