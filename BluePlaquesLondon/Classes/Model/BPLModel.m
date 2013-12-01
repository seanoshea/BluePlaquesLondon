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

#import "BPLModel.h"

#import "SimpleKML.h"
#import "SimpleKMLContainer.h"
#import "SimpleKMLDocument.h"
#import "SimpleKMLFeature.h"
#import "SimpleKMLFolder.h"

@implementation BPLModel

- (id)init
{
    self = [super init];
    if (self) {
        [self loadBluePlaquesData];
    }
    return self;
}

- (NSError *)loadBluePlaquesData
{
    NSError *error;
    
    SimpleKML *kml = [SimpleKML KMLWithContentsOfFile:[[NSBundle mainBundle] pathForResource:BPLKMZFilename ofType:@"kmz"] error:&error];
    
    if (!error) {
        if (kml.feature && [kml.feature isKindOfClass:[SimpleKMLDocument class]]) {
            for (SimpleKMLFeature *feature in ((SimpleKMLContainer *)kml.feature).features) {
                if ([feature isKindOfClass:[SimpleKMLFolder class]]) {
                    self.data = ((SimpleKMLFolder *)feature).document;
                    break;
                }
            }
        }
    } else {
        
    }
    
    return error;
}

@end
