/*
 Copyright 2013 - 2014 Sean O' Shea
 
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

#import "BPLURLResourceLoader.h"

static NSDictionary *responses;

@implementation BPLURLResourceLoader

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if (!responses) {
        responses = @{ @"http://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=CHURCHILL,%20Sir%20Winston,%20KG&srprop=timestamp&format=json": @"wikipedia.json" };
    }
    return responses[request.URL.absoluteString] != nil;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (NSCachedURLResponse *)cachedResponse
{
	return nil;
}

- (void)startLoading
{
    NSString *fileName = responses[self.request.URL.absoluteString];
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:[fileName stringByDeletingPathExtension] ofType:[fileName pathExtension]]];
    
    NSURLResponse *response = [[NSURLResponse alloc] initWithURL:self.request.URL
                                                        MIMEType:@"text/json"
                                           expectedContentLength:data.length
                                                textEncodingName:@"UTF8"];
    [self.client URLProtocol:self
          didReceiveResponse:response
          cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    
    
    [self.client URLProtocol:self didLoadData:data];
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading
{    
    [self.client URLProtocolDidFinishLoading:self];
}

@end
