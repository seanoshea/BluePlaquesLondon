/*
 Copyright 2013 - 2014 Sean O' Shea
 
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

#import "UIScrollView+Autosizing.h"

@implementation UIScrollView (Autosizing)

- (CGSize)sizeThatFitsSubviews {
    CGSize size = CGSizeZero;
    CGFloat width;
    CGFloat height;
    for (UIView *subview in self.subviews) {
        if (subview.alpha > 0 && !subview.hidden) {
            width = subview.frame.origin.x + subview.frame.size.width;
            height = subview.frame.origin.y + subview.frame.size.height;
            if (width > size.width) {
                size.width = width;
            }
            if (height > size.height) {
                size.height = height;
            }
        }
    }
    size.height = size.height + 300.0f;
    return size;
}

@end
