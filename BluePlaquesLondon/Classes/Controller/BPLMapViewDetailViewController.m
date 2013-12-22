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

#import "SimpleKMLPlacemark+Additions.h"
#import "BPLConstants.h"
#import "BPLWikipediaViewController.h"
#import "BPLDetailChooserViewController.h"
#import "BPLStreetViewViewController.h"

#import "UIColor+BluePlaquesLondon.h"

@interface BPLMapViewDetailViewController()

@property (nonatomic, weak) IBOutlet UILabel *occupationLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UILabel *noteLabel;
@property (nonatomic, weak) IBOutlet UILabel *councilAndYearLabel;

@property (nonatomic, weak) IBOutlet UIButton *moreButton;

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    SimpleKMLPlacemark *placemark = (SimpleKMLPlacemark *)self.markers[0];
    
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
    self.moreButton.hidden = self.markers.count == 1;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:BPLWikipediaViewControllerSegue]) {
        BPLWikipediaViewController *destinationViewController = (BPLWikipediaViewController *)segue.destinationViewController;
        destinationViewController.markers = self.markers;
    } else if ([segue.identifier isEqualToString:BPLDetailChooserViewControllerSegue]) {
        BPLDetailChooserViewController *destinationViewController = (BPLDetailChooserViewController *)segue.destinationViewController;
        destinationViewController.markers = self.markers;
    } else if ([segue.identifier isEqualToString:BPLStreetMapViewControllerSegue]) {
        BPLStreetViewViewController *destinationViewController = (BPLStreetViewViewController *)segue.destinationViewController;
        destinationViewController.placemark = self.markers[0];
    }
}

- (void)detailChooserViewControllerRowSelected:(NSNotification *)notification {
    
    NSNumber *index = [notification object];
    SimpleKMLPlacemark *selectedPlacemark = self.markers[[index intValue]];
    NSMutableArray *mutableMarkers = [self.markers mutableCopy];
    [mutableMarkers removeObject:selectedPlacemark];
    [mutableMarkers insertObject:selectedPlacemark atIndex:0];
    self.markers = [mutableMarkers copy];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
