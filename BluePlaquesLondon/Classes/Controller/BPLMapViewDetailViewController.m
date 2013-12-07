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

#import "NSString+MapOverlayAdditions.h"
#import "SimpleKMLPlacemark.h"

#import <UIKit/UIKit.h>

@interface BPLMapViewDetailViewController()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *occupationLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;

- (IBAction)doneButtonTapped:(id)sender;

@end

@implementation BPLMapViewDetailViewController

- (void)viewWillAppear:(BOOL)animated
{
    SimpleKMLPlacemark *placemark = (SimpleKMLPlacemark *)self.marker.userData;
    self.titleLabel.text = [placemark.featureDescription overlayTitle];
    self.occupationLabel.text = placemark.featureDescription.occupation;
    self.addressLabel.text = placemark.featureDescription.address;
}

- (void)doneButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
