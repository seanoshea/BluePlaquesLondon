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

#import "BPLMapViewController.h"

@import MapKit;

#import "BPLMapViewModel.h"

#import "NSUserDefaults+BPLState.h"
#import "BPLMapViewDetailViewController.h"
#import "BPLConstants.h"
#import "UIColor+BPLColors.h"
#import "BPLMapViewDetailViewModel.h"
#import "NSObject+BPLTracking.h"
#import "MKDistanceFormatter+BPLAdditions.h"
#import "BPLPlacemark+Additions.h"
#import "BPLSearchResultsController.h"
#import "BPLInfoWindow.h"
#import "BPLPlacemark+Additions.h"

NSString *BPLMapViewControllerStoryboardIdentifier = @"BPLMapViewController";

@interface BPLMapViewController() <GMSMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic) UISearchController *searchController;
@property (nonatomic) BPLSearchResultsController *searchResultsController;

@property (nonatomic) UIView *headerView;
@property (nonatomic) UIButton *aboutButton;

@property (nonatomic) GMSMapView *mapView;

@property (nonatomic) BPLMapViewModel *model;
@property (nonatomic) BOOL automaticallyNavigateToClosestPlacemark;

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocation *currentLocation;

@end

@implementation BPLMapViewController

#pragma mark Lifecycle

- (void)dealloc
{
  // Clean up location manager
  [self.locationManager stopUpdatingLocation];
  self.locationManager.delegate = nil;
  self.locationManager = nil;

  // Clean up references
  self.model = nil;
  self.searchController = nil;
  self.searchResultsController = nil;
  self.currentLocation = nil;
  self.mapView = nil;
  self.headerView = nil;
  self.aboutButton = nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (void)commonInit
{
  // Use weak reference to self in block to avoid retain cycle
  __weak typeof(self) weakSelf = self;
  self.model = [[BPLMapViewModel alloc] initWithKMLFileParsedCallback:^{
    __strong typeof(weakSelf) strongSelf = weakSelf;
    if (strongSelf) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [strongSelf.model createMarkersForMap:strongSelf.mapView];
        strongSelf.searchResultsController.model = strongSelf.model;
        [strongSelf.searchResultsController.collectionView reloadData];
        [strongSelf checkForAutomaticallyNavigatingToClosestPlacemark];
      });
    }
  }];
  self.locationManager = [[CLLocationManager alloc] init];
  [self.locationManager requestAlwaysAuthorization];
  [self.locationManager requestWhenInUseAuthorization];
  self.locationManager.delegate = self;
  self.locationManager.distanceFilter = kCLDistanceFilterNone;
  self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
  [self.locationManager startUpdatingLocation];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // screenName removed with Google Analytics
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  CLLocationCoordinate2D lastKnownCoordinate = defaults.lastKnownBPLCoordinate;
  float mapZoom = defaults.mapZoom;
  
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lastKnownCoordinate.latitude
                                                          longitude:lastKnownCoordinate.longitude
                                                               zoom:mapZoom];
  
  self.mapView = [[GMSMapView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
  self.mapView.camera = camera;
  UIEdgeInsets mapInsets = UIEdgeInsetsMake(0.0f, 5.0f, 5.0f, 0.0f);
  self.mapView.padding = mapInsets;
  self.mapView.delegate = self;
  self.mapView.indoorEnabled = NO;
  self.mapView.myLocationEnabled = YES;
  self.mapView.settings.myLocationButton = YES;
  self.mapView.settings.compassButton = NO;
  [self.view addSubview:self.mapView];
  
  [self.mapView animateToLocation:lastKnownCoordinate];

  // Setup UISearchController with results controller
  self.searchResultsController = [[BPLSearchResultsController alloc] init];
  self.searchResultsController.model = self.model;
  self.searchResultsController.currentLocation = self.currentLocation;

  __weak typeof(self) weakSelf = self;
  self.searchResultsController.didSelectItemAtIndexPath = ^(NSIndexPath *indexPath) {
    [weakSelf handleSearchResultSelection:indexPath];
  };

  self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsController];
  self.searchController.searchResultsUpdater = self.searchResultsController;
  self.navigationItem.searchController = self.searchController;
  self.definesPresentationContext = YES;

  [self setupHeaderView];
  [self styleHeaderView];
  [self setupInfoButton];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  // Stop location updates when view disappears to prevent battery drain and unnecessary processing
  [self.locationManager stopUpdatingLocation];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  // Ensure location manager is stopped when view is fully dismissed
  self.locationManager.delegate = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:BPLMapDetailViewControllerSegue]) {
    BPLMapViewDetailViewController *destinationViewController = (BPLMapViewDetailViewController *)segue.destinationViewController;
    BPLPlacemark *placemark = self.mapView.selectedMarker.userData;
    NSArray *markers = [self.model placemarksForKey:placemark.key];
    BPLMapViewDetailViewModel *model = [[BPLMapViewDetailViewModel alloc] initWithMarkers:markers currentLocation:self.currentLocation];
    destinationViewController.model = model;
  }
}

- (void)navigateToClosestPlacemark
{
  BPLPlacemark *closestPlacemark = [self.model closestPlacemarkToCoordinate:self.currentLocation.coordinate];
  if (closestPlacemark) {
    [self trackCategory:BPLUIActionCategory action:BPLTableRowPressedEvent label:closestPlacemark.placemarkName];
    [self navigateToPlacemark:closestPlacemark];
  } else {
    self.automaticallyNavigateToClosestPlacemark = YES;
  }
}

- (void)checkForAutomaticallyNavigatingToClosestPlacemark {
  if (self.automaticallyNavigateToClosestPlacemark && self.currentLocation) {
    self.automaticallyNavigateToClosestPlacemark = NO;
    [self navigateToClosestPlacemark];
  }
}

#pragma mark - Search Result Selection

- (void)handleSearchResultSelection:(NSIndexPath *)indexPath
{
  if (indexPath.row == 0) {
    [self navigateToClosestPlacemark];
  } else {
    BPLPlacemark *placemarkAtIndexPath = [self.model placemarkForRowAtIndexPath:indexPath];
    [self trackCategory:BPLUIActionCategory action:BPLTableRowPressedEvent label:placemarkAtIndexPath.placemarkName];
    [self navigateToPlacemark:placemarkAtIndexPath];
  }
}

- (void)navigateToPlacemark:(BPLPlacemark *)placemark
{
  // Dismiss search controller
  self.searchController.active = NO;

  [self.mapView animateToLocation:placemark.coordinate];
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    self.mapView.selectedMarker = [self.model markerAtPlacemark:placemark];
  });
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
  self.currentLocation = locations.lastObject;
  // ensure that the search table always has the latest known distances updated.
  //    [self reloadData];
  [[NSUserDefaults standardUserDefaults] saveLastKnownCoordinate:self.currentLocation.coordinate];
  [self checkForAutomaticallyNavigatingToClosestPlacemark];
}

#pragma mark GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
  // Dismiss search controller when user taps on map
  self.searchController.active = NO;
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
  [[NSUserDefaults standardUserDefaults] saveLastKnownBPLCoordinate:marker.position];
  [self markerTapped:marker withAction:BPLMarkerPressedEvent];
  return NO;
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
  if (position.zoom > 0.0f) {
    [[NSUserDefaults standardUserDefaults] saveMapZoom:position.zoom];
  }
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
  [[NSUserDefaults standardUserDefaults] saveLastKnownBPLCoordinate:marker.position];
  [self markerTapped:marker withAction:BPLMarkerInfoWindowPressedEvent];
  [self performSegueWithIdentifier:BPLMapDetailViewControllerSegue sender:self];
}

- (void)markerTapped:(GMSMarker *)marker withAction:(NSString *)action
{
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    BPLPlacemark *placemarkForMarker = [self.model firstPlacemarkAtCoordinate:marker.position];
    if (placemarkForMarker) {
      [self trackCategory:BPLUIActionCategory action:action label:placemarkForMarker.placemarkName];
    }
  });
}

- (void)setCurrentLocation:(CLLocation *)currentLocation {
  _currentLocation = currentLocation;
  if (self.searchResultsController) {
    self.searchResultsController.currentLocation = currentLocation;
    [self.searchResultsController.collectionView reloadData];
  }
}

#pragma mark MDC stuff

- (void)setupHeaderView {
  CGFloat width = self.view.frame.size.width > 0 ? self.view.frame.size.width : 320.0f;
  _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 76.0f)];
  _headerView.backgroundColor = [UIColor whiteColor];
}

- (void)styleHeaderView {
  [self.view addSubview:self.headerView];
}

- (void)setupInfoButton {
  self.aboutButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30.0f, 30.0f)];
  [self.aboutButton setBackgroundImage:[UIImage imageNamed:@"ic_info"] forState:UIControlStateNormal];
  [self.aboutButton setBackgroundImage:[UIImage imageNamed:@"ic_info"] forState:UIControlStateSelected];
  self.aboutButton.backgroundColor = [UIColor whiteColor];
  self.aboutButton.layer.cornerRadius = 15.0f;
  self.aboutButton.center = CGPointMake(self.view.frame.size.width - 25.0f, 47.0f);
  [self.aboutButton addTarget:self action:@selector(didTap:) forControlEvents:UIControlEventTouchUpInside];
  [self.headerView addSubview:self.aboutButton];
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
  BPLInfoWindow *view =  [[[NSBundle mainBundle] loadNibNamed:@"BPLInfoWindow" owner:self options:nil] objectAtIndex:0];
  BPLPlacemark *placemark = self.mapView.selectedMarker.userData;
  view.header.text = placemark.placemarkTitle;
  view.runner.text = placemark.occupation;
  return view;
}

- (void)didTap:(id)sender {
  [self performSegueWithIdentifier:@"AboutViewControllerPushSegue" sender: self];
}

@end
