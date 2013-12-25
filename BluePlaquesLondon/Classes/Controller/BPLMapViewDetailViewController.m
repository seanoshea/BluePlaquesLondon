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

#import "BPLMapViewDetailViewController.h"

#import <IntentKit/IntentKit.h>

#import "SimpleKMLPlacemark+Additions.h"
#import "SimpleKMLPoint.h"
#import "BPLConstants.h"
#import "BPLWikipediaViewController.h"
#import "BPLDetailChooserViewController.h"
#import "BPLStreetViewViewController.h"
#import "BPLMapViewDetailViewModel.h"
#import "UIColor+BluePlaquesLondon.h"
#import "NSString+BPLPlacemarkFeatureDescription.h"
#import "NSUserDefaults+BPLState.h"
#import "UIScrollView+Autosizing.h"

@interface BPLMapViewDetailViewController()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic, weak) IBOutlet UILabel *occupationLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UILabel *noteLabel;
@property (nonatomic, weak) IBOutlet UILabel *councilAndYearLabel;

@property (nonatomic, weak) IBOutlet UIButton *moreButton;
@property (nonatomic, weak) IBOutlet UIButton *directionsButton;

- (IBAction)directionsButtonTapped:(id)sender;

@end

@implementation BPLMapViewDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detailChooserViewControllerRowSelected:) name:BPLDetailChooserViewControllerRowSelected object:nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor darkBlueColour]}];
    self.occupationLabel.textColor = [UIColor darkBlueColour];
    self.addressLabel.textColor = [UIColor darkBlueColour];
    self.noteLabel.textColor = [UIColor darkBlueColour];
    self.councilAndYearLabel.textColor = [UIColor darkBlueColour];
}

- (void)viewDidLayoutSubviews
{
    self.scrollView.contentSize = self.scrollView.sizeThatFitsSubviews;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    SimpleKMLPlacemark *placemark = (SimpleKMLPlacemark *)self.model.markers[0];
    
    self.navigationItem.title = placemark.name;
    self.occupationLabel.text = placemark.occupation;
    self.addressLabel.text = placemark.address;
    
    // not all placemarks have notes
    NSString *note = placemark.note;
    if (note) {
        self.noteLabel.text = note;
        self.noteLabel.hidden = NO;
    } else {
        self.noteLabel.hidden = YES;
    }
    
    // not all placemarks have council and year data associated with them
    NSString *councilAndYear = placemark.councilAndYear;
    if (councilAndYear) {
        self.councilAndYearLabel.text = councilAndYear;
        self.councilAndYearLabel.hidden = NO;
    } else {
        self.noteLabel.hidden = YES;
    }
    
    // not all placemarks have multiple people associated with them
    self.moreButton.hidden = self.model.markers.count == 1;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:BPLWikipediaViewControllerSegue]) {
        BPLWikipediaViewController *destinationViewController = (BPLWikipediaViewController *)segue.destinationViewController;
        destinationViewController.markers = self.model.markers;
    } else if ([segue.identifier isEqualToString:BPLDetailChooserViewControllerSegue]) {
        BPLDetailChooserViewController *destinationViewController = (BPLDetailChooserViewController *)segue.destinationViewController;
        destinationViewController.markers = self.model.markers;
    } else if ([segue.identifier isEqualToString:BPLStreetMapViewControllerSegue]) {
        BPLStreetViewViewController *destinationViewController = (BPLStreetViewViewController *)segue.destinationViewController;
        destinationViewController.placemark = self.model.markers[0];
    }
}

- (void)detailChooserViewControllerRowSelected:(NSNotification *)notification {
    
    NSNumber *index = [notification object];
    SimpleKMLPlacemark *selectedPlacemark = self.model.markers[[index intValue]];
    NSMutableArray *mutableMarkers = [self.model.markers mutableCopy];
    [mutableMarkers removeObject:selectedPlacemark];
    [mutableMarkers insertObject:selectedPlacemark atIndex:0];
    self.model.markers = [mutableMarkers copy];
}

- (IBAction)directionsButtonTapped:(id)sender
{
    INKMapsHandler *mapsHandler = [[INKMapsHandler alloc] init];
    mapsHandler.center = CLLocationCoordinate2DMake(self.model.currentLocation.coordinate.longitude, self.model.currentLocation.coordinate.latitude);
    mapsHandler.zoom = [[NSUserDefaults standardUserDefaults] mapZoom];
    SimpleKMLPlacemark *placemark = self.model.markers[0];
    NSString *to = [NSString stringWithFormat:@"%.12f, %.12f", placemark.point.coordinate.latitude, placemark.point.coordinate.longitude];
    NSString *from = [NSString stringWithFormat:@"%.12f, %.12f", self.model.currentLocation.coordinate.latitude, self.model.currentLocation.coordinate.longitude];
    INKActivityPresenter *presenter = [mapsHandler directionsFrom:from to:to mode:INKMapsHandlerDirectionsModeWalking];
    [presenter presentActivitySheetFromViewController:self popoverFromRect:self.directionsButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
