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

#import "BPLStreetViewViewController.h"

#import "GMSPanoramaView.h"
#import "SimpleKMLPoint.h"
#import "GMSPanorama.h"
#import "NSObject+BPLTracking.h"
#import "BPLConstants.h"

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
    GMSPanoramaView *panoView = [GMSPanoramaView panoramaWithFrame:CGRectZero nearCoordinate:self.placemark.point.coordinate];
    panoView.delegate = self;
    self.view = panoView;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.firstPanoramaId = nil;
    [super viewWillAppear:animated];
}

#pragma mark GMSPanoramaViewDelegate

- (void)panoramaView:(GMSPanoramaView *)view didMoveToPanorama:(GMSPanorama *)panorama
{
    if (!self.firstPanoramaId) {
        self.firstPanoramaId = panorama.panoramaID;
    }
    if (!self.firstPanoramaId) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Ooooops ...", nil)
                                   message:NSLocalizedString(@"Could not load Street View", nil)
                                  delegate:nil
                         cancelButtonTitle:NSLocalizedString(@"OK", nil)
                         otherButtonTitles:nil, nil] show];
        [self trackCategory:BPLErrorCategory action:BPLStreetMapsPageLoadErrorEvent label:self.placemark.name];
    }
}

@end
