/*
 Copyright 2012 - 2014 Sean O' Shea
 
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

#import "BPLAppDelegate.h"

#import <GoogleMaps/GoogleMaps.h>
#import <Crashlytics/Crashlytics.h>
#import "Reachability.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

#import "BPLConfiguration.h"
#import "BPLConstants.h"
#import "UIColor+BluePlaquesLondon.h"

typedef NS_ENUM(NSInteger, BPLViewControllerTabIndex) {
    BPLMapViewControllerIndex = 0,
    BPLAboutViewControllerIndex = 1,
};

@interface BPLAppDelegate()

@property (nonatomic) Reachability *internetReach;

@end

@implementation BPLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initializeGoogleMapsApi];
    [self initializeStyling];
    [self initializeLogging];
    [self initializeReachability];
    [self initializeLocalization];
    [self initializeTracking];
    [self initializeCrashReporting];
    return YES;
}

- (void)initializeStyling
{
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    tabBarController.tabBar.selectedImageTintColor = [UIColor BPLBlueColour];
    [[UISearchBar appearance] setBarTintColor:[UIColor BPLGreyColour]];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor BPLBlueColour]];
    [[UILabel appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor BPLBlueColour]];
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage alloc]];
    [[UITabBarItem appearance] setTitleTextAttributes:
     @{ NSForegroundColorAttributeName: [UIColor BPLBlueColour],
        NSFontAttributeName: [UIFont preferredFontForTextStyle: UIFontTextStyleCaption2]}
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:
     @{ NSForegroundColorAttributeName: [UIColor BPLBlueColour],
        NSFontAttributeName: [UIFont preferredFontForTextStyle: UIFontTextStyleCaption2]}
                                             forState:UIControlStateSelected];
    self.window.tintColor = [UIColor BPLBlueColour];
}

- (void)initializeLogging
{
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    NSString *productName =  [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
    NSString *shortVersionString = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    DDLogInfo(@"Application Loaded");
    DDLogInfo(@"%@ v%@", productName, shortVersionString);
}

#pragma mark Reachability

- (void)initializeReachability
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.internetReach = [Reachability reachabilityForInternetConnection];
    [self.internetReach startNotifier];
}

- (BOOL)hasInternetConnection {
    BOOL hasInternetConnection = NO;
    if (self.internetReach) {
        NetworkStatus netStatus = [self.internetReach currentReachabilityStatus];
        hasInternetConnection = netStatus != NotReachable;
    }
    return hasInternetConnection;
}

- (void)reachabilityChanged:(NSNotification *)notification {
    // check to see whether the device was previously offline & whether the new reachability is online
    if (self.internetReach && [self.internetReach currentReachabilityStatus] != NotReachable) {
        DDLogInfo(@"Reachability changed back to reachable");
        [[NSNotificationCenter defaultCenter] postNotificationName:BPLNetworkAvailable object:nil];
    }
}

- (void)initializeLocalization {
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    NSArray *viewControllers = tabBarController.viewControllers;
    // Ensure each view controller has a unique identifier
    for (int i = 0; i < viewControllers.count; i++) {
        UIViewController *viewController = viewControllers[i];
        viewController.view.tag = i;
    }
    // Localize the tab names (they're stored in the storyboards)
    NSArray *items = tabBarController.tabBar.items;
    for (int i = 0; i < items.count; i++) {
        UITabBarItem *item = items[i];
        NSString *title;
        switch (i) {
            case BPLMapViewControllerIndex: {
                title = NSLocalizedString(@"Map", @"");
            } break;
            case BPLAboutViewControllerIndex: {
                title = NSLocalizedString(@"About", @"");
            } break;
            default:
                break;
        }
        item.title = title;
    }
}

- (void)initializeTracking
{
    if ([BPLConfiguration isAnalyticsEnabled]) {
        NSString *shortVersionString = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
        [GAI sharedInstance].trackUncaughtExceptions = YES;
        [GAI sharedInstance].dispatchInterval = 20;
        [[[GAI sharedInstance] logger] setLogLevel:[BPLConfiguration isDebug] ? kGAILogLevelVerbose : kGAILogLevelWarning];
        id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:BPLAnalyticsKey];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:BPLApplicationLoaded
                                                              action:[NSString stringWithFormat:@"Application Version: %@", shortVersionString]
                                                               label:[NSString stringWithFormat:@"iOS Version %@", [[UIDevice currentDevice] systemVersion]]
                                                               value:nil] build]];
    }
}

- (void)initializeCrashReporting
{
    if ([BPLConfiguration isCrashReportingEnabled]) {
        [Crashlytics startWithAPIKey:BPLCrashReportingKey];
    }
}

- (void)initializeGoogleMapsApi
{
    [GMSServices provideAPIKey:BPLMapsKey];
}

@end
