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

#import "BPLMapViewDetailViewController.h"

#import <IntentKit/IntentKit.h>
#import <HCViews/HCChevronView.h>

#import "BPLConstants.h"
#import "BPLWikipediaViewController.h"
#import "BPLDetailChooserViewController.h"
#import "BPLStreetViewViewController.h"
#import "BPLMapViewDetailViewModel.h"
#import "UIColor+BPLColors.h"
#import "NSString+BPLPlacemarkFeatureDescription.h"
#import "NSUserDefaults+BPLState.h"
#import "BPLLabel.h"
#import "BPLButton.h"
#import "NSObject+BPLTracking.h"
#import "BPLPlacemark+Additions.h"

#import "INKMapsHandler.h"
#import "INKActivityPresenter.h"

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

#pragma mark Lifecycle

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    BPLPlacemark *placemark = (BPLPlacemark *)self.model.markers[0];
    
    self.navigationItem.title = placemark.placemarkName;
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
    self.moreButton.hidden = [self.model.markers count] == 1;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    BPLPlacemark *placemark;
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

#pragma mark IBActions

- (void)detailChooserViewControllerRowSelected:(NSNotification *)notification
{
    NSNumber *index = [notification object];
    BPLPlacemark *selectedPlacemark = self.model.markers[[index intValue]];
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
    BPLPlacemark *placemark = self.model.markers[0];
    NSString *to = [NSString stringWithFormat:@"%.12f, %.12f", placemark.coordinate.latitude, placemark.coordinate.longitude];
    NSString *from = [NSString stringWithFormat:@"%.12f, %.12f", self.model.currentLocation.coordinate.latitude, self.model.currentLocation.coordinate.longitude];
    INKActivityPresenter *presenter = [mapsHandler directionsFrom:from to:to mode:INKMapsHandlerDirectionsModeWalking];
    [presenter presentModalActivitySheetFromViewController:self completion:^{

    }];
    [self buttonTappedForPlacemark:placemark withAction:BPLDirectionsButtonPressedEvent];
}

- (void)addChevronToButtons:(NSArray *)buttons
{
    for (UIButton *button in buttons) {
        UIView *chevron = [HCChevronView chevronViewWithColor:[UIColor BPLOrangeColour]
                                             highlightedColor:[UIColor BPLOrangeColour]];

        chevron.frame = CGRectMake(button.frame.size.width - 20, 10, 15, 15);
        chevron.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [button addSubview:chevron];
    }
}

- (void)buttonTappedForPlacemark:(BPLPlacemark *)placemark withAction:(NSString *)action
{
    [self trackCategory:BPLUIActionCategory action:action label:placemark.placemarkName];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
