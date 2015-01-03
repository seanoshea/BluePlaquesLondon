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

#import "BPLAppDelegate.h"

#import <GoogleMaps/GoogleMaps.h>
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <Crashlytics/Crashlytics.h>
#import "Reachability.h"
#import "iRate.h"

#import "BPLConfiguration.h"
#import "BPLConstants.h"
#import "UIColor+BPLColors.h"
#import "NSObject+BPLTracking.h"

typedef NS_ENUM(NSInteger, BPLViewControllerTabIndex) {
    BPLMapViewControllerIndex = 0,
    BPLAboutViewControllerIndex = 1,
};

@interface BPLAppDelegate() <iRateDelegate>

@property (nonatomic) Reachability *internetReach;

@end

@implementation BPLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initializeGoogleMapsApi];
    [self initializeStyling];
    [self initializeReachability];
    [self initializeLocalization];
    [self initializeTracking];
    [self initializeCrashReporting];
    [self initializeRating];
    return YES;
}

- (void)initializeGoogleMapsApi
{
    [GMSServices provideAPIKey:BPLMapsKey];
}

- (void)initializeStyling
{
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    tabBarController.tabBar.tintColor = [UIColor BPLBlueColour];
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

#pragma mark Reachability

- (void)initializeReachability
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.internetReach = [Reachability reachabilityForInternetConnection];
    [self.internetReach startNotifier];
}

- (BOOL)hasInternetConnection
{
    BOOL hasInternetConnection = NO;
    if (self.internetReach) {
        NetworkStatus netStatus = [self.internetReach currentReachabilityStatus];
        hasInternetConnection = netStatus != NotReachable;
    }
    return hasInternetConnection;
}

- (void)reachabilityChanged:(NSNotification *)notification
{
    // check to see whether the device was previously offline & whether the new reachability is online
    if (self.internetReach && [self.internetReach currentReachabilityStatus] != NotReachable) {
        [[NSNotificationCenter defaultCenter] postNotificationName:BPLNetworkAvailable object:nil];
    }
}

- (void)initializeLocalization
{
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
    if ([BPLConfiguration isTrackingEnabled]) {
        // don't bother sending analytics for debug builds.
        if ([BPLConfiguration isDebug]) {
            [GAI sharedInstance].dryRun = YES;
        }
        [GAI sharedInstance].dispatchInterval = 30;
        [[[GAI sharedInstance] logger] setLogLevel:[BPLConfiguration isDebug] ? kGAILogLevelVerbose : kGAILogLevelWarning];
        NSString *shortVersionString = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
        [self trackCategory:BPLApplicationLoaded action:[NSString stringWithFormat:@"Application Version: %@", shortVersionString] label:[NSString stringWithFormat:@"iOS Version %@", [[UIDevice currentDevice] systemVersion]]];
    }
}

- (void)initializeCrashReporting
{
    if ([BPLConfiguration isCrashReportingEnabled]) {
        [Crashlytics startWithAPIKey:BPLCrashReportingKey];
        [GAI sharedInstance].trackUncaughtExceptions = YES;
    }
}

- (void)initializeRating
{
    [iRate sharedInstance].delegate = self;
    [iRate sharedInstance].messageTitle = NSLocalizedString(@"Rate Blue Plaques London", nil);
    [iRate sharedInstance].message = NSLocalizedString(@"If you enjoy using this application, would you mind taking a moment to rate it?", nil);
    [iRate sharedInstance].applicationName = NSLocalizedString(@"Blue Plaques London", nil);
    [iRate sharedInstance].daysUntilPrompt = 5;
    [iRate sharedInstance].usesUntilPrompt = 15;
}

#pragma mark iRateDelegate

- (void)iRateUserDidAttemptToRateApp
{
    [self trackCategory:BPLUIActionCategory action:BPLRateAppButtonPressedEvent label:nil];
}

- (void)iRateUserDidDeclineToRateApp
{
    [self trackCategory:BPLUIActionCategory action:BPLDeclineRateAppButtonPressedEvent label:nil];
}

- (void)iRateUserDidRequestReminderToRateApp
{
    [self trackCategory:BPLUIActionCategory action:BPLRemindRateAppButtonPressedEvent label:nil];
}

- (void)iRateDidOpenAppStore
{
    [self trackCategory:BPLRateAppStoreOpened action:nil label:nil];
}

@end
