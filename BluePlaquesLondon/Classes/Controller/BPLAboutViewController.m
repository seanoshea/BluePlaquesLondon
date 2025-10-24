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

#import "BPLAboutViewController.h"

@import Social;

#import "BPLAboutViewModel.h"
#import "BPLLabel.h"
#import "UIColor+BPLColors.h"
#import "BPLConstants.h"
#import "NSObject+BPLTracking.h"


static NSString *const BPLDeveloperURLString = @"http://www.twitter.com/seanoshea";
static NSString *const BPLDesignerURLString = @"http://www.andydale.info";
static NSString *const BPLNounProjectURLString = @"http://www.thenounproject.com";
static NSString *const BPLDataURLString = @"http://www.reeddesign.co.uk";

@interface BPLAboutViewController ()

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

#pragma mark Lifecycle

/**
 * Initializes the view controller from a storyboard.
 * @param aDecoder The decoder used to initialize from storyboard
 * @return Initialized view controller instance
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    _model = [[BPLAboutViewModel alloc] init];
  }
  return self;
}

/**
 * Configures the view with about information and styling.
 */
- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // screenName removed with Google Analytics
  
  self.title = @"About";
  
  UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(close:)];
  self.navigationItem.rightBarButtonItem = anotherButton;
  
  self.developerLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
  self.developerLabel.textColor = [UIColor BPLOrangeColour];
  self.developerDetailsLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
  self.developerLabel.text = NSLocalizedString(@"Developer Details", nil);
  self.developerDetailsLabel.text = NSLocalizedString(@"Developed by Sean O'Shea", nil);
  
  self.designerLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
  self.designerLabel.textColor = [UIColor BPLOrangeColour];
  self.designerDetailsLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
  self.designerLabel.text = NSLocalizedString(@"Designer Details", nil);
  self.designerDetailsLabel.text = NSLocalizedString(@"Application designed by Andy Dale", nil);
  
  self.dataLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
  self.dataLabel.textColor = [UIColor BPLOrangeColour];
  self.dataDetailsLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
  self.dataLabel.text = NSLocalizedString(@"Map Data Details", nil);
  self.dataDetailsLabel.text = NSLocalizedString(@"Map Data for this application is maintained by Roy Reed", nil);
  
  self.googleMapsLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
  self.googleMapsLabel.textColor = [UIColor BPLOrangeColour];
  self.googleMapsLicenseInfoLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
  self.googleMapsLabel.text = NSLocalizedString(@"Google Maps Information", nil);
  self.googleMapsLicenseInfoLabel.text = self.model.mapsOpenSourceLicenseInfo;
}



/**
 * Dismisses the about view controller.
 * @param sender The object that triggered the close action
 */
- (void)close:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
