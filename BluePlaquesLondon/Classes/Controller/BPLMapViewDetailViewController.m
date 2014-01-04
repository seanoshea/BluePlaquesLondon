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

#import "BPLMapViewDetailViewController.h"

#import <IntentKit/IntentKit.h>
#import <HCViews/HCChevronView.h>

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
#import "BPLLabel.h"
#import "BPLButton.h"

#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>

@interface BPLMapViewDetailViewController()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic, weak) IBOutlet BPLLabel *occupationLabel;
@property (nonatomic, weak) IBOutlet BPLLabel *addressLabel;
@property (nonatomic, weak) IBOutlet BPLLabel *noteLabel;
@property (nonatomic, weak) IBOutlet BPLLabel *councilAndYearLabel;

@property (nonatomic, weak) IBOutlet BPLButton *streetButton;
@property (nonatomic, weak) IBOutlet BPLButton *wikipediaButton;
@property (nonatomic, weak) IBOutlet BPLButton *moreButton;
@property (nonatomic, weak) IBOutlet BPLButton *directionsButton;

- (IBAction)directionsButtonTapped:(id)sender;

@end

@implementation BPLMapViewDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"Map Detail Screen";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIFontDescriptor *runner = [UIFontDescriptor fontDescriptorWithName:UIFontTextStyleBody size:13.0f];
    self.addressLabel.font = [UIFont fontWithDescriptor:runner size:13.0f];
    self.noteLabel.font = [UIFont fontWithDescriptor:runner size:13.0f];
    self.councilAndYearLabel.font = [UIFont fontWithDescriptor:runner size:13.0f];
    
    [self addChevronToButtons:@[self.streetButton, self.wikipediaButton, self.directionsButton, self.moreButton]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detailChooserViewControllerRowSelected:) name:BPLDetailChooserViewControllerRowSelected object:nil];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor BPLBlueColour]}];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SimpleKMLPlacemark *placemark;
    NSString *action;
    if ([segue.identifier isEqualToString:BPLWikipediaViewControllerSegue]) {
        BPLWikipediaViewController *destinationViewController = (BPLWikipediaViewController *)segue.destinationViewController;
        destinationViewController.markers = self.model.markers;
        placemark = self.model.markers[0];
        action = BPLWikipediaButtonPressedEvent;
    } else if ([segue.identifier isEqualToString:BPLDetailChooserViewControllerSegue]) {
        BPLDetailChooserViewController *destinationViewController = (BPLDetailChooserViewController *)segue.destinationViewController;
        destinationViewController.markers = self.model.markers;
        placemark = self.model.markers[0];
        action = BPLDetailsButtonPressedEvent;
    } else if ([segue.identifier isEqualToString:BPLStreetMapViewControllerSegue]) {
        BPLStreetViewViewController *destinationViewController = (BPLStreetViewViewController *)segue.destinationViewController;
        destinationViewController.placemark = self.model.markers[0];
        placemark = self.model.markers[0];
        action = BPLStreetViewButtonPressedEvent;
    }
    if (placemark && action) {
        [self buttonTappedForPlacemark:placemark withAction:action];
    }
}

- (void)detailChooserViewControllerRowSelected:(NSNotification *)notification
{
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
    [self buttonTappedForPlacemark:placemark withAction:BPLDirectionsButtonPressedEvent];
}

- (void)addChevronToButtons:(NSArray *)buttons
{
    for (UIButton *button in buttons) {
        UIView *chevron = [HCChevronView chevronViewWithColor:[UIColor BPLOrangeColour]
                                             highlightedColor:[UIColor BPLOrangeColour]];
        chevron.frame = CGRectMake(270, 10, 15, 15);
        chevron.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [button addSubview:chevron];
    }
}

- (void)buttonTappedForPlacemark:(SimpleKMLPlacemark *)placemark withAction:(NSString *)action
{
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:BPLUIActionCategory
                                                          action:action
                                                           label:placemark.name
                                                           value:nil] build]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
