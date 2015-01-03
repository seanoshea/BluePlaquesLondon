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

#import "NSObject+BPLTracking.h"

#import <Crashlytics/Crashlytics.h>
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>

#import "BPLConfiguration.h"
#import "BPLConstants.h"

@implementation NSObject (BPLTracking)

- (void)trackCategory:(NSString *)category action:(NSString *)action label:(NSString *)label
{
    [self trackCategory:category action:action label:label value:nil];
}

- (void)trackCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value
{
    if ([BPLConfiguration isTrackingEnabled]) {
        id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:BPLTrackingKey];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category
                                                              action:action
                                                               label:label
                                                               value:value] build]];
        if ([BPLConfiguration isCrashReportingEnabled]) {
            static unsigned long long eventCount = 0;
            NSDictionary *parameters = @{
                                         @"category": category ?: @"",
                                         @"action": action ?: @"",
                                         @"label": label ?: @"",
                                         @"value": value ?: @""
                                         };
            Crashlytics *crashlytics = [Crashlytics sharedInstance];
            [crashlytics setObjectValue:parameters
                                 forKey:[action stringByAppendingFormat:@"-%llu", (unsigned long long)++eventCount]];
        }
    }
}

@end
