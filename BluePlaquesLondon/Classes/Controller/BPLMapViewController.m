/*
 Copyright (c) 2014 - 2015 Upwards Northwards Software Limited
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

NSString *BPLMapViewControllerStoryboardIdentifier = @"BPLMapViewController";

@interface BPLMapViewController() <GMSMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic) GMSMapView *mapView;

@property (nonatomic) BPLMapViewModel *model;
@property (nonatomic) NSTimer *loadingTimer;
@property (nonatomic) NSUInteger loadingTicks;

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocation *currentLocation;

@end

@implementation BPLMapViewController

#pragma mark Lifecycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
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
            self.searchBar.userInteractionEnabled = YES;
            [self.tableView reloadData];
        });
    }];
    
    self.locationManager = [[CLLocationManager alloc] init];
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"Maps Screen";
    
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    CLLocationCoordinate2D lastKnownCoordinate = [defaults lastKnownBPLCoordinate];
    float mapZoom = [defaults mapZoom];

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lastKnownCoordinate.latitude
                                                            longitude:lastKnownCoordinate.longitude
                                                                 zoom:mapZoom];

    self.mapView = [GMSMapView mapWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height) camera:camera];
    UIEdgeInsets mapInsets = UIEdgeInsetsMake(0.0f, 5.0f, 48.0f, 0.0f);
    self.mapView.padding = mapInsets;
    self.mapView.delegate = self;
    self.mapView.indoorEnabled = NO;
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
    self.mapView.settings.compassButton = NO;
    [self.view addSubview:self.mapView];
    [self.mapView animateToLocation:lastKnownCoordinate];
    
    self.searchBar.placeholder = NSLocalizedString(@"Search", @"");
    self.searchBar.userInteractionEnabled = NO;
    [self.view bringSubviewToFront:self.searchBar];
    [self toggleTableView:NO];
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading", @"") maskType:SVProgressHUDMaskTypeGradient];
    self.loadingTicks = 0;
    self.loadingTimer = [NSTimer scheduledTimerWithTimeInterval:1.5f
                                                         target:self
                                                       selector:@selector(updateLoadingMessage)
                                                       userInfo:nil
                                                        repeats:YES];
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
    }
}

- (void)navigateToClosestPlacemark
{
    BPLPlacemark *closestPlacemark = [self.model closestPlacemarkToCoordinate:self.currentLocation.coordinate];
    [self trackCategory:BPLUIActionCategory action:BPLTableRowPressedEvent label:closestPlacemark.placemarkName];
    [self navigateToPlacemark:closestPlacemark];
}

#pragma UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.model.numberOfPlacemarks + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:BPLClosestCell];
        if (!cell) {
            cell = [[BPLTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BPLClosestCell];
        }
        cell.textLabel.text = NSLocalizedString(@"Find the Plaque closest to me", nil);
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:BPLSearchCell];
        if (!cell) {
            cell = [[BPLTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:BPLSearchCell];
        }
        BPLPlacemark *pm = [self.model placemarkForRowAtIndexPath:indexPath];
        
        if (self.currentLocation) {
            CLLocation *loc = [[CLLocation alloc] initWithLatitude:pm.coordinate.latitude
                                                         longitude:pm.coordinate.longitude];
            cell.detailTextLabel.text = [MKDistanceFormatter distanceFromLocation:loc toLocation:self.currentLocation];
        }
        
        cell.textLabel.text = pm.placemarkName;
    }
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    [self toggleTableView:YES];
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
    [self toggleTableView:NO];
}

- (void)filterDataForSearchText:(NSString *)searchText
{
    self.model.filteredData = [self.model.alphabeticallySortedPositions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.placemarkTitle contains[c] %@", searchText]];
    [self.tableView reloadData];
}

- (void)navigateToPlacemark:(BPLPlacemark *)placemark
{
    [self.searchBar resignFirstResponder];
    [self toggleTableView:NO];
    [self.mapView animateToLocation:placemark.coordinate];
    self.mapView.selectedMarker = [self.model markerAtPlacemark:placemark];
}

- (void)toggleTableView:(BOOL)show
{
    if (show) {
        [self.view bringSubviewToFront:self.tableView];
    } else {
        [self.view sendSubviewToBack:self.tableView];
    }
    self.searchBar.showsCancelButton = show;
    self.tableView.hidden = !show;
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = locations.lastObject;
    // ensure that the search table always has the latest known distances updated.
    [self.tableView reloadData];
    [[NSUserDefaults standardUserDefaults] saveLastKnownCoordinate:self.currentLocation.coordinate];
}

#pragma mark GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self toggleTableView:NO];
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
    if ([loadingMessages count] > self.loadingTicks) {
        message = loadingMessages[self.loadingTicks];
    } else {
        message = loadingMessages[[loadingMessages count] - 1];
    }
    self.loadingTicks++;
    [SVProgressHUD showWithStatus:message maskType:SVProgressHUDMaskTypeGradient];
}

- (void)dismissHUDAndInvalidateTimer
{
    [SVProgressHUD dismiss];
    [self.loadingTimer invalidate];
    self.loadingTimer = nil;
}

@end
