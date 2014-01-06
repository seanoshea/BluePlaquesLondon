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

#import "BPLAboutViewController.h"

#import "BPLAboutViewModel.h"
#import "BPLLabel.h"
#import "UIScrollView+Autosizing.h"
#import "UIColor+BluePlaquesLondon.h"
#import "BPLConstants.h"
#import "NSObject+BPLTracking.h"

static NSString *const BPLDeveloperURLString = @"http://www.twitter.com/seanoshea";
static NSString *const BPLDesignerURLString = @"";
static NSString *const BPLDataURLString = @"http://www.reeddesign.co.uk";

@interface BPLAboutViewController () <TTTAttributedLabelDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic, weak) IBOutlet BPLLabel *developerLabel;
@property (nonatomic, weak) IBOutlet BPLLabel *developerDetailsLabel;

@property (nonatomic, weak) IBOutlet BPLLabel *designerLabel;
@property (nonatomic, weak) IBOutlet BPLLabel *designerDetailsLabel;

@property (nonatomic, weak) IBOutlet BPLLabel *dataLabel;
@property (nonatomic, weak) IBOutlet BPLLabel *dataDetailsLabel;

@property (nonatomic, weak) IBOutlet BPLLabel *googleMapsLabel;
@property (nonatomic, weak) IBOutlet BPLLabel *googleMapsLicenseInfoLabel;

@end

@implementation BPLAboutViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _model = [[BPLAboutViewModel alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"About Screen";
    
    UIFontDescriptor *header = [UIFontDescriptor fontDescriptorWithName:UIFontTextStyleHeadline size:20.0f];
    UIFontDescriptor *runner = [UIFontDescriptor fontDescriptorWithName:UIFontTextStyleBody size:13.0f];

    self.developerLabel.font = [UIFont fontWithDescriptor:header size:20.0f];
    self.developerLabel.textColor = [UIColor BPLOrangeColour];
    self.developerDetailsLabel.font = [UIFont fontWithDescriptor:runner size:13.0f];
    self.developerDetailsLabel.dataDetectorTypes = UIDataDetectorTypeAll;
    self.developerDetailsLabel.delegate = self;
    self.developerLabel.text = NSLocalizedString(@"Developer Details", nil);
    self.developerDetailsLabel.text = NSLocalizedString(@"Developed by Sean O' Shea", nil);
    NSRange range = [self.developerDetailsLabel.text rangeOfString:@"Sean O' Shea"];
    [self.developerDetailsLabel addLinkToURL:[NSURL URLWithString:BPLDeveloperURLString] withRange:range];
    
    self.designerLabel.font = [UIFont fontWithDescriptor:header size:20.0f];
    self.designerLabel.textColor = [UIColor BPLOrangeColour];
    self.designerDetailsLabel.font = [UIFont fontWithDescriptor:runner size:13.0f];
    self.designerDetailsLabel.dataDetectorTypes = UIDataDetectorTypeAll;
    self.designerDetailsLabel.delegate = self;
    self.designerLabel.text = NSLocalizedString(@"Designer Details", nil);
    self.designerDetailsLabel.text = NSLocalizedString(@"Designed by ...", nil);

    self.dataLabel.font = [UIFont fontWithDescriptor:header size:20.0f];
    self.dataLabel.textColor = [UIColor BPLOrangeColour];
    self.dataDetailsLabel.font = [UIFont fontWithDescriptor:runner size:13.0f];
    self.dataDetailsLabel.dataDetectorTypes = UIDataDetectorTypeAll;
    self.dataDetailsLabel.delegate = self;
    self.dataLabel.text = NSLocalizedString(@"Map Data Details", nil);
    self.dataDetailsLabel.text = NSLocalizedString(@"Map Data for this application is maintained by Roy Reed", nil);
    NSRange dataDetailsRange = [self.dataDetailsLabel.text rangeOfString:@"Roy Reed"];
    [self.dataDetailsLabel addLinkToURL:[NSURL URLWithString:BPLDataURLString] withRange:dataDetailsRange];
    
    self.googleMapsLabel.font = [UIFont fontWithDescriptor:header size:20.0f];
    self.googleMapsLabel.textColor = [UIColor BPLOrangeColour];
    self.googleMapsLicenseInfoLabel.font = [UIFont fontWithDescriptor:runner size:13.0f];
    self.googleMapsLicenseInfoLabel.dataDetectorTypes = UIDataDetectorTypeAll;
    self.googleMapsLicenseInfoLabel.delegate = self;
    self.googleMapsLabel.text = NSLocalizedString(@"Google Maps Information", nil);
    self.googleMapsLicenseInfoLabel.text = self.model.mapsOpenSourceLicenseInfo;
    
    self.scrollView.contentSize = [self.scrollView sizeThatFitsSubviews];
}

#pragma mark TTTAttributedLabelDelegate Methods

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    // tracking
    if ([url.absoluteString isEqualToString:BPLDeveloperURLString] ||
        [url.absoluteString isEqualToString:BPLDesignerURLString] ||
        [url.absoluteString isEqualToString:BPLDataURLString]) {
        [self trackCategory:BPLUIActionCategory action:BPLAboutLinkPressedEvent label:url.absoluteString];
    }
    [[UIApplication sharedApplication] openURL:url];
}

@end
