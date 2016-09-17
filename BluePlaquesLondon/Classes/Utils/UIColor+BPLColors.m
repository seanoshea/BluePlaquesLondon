/*
 Copyright (c) 2014 - 2016 Upwards Northwards Software Limited
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

#import "UIColor+BPLColors.h"

@implementation UIColor (BPLColors)

+ (UIColor *)BPLBlueColour
{
    static UIColor *darkBlueColour;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        darkBlueColour = [UIColor colorWithRed:13.0f/255.0f green:71.0f/255.0f blue:161.0f/255.0f alpha:1.0];
    });
    return darkBlueColour;
}

+ (UIColor *)BPLGreyColour
{
    static UIColor *lightGreyColour;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lightGreyColour = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0];
    });
    return lightGreyColour;
}

+ (UIColor *)BPLOrangeColour
{
    static UIColor *orangeColour;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        orangeColour = [UIColor colorWithRed:239.0f/255.0f green:108.0f/255.0f blue:0.0f/255.0f alpha:1.0];
    });
    return orangeColour;
}

+ (UIColor *)BPLLightOrangeColour
{
  static UIColor *lightOrangeColour;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    lightOrangeColour = [UIColor colorWithRed:239.0f/255.0f green:108.0f/255.0f blue:0.0f/255.0f alpha:0.25];
  });
  return lightOrangeColour;
}

@end
