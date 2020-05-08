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

#import "BPLPlacemark+Additions.h"

#import "NSString+BPLPlacemarkFeatureDescription.h"

static NSString *const BPLOverlayTitleDelimiter = @"<br>";
static NSString *const BPLNameDelimiter = @"(";
static NSString *const BPLEmphasisNoteOpeningTag = @"<em>";
static NSString *const BPLEmphasisNoteClosingTag = @"</em>";

@implementation BPLPlacemark (Additions)

- (CLLocationCoordinate2D)coordinate
{
  return CLLocationCoordinate2DMake((self.latitude).doubleValue, (self.longitude).doubleValue);
}

- (NSString *)placemarkName
{
  return self.featureDescription.name;
}

- (NSString *)placemarkTitle
{
  return self.featureDescription.title;
}

- (NSString *)occupation
{
  return self.featureDescription.occupation;
}

- (NSString *)address
{
  return self.featureDescription.address;
}

- (NSString *)note
{
  return self.featureDescription.note;
}

- (NSString *)councilAndYear
{
  return  self.featureDescription.councilAndYear;
}

- (NSString *)key
{
  return [NSString stringWithFormat:@"%.5f%.5f", self.coordinate.latitude, self.coordinate.longitude];
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"name: %@ title: %@ occupation: %@ address: %@ note: %@ councilAndYear: %@", self.placemarkName, self.placemarkTitle, self.occupation, self.address, self.note, self.councilAndYear];
}

@end
