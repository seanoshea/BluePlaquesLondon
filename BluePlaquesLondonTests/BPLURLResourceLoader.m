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

#import "BPLURLResourceLoader.h"

static NSDictionary *responses;

@implementation BPLURLResourceLoader

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if (!responses) {
        responses = @{ @"https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=Churchill,%20Winston&srprop=timestamp&format=json": @"wikipedia.json" };
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
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:fileName.stringByDeletingPathExtension ofType:fileName.pathExtension]];
    
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
