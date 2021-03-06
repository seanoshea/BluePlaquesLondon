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

#import "BPLAppDelegate.h"

#import <GoogleMaps/GoogleMaps.h>
#import <GoogleAnalytics/GAI.h>
#import <GoogleAnalytics/GAIDictionaryBuilder.h>
#import <GoogleAnalytics/GAIFields.h>

#import "Reachability.h"

#import "BPLConfiguration.h"
#import "BPLConstants.h"
#import "UIColor+BPLColors.h"
#import "NSObject+BPLTracking.h"
#import "BPLMapViewController.h"
#import "MDCTypography.h"

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
  [self initializeReachability];
  [self initializeTracking];
  [self initializeCrashReporting];
  return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  BOOL canHandle = NO;
  NSURLComponents *components = [NSURLComponents componentsWithString:url.absoluteString];
  canHandle = [components.scheme caseInsensitiveCompare:BPLApplicationURLSchemeIdentifier] == NSOrderedSame;
  if (canHandle) {
    [self openAppAtClosestPlacemark];
  }
  return canHandle;
}

- (void)initializeGoogleMapsApi
{
  [GMSServices provideAPIKey:BPLMapsKey];
}

- (void)initializeStyling
{
  [[UINavigationBar appearance] setBarTintColor:[UIColor BPLLightGreyColour]];
  [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                         NSForegroundColorAttributeName: [UIColor BPLBlueColour],
                                                         NSFontAttributeName: [MDCTypography subheadFont]
                                                         }];
  [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(5, 0)
                                                       forBarMetrics:UIBarMetricsDefault];
  
  [[UIBarButtonItem appearance] setTitleTextAttributes:@{
                                                         NSForegroundColorAttributeName: [UIColor BPLBlueColour],
                                                         NSFontAttributeName: [MDCTypography subheadFont]
                                                         } forState:UIControlStateNormal];
  
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
  
}

- (void)initializeTracking
{
  if ([BPLConfiguration isTrackingEnabled]) {
    // don't bother sending analytics for debug builds.
    if ([BPLConfiguration isDebug]) {
      [GAI sharedInstance].dryRun = YES;
    }
    [GAI sharedInstance].dispatchInterval = 30;
    [GAI sharedInstance].logger.logLevel = [BPLConfiguration isDebug] ? kGAILogLevelVerbose : kGAILogLevelWarning;
    NSString *shortVersionString = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    [self trackCategory:BPLApplicationLoaded action:[NSString stringWithFormat:@"Application Version: %@", shortVersionString] label:[NSString stringWithFormat:@"iOS Version %@", [UIDevice currentDevice].systemVersion]];
  }
}

- (void)initializeCrashReporting
{
#ifndef DEBUG
  if ([BPLConfiguration isCrashReportingEnabled]) {
    [GAI sharedInstance].trackUncaughtExceptions = YES;
  }
#endif
}

- (void)openAppAtClosestPlacemark {
  [self trackCategory:BPLUIActionCategory action:BPLTodayExtensionButtonPressed label:nil];
  // ensure that the map tab is selected
  UINavigationController *mapViewNavigationController = (UINavigationController *)self.window.rootViewController;
  [mapViewNavigationController popToRootViewControllerAnimated:NO];
  BPLMapViewController *mapViewController = mapViewNavigationController.viewControllers[0];
  [mapViewController navigateToClosestPlacemark];
}

@end
