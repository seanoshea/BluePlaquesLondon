/*
 Copyright (c) 2014 - 2016 Upwards Northwards Software Limited
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

@end

@implementation BPLStreetViewViewController

#pragma mark Lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.screenName = @"Street View Screen";
  self.title = NSLocalizedString(@"Street View", nil);
  GMSPanoramaView *panoView = [GMSPanoramaView panoramaWithFrame:CGRectZero nearCoordinate:self.placemark.coordinate];
  panoView.delegate = self;
  self.view = panoView;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.firstPanoramaId = nil;
}

#pragma mark GMSPanoramaViewDelegate

- (void)panoramaView:(GMSPanoramaView *)view didMoveToPanorama:(GMSPanorama *)panorama
{
  if (!self.firstPanoramaId) {
    self.firstPanoramaId = panorama.panoramaID;
  }
  if (!self.firstPanoramaId) {
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
}

@end
