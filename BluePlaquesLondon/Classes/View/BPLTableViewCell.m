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

#import "BPLTableViewCell.h"

#import "UIColor+BluePlaquesLondon.h"

@implementation BPLTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if ([reuseIdentifier isEqualToString:@"BluePlaquesClosestCell"]) {
            self.textLabel.textColor = [UIColor whiteColor];
            self.textLabel.highlightedTextColor = [UIColor darkBlueColour];
            self.backgroundColor = [UIColor darkBlueColour];
        } else {
            self.textLabel.textColor = [UIColor darkBlueColour];
        }
        UIView *backgroundView = [[UIView alloc] initWithFrame:self.frame];
        backgroundView.backgroundColor = [UIColor lightYellowColour];
        self.selectedBackgroundView = backgroundView;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

@end
