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

#import "BPLSearchResultCell.h"
#import "UIColor+BPLColors.h"

@interface BPLSearchResultCell ()

@property (nonatomic) UILabel *disclosureLabel;

@end

@implementation BPLSearchResultCell

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self setupCell];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self setupCell];
  }
  return self;
}

- (void)setupCell
{
  // Configure cell appearance
  self.backgroundColor = [UIColor whiteColor];
  self.layer.cornerRadius = 8.0f;
  self.layer.shadowColor = [UIColor blackColor].CGColor;
  self.layer.shadowOffset = CGSizeMake(0, 2);
  self.layer.shadowRadius = 4.0f;
  self.layer.shadowOpacity = 0.1f;

  // Create title label
  _titleLabel = [[UILabel alloc] init];
  _titleLabel.font = [UIFont boldSystemFontOfSize:16];
  _titleLabel.textColor = [UIColor BPLBlueColour];
  _titleLabel.numberOfLines = 1;
  [self.contentView addSubview:_titleLabel];

  // Create subtitle label
  _subtitleLabel = [[UILabel alloc] init];
  _subtitleLabel.font = [UIFont systemFontOfSize:14];
  _subtitleLabel.textColor = [UIColor BPLDarkGreyColour];
  _subtitleLabel.numberOfLines = 1;
  [self.contentView addSubview:_subtitleLabel];

  // Create disclosure indicator
  _disclosureLabel = [[UILabel alloc] init];
  _disclosureLabel.text = @">";
  _disclosureLabel.textColor = [UIColor lightGrayColor];
  _disclosureLabel.textAlignment = NSTextAlignmentCenter;
  _disclosureLabel.font = [UIFont boldSystemFontOfSize:18];
  [self.contentView addSubview:_disclosureLabel];
}

- (void)layoutSubviews
{
  [super layoutSubviews];

  CGFloat cellWidth = self.contentView.bounds.size.width;
  CGFloat cellHeight = self.contentView.bounds.size.height;

  // Position title label
  self.titleLabel.frame = CGRectMake(16, 8, cellWidth - 48, 20);

  // Position subtitle label
  self.subtitleLabel.frame = CGRectMake(16, 28, cellWidth - 48, 16);

  // Position disclosure indicator
  self.disclosureLabel.frame = CGRectMake(cellWidth - 30, 0, 20, cellHeight);
}

- (void)configureCellWithTitle:(NSString *)title subtitle:(NSString *)subtitle showSubtitle:(BOOL)showSubtitle
{
  self.titleLabel.text = title;
  self.subtitleLabel.text = subtitle;
  self.subtitleLabel.hidden = !showSubtitle;
  [self setNeedsLayout];
}

- (void)prepareForReuse
{
  [super prepareForReuse];
  self.titleLabel.text = nil;
  self.subtitleLabel.text = nil;
  self.subtitleLabel.hidden = NO;
}

@end
