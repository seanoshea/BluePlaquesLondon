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

#import "BPLFindClosestPlaqueView.h"

#import "UIColor+BluePlaquesLondon.h"

@implementation BPLFindClosestPlaqueView

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor darkBlueColour];
    self.button.titleLabel.text = NSLocalizedString(@"Find the Plaque Closest to You", @"");
    self.button.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    self.button.titleLabel.textColor = [UIColor whiteColor];
}

@end
