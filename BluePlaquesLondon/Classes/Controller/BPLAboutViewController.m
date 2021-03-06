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
#import "MDCTypography.h"

static NSString *const BPLDeveloperURLString = @"http://www.twitter.com/seanoshea";
static NSString *const BPLDesignerURLString = @"http://www.andydale.info";
static NSString *const BPLNounProjectURLString = @"http://www.thenounproject.com";
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

#pragma mark Lifecycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder
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
  
  self.title = @"About";
  
  UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(close:)];
  self.navigationItem.rightBarButtonItem = anotherButton;
  
  self.developerLabel.font = [MDCTypography subheadFont];
  self.developerLabel.textColor = [UIColor BPLOrangeColour];
  self.developerDetailsLabel.font = [MDCTypography body1Font];
  self.developerDetailsLabel.enabledTextCheckingTypes = UIDataDetectorTypeAll;
  self.developerDetailsLabel.delegate = self;
  self.developerLabel.text = NSLocalizedString(@"Developer Details", nil);
  self.developerDetailsLabel.text = NSLocalizedString(@"Developed by Sean O'Shea", nil);
  NSRange range = [self.developerDetailsLabel.text rangeOfString:@"Sean O'Shea"];
  [self.developerDetailsLabel addLinkToURL:[NSURL URLWithString:BPLDeveloperURLString] withRange:range];
  
  self.designerLabel.font = [MDCTypography subheadFont];
  self.designerLabel.textColor = [UIColor BPLOrangeColour];
  self.designerDetailsLabel.font = [MDCTypography body1Font];
  self.designerDetailsLabel.enabledTextCheckingTypes = UIDataDetectorTypeAll;
  self.designerDetailsLabel.delegate = self;
  self.designerLabel.text = NSLocalizedString(@"Designer Details", nil);
  self.designerDetailsLabel.text = NSLocalizedString(@"Application designed by Andy Dale", nil);
  NSRange designerDetailsRange = [self.designerDetailsLabel.text rangeOfString:@"Andy Dale"];
  [self.designerDetailsLabel addLinkToURL:[NSURL URLWithString:BPLDesignerURLString] withRange:designerDetailsRange];
  
  self.dataLabel.font = [MDCTypography subheadFont];
  self.dataLabel.textColor = [UIColor BPLOrangeColour];
  self.dataDetailsLabel.font = [MDCTypography body1Font];
  self.dataDetailsLabel.enabledTextCheckingTypes = UIDataDetectorTypeAll;
  self.dataDetailsLabel.delegate = self;
  self.dataLabel.text = NSLocalizedString(@"Map Data Details", nil);
  self.dataDetailsLabel.text = NSLocalizedString(@"Map Data for this application is maintained by Roy Reed", nil);
  NSRange dataDetailsRange = [self.dataDetailsLabel.text rangeOfString:@"Roy Reed"];
  [self.dataDetailsLabel addLinkToURL:[NSURL URLWithString:BPLDataURLString] withRange:dataDetailsRange];
  
  self.googleMapsLabel.font = [MDCTypography subheadFont];
  self.googleMapsLabel.textColor = [UIColor BPLOrangeColour];
  self.googleMapsLicenseInfoLabel.font = [MDCTypography body1Font];
  self.googleMapsLicenseInfoLabel.enabledTextCheckingTypes = UIDataDetectorTypeAll;
  self.googleMapsLicenseInfoLabel.delegate = self;
  self.googleMapsLabel.text = NSLocalizedString(@"Google Maps Information", nil);
  self.googleMapsLicenseInfoLabel.text = self.model.mapsOpenSourceLicenseInfo;
}

#pragma mark TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
  BOOL developerURLClicked = [url.absoluteString isEqualToString:BPLDeveloperURLString];
  // tracking
  if (developerURLClicked ||
      [url.absoluteString isEqualToString:BPLDesignerURLString] ||
      [url.absoluteString isEqualToString:BPLDataURLString] ||
      [url.absoluteString isEqualToString:BPLNounProjectURLString]) {
    [self trackCategory:BPLUIActionCategory action:BPLAboutLinkPressedEvent label:url.absoluteString];
  }
  if (developerURLClicked && [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
    SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [tweetSheet setInitialText:@"Hi there!"];
    [self presentViewController:tweetSheet animated:YES completion:^{
      [self trackCategory:BPLUIActionCategory action:BPLTweetSent label:url.absoluteString];
    }];
  } else {
    [[UIApplication sharedApplication] openURL:url];
  }
}

- (void)close:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
