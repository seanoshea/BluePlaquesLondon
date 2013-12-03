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

#import "BPLConfiguration.h"

#import "NSUserDefaults+BPLState.h"

@implementation BPLConfiguration

+ (BOOL)isAnalyticsEnabled {
#ifdef ANALYTICS
    return [[NSUserDefaults standardUserDefaults] isTrackingEnabled];
#else
    return false;
#endif
}

+ (BOOL)isCrashReportingEnabled {
#ifdef CRASH_REPORTING
    return true;
#else
    return false;
#endif
}

+ (BOOL)isDebug {
#ifdef DEBUG
    return true;
#else
    return false;
#endif
}

@end