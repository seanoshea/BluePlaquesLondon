/*
 Copyright (c) 2014 - present Upwards Northwards Software Limited
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

/**
 * Completion block type for Wikipedia URL resolution.
 * @param urlRequest The resolved URL request for the Wikipedia article, or nil if failed
 * @param error Error object if the resolution failed, or nil if successful
 */
typedef void(^BPLWikipediaViewURLResolutionCompletionBlock)(NSURLRequest *urlRequest, NSError *error);

/**
 * View model that handles Wikipedia article search and URL resolution.
 * Searches for Wikipedia articles based on person names and provides URL requests for web view loading.
 */
@interface BPLWikipediaViewModel : NSObject

/**
 * Designated initializer that creates a view model for the specified person.
 * @param name The name of the person to search for on Wikipedia
 * @return Initialized BPLWikipediaViewModel instance
 */
- (instancetype)initWithName:(NSString *)name NS_DESIGNATED_INITIALIZER;

/**
 * Searches Wikipedia for articles related to the person and returns a URL request.
 * @param completionBlock Block to execute when the search completes
 * @return NSURLSessionDataTask for the Wikipedia search request
 */
- (NSURLSessionDataTask *)retrieveWikipediaUrlWithCompletionBlock:(BPLWikipediaViewURLResolutionCompletionBlock)completionBlock;

@end
