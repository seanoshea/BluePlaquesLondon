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

#import "BPLStreetViewViewController.h"

#import <GoogleMaps/GoogleMaps.h>

#import "NSObject+BPLTracking.h"
#import "BPLConstants.h"
#import "BPLPlacemark+Additions.h"

@interface BPLStreetViewViewController() <GMSPanoramaViewDelegate>

@property (nonatomic, copy) NSString *firstPanoramaId;
@property (nonatomic, strong) GMSPanoramaService *panoramaService;

@end

@implementation BPLStreetViewViewController

#pragma mark Properties

- (NSString *)screenName
{
  return @"Street View Screen";
}

#pragma mark Lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  // screenName removed with Google Analytics
  self.title = NSLocalizedString(@"Street View", nil);

  // Create panorama view with explicit frame
  self.panoramaView = [[GMSPanoramaView alloc] initWithFrame:self.view.bounds];
  self.panoramaView.delegate = self;
  self.panoramaView.translatesAutoresizingMaskIntoConstraints = NO;

  // Add the panorama view as a subview to fill the current view
  [self.view addSubview:self.panoramaView];

  // Use Auto Layout constraints to fill the entire container
  [self.view addConstraints:@[
    [NSLayoutConstraint constraintWithItem:self.panoramaView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0],
    [NSLayoutConstraint constraintWithItem:self.panoramaView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0],
    [NSLayoutConstraint constraintWithItem:self.panoramaView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0],
    [NSLayoutConstraint constraintWithItem:self.panoramaView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]
  ]];

  // Request the panorama at the coordinate
  self.panoramaService = [[GMSPanoramaService alloc] init];

  __weak typeof(self) weakSelf = self;
  GMSPanoramaCallback callback = ^(GMSPanorama * _Nullable panorama, NSError * _Nullable error) {
    __strong typeof(weakSelf) strongSelf = weakSelf;
    if (!strongSelf) {
      return;
    }

    if (error) {
      NSLog(@"Street View Error: %@", error);
      dispatch_async(dispatch_get_main_queue(), ^{
        [strongSelf showStreetViewErrorAlert];
      });
    } else if (panorama) {
      dispatch_async(dispatch_get_main_queue(), ^{
        strongSelf.panoramaView.panorama = panorama;
      });
    } else {
      dispatch_async(dispatch_get_main_queue(), ^{
        [strongSelf showStreetViewErrorAlert];
      });
    }
  };

  [self.panoramaService requestPanoramaNearCoordinate:self.placemark.coordinate callback:callback];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.firstPanoramaId = nil;
}

#pragma mark GMSPanoramaViewDelegate

- (void)panoramaView:(GMSPanoramaView *)view didMoveToPanorama:(GMSPanorama *)panorama
{
  if (!panorama.panoramaID) {
    [self showStreetViewErrorAlert];
    return;
  }
  
  if (!self.firstPanoramaId) {
    self.firstPanoramaId = panorama.panoramaID;
  }
}

- (void)panoramaView:(GMSPanoramaView *)view error:(NSError *)error onPanoramaAtCoordinate:(CLLocationCoordinate2D)coordinate
{
  [self showStreetViewErrorAlert];
}

- (void)showStreetViewErrorAlert
{
  NSString *title = NSLocalizedString(@"Oooops", nil);
  NSString *message = NSLocalizedString(@"Could not load Street View", nil);
  UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil];
  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                           message:message
                                                                    preferredStyle:UIAlertControllerStyleAlert];
  [alertController addAction:action];
  [self presentViewController:alertController animated:YES completion:nil];
  [self trackCategory:BPLErrorCategory action:BPLStreetMapsPageLoadErrorEvent label:self.placemark.placemarkName];
}

@end
