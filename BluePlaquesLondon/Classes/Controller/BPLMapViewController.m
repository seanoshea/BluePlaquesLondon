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

#import "BPLMapViewController.h"

@import MapKit;

#import "BPLMapViewModel.h"

#import "NSUserDefaults+BPLState.h"
#import "BPLMapViewDetailViewController.h"
#import "BPLConstants.h"
#import "UIColor+BPLColors.h"
#import "BPLTableViewCell.h"
#import "BPLMapViewDetailViewModel.h"
#import "NSObject+BPLTracking.h"
#import "MKDistanceFormatter+BPLAdditions.h"
#import "BPLPlacemark+Additions.h"

#import <SVProgressHUD/SVProgressHUD.h>
#import "GAITrackedViewController.h"
#import "BPLSearchViewController.h"
#import "MaterialFlexibleHeader.h"
#import "MDCRaisedButton.h"

NSString *BPLMapViewControllerStoryboardIdentifier = @"BPLMapViewController";

@interface BPLMapViewController() <GMSMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, BPLSearchViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) BPLSearchViewController *searchViewController;

@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic) MDCFlexibleHeaderViewController *fhvc;
@property (nonatomic) MDCRaisedButton *raisedButton;

@property (nonatomic) GMSMapView *mapView;

@property (nonatomic) BPLMapViewModel *model;
@property (nonatomic) NSTimer *loadingTimer;
@property (nonatomic) NSUInteger loadingTicks;
@property (nonatomic) BOOL automaticallyNavigateToClosestPlacemark;

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocation *currentLocation;

@end

@implementation BPLMapViewController

#pragma mark Lifecycle

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
    self.model = [[BPLMapViewModel alloc] initWithKMLFileParsedCallback:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissHUDAndInvalidateTimer];
            [self.model createMarkersForMap:self.mapView];
            self.searchViewController.model = self.model;
            self.searchBar.userInteractionEnabled = YES;
            [self reloadData];
            [self checkForAutomaticallyNavigatingToClosestPlacemark];
        });
    }];
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
  [self setupFlexibleHeaderViewController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"Maps Screen";
  
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CLLocationCoordinate2D lastKnownCoordinate = defaults.lastKnownBPLCoordinate;
    float mapZoom = defaults.mapZoom;

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lastKnownCoordinate.latitude
                                                            longitude:lastKnownCoordinate.longitude
                                                                 zoom:mapZoom];

    self.mapView = [GMSMapView mapWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height) camera:camera];
    UIEdgeInsets mapInsets = UIEdgeInsetsMake(0.0f, 5.0f, 5.0f, 0.0f);
    self.mapView.padding = mapInsets;
    self.mapView.delegate = self;
    self.mapView.indoorEnabled = NO;
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
    self.mapView.settings.compassButton = NO;
    [self.view addSubview:self.mapView];
    
    [self.mapView animateToLocation:lastKnownCoordinate];
  
  [self setupSearchBar];

    [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading", @"")];
    self.loadingTicks = 0;
    self.loadingTimer = [NSTimer scheduledTimerWithTimeInterval:1.5f
                                                         target:self
                                                       selector:@selector(updateLoadingMessage)
                                                       userInfo:nil
                                                        repeats:YES];
  
  [self styleFlexibleHeaderView];
  [self setupInfoButton];
}

- (void)didTap:(id)sender {
  
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self dismissHUDAndInvalidateTimer];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:BPLMapDetailViewControllerSegue]) {
        BPLMapViewDetailViewController *destinationViewController = (BPLMapViewDetailViewController *)segue.destinationViewController;
        BPLPlacemark *placemark = self.mapView.selectedMarker.userData;
        NSArray *markers = [self.model placemarksForKey:placemark.key];
        BPLMapViewDetailViewModel *model = [[BPLMapViewDetailViewModel alloc] initWithMarkers:markers currentLocation:self.currentLocation];
        destinationViewController.model = model;
    } else if ([segue.identifier isEqualToString:BPLSearchViewControllerSegue]) {
      self.searchViewController = segue.destinationViewController;
      self.searchViewController.delegate = self;
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

#pragma mark BPLSearchViewControllerDelegate

- (void)searchViewController:(BPLSearchViewController *)searchViewController didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) {
    [self navigateToClosestPlacemark];
  } else {
    BPLPlacemark *placemarkAtIndexPath = [self.model placemarkForRowAtIndexPath:indexPath];
    [self trackCategory:BPLUIActionCategory action:BPLTableRowPressedEvent label:placemarkAtIndexPath.placemarkName];
    [self navigateToPlacemark:placemarkAtIndexPath];
  }
}

#pragma mark - Search

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self filterDataForSearchText:self.searchBar.text];
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self toggleSearchViewController:YES];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self filterDataForSearchText:searchBar.text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self filterDataForSearchText:searchText];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self toggleSearchViewController:NO];
}

- (void)filterDataForSearchText:(NSString *)searchText
{
    self.model.filteredData = [self.model.alphabeticallySortedPositions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.placemarkTitle contains[c] %@", searchText]];
    [self reloadData];
}

- (void)navigateToPlacemark:(BPLPlacemark *)placemark
{
    [self.searchBar resignFirstResponder];
    [self toggleSearchViewController:NO];
    [self.mapView animateToLocation:placemark.coordinate];
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    self.mapView.selectedMarker = [self.model markerAtPlacemark:placemark];
  });
}

- (void)toggleSearchViewController:(BOOL)show
{
    if (show) {
        [self.view bringSubviewToFront:self.containerView];
    } else {
        [self.view sendSubviewToBack:self.containerView];
    }
  self.searchBar.showsCancelButton = show;
  self.containerView.hidden = !show;
}

- (void)reloadData {
  [self.searchViewController.collectionView reloadData];
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
    [self toggleSearchViewController:NO];
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
  if (self.searchViewController) {
    self.searchViewController.currentLocation = currentLocation;
  }
}

#pragma mark Loading

- (void)updateLoadingMessage
{
    static NSArray *loadingMessages;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loadingMessages = @[NSLocalizedString(@"Loading .", nil),
                            NSLocalizedString(@"Loading ..", nil),
                            NSLocalizedString(@"Loading ...", nil),
                            NSLocalizedString(@"Nearly ready .....", nil)];
    });
    NSString *message;
    if (loadingMessages.count > self.loadingTicks) {
        message = loadingMessages[self.loadingTicks];
    } else {
        message = loadingMessages[loadingMessages.count - 1];
    }
    self.loadingTicks++;
    [SVProgressHUD showWithStatus:message];
}

- (void)dismissHUDAndInvalidateTimer
{
    [SVProgressHUD dismiss];
    [self.loadingTimer invalidate];
    self.loadingTimer = nil;
}

#pragma mark MDC stuff

- (void)setupFlexibleHeaderViewController {
  _fhvc = [[MDCFlexibleHeaderViewController alloc] initWithNibName:nil bundle:nil];
  [self addChildViewController:_fhvc];
}

- (void)setupSearchBar {
  self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
  self.searchBar.placeholder = NSLocalizedString(@"Search", @"");
  self.searchBar.userInteractionEnabled = NO;
  self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
  self.searchBar.delegate = self;
  [self.fhvc.view addSubview:self.searchBar];
  [self toggleSearchViewController:NO];
}

- (void)styleFlexibleHeaderView {
  self.fhvc.view.frame = self.view.bounds;
  [self.view addSubview:self.fhvc.view];
  [self.fhvc didMoveToParentViewController:self];
  self.fhvc.headerView.minimumHeight = 10.0f;
  self.fhvc.headerView.backgroundColor = [UIColor whiteColor];
}

- (void)setupInfoButton {
  self.raisedButton = [[MDCRaisedButton alloc] init];
  [self.raisedButton sizeToFit];
  [self.raisedButton setBackgroundImage:[UIImage imageNamed:@"ic_info"] forState:UIControlStateNormal];
  [self.raisedButton setBackgroundImage:[UIImage imageNamed:@"ic_info"] forState:UIControlStateSelected];
  [self.raisedButton setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
  self.raisedButton.center = CGPointMake(self.view.frame.size.width - self.raisedButton.frame.size.width / 2, 60.0f);
  [self.raisedButton addTarget:self
                          action:@selector(didTap:)
                forControlEvents:UIControlEventTouchUpInside];
  [self.fhvc.view addSubview:self.raisedButton];
}

@end
