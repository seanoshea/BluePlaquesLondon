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

#import "BPLAppDelegate.h"

#import "SimpleKML.h"
#import "SimpleKMLContainer.h"
#import "SimpleKMLDocument.h"
#import "SimpleKMLFeature.h"
#import "SimpleKMLPlacemark.h"
#import "SimpleKMLPoint.h"
#import "SimpleKMLPolygon.h"
#import "SimpleKMLLinearRing.h"
#import "SimpleKMLFolder.h"

@implementation BPLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self initializeGoogleMapsApi];
    
    NSError *error;
    
    SimpleKML *kml = [SimpleKML KMLWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"blueplaques" ofType:@"kmz"] error:NULL];

    if (kml.feature && [kml.feature isKindOfClass:[SimpleKMLDocument class]]) {

        for (SimpleKMLFeature *feature in ((SimpleKMLContainer *)kml.feature).features) {
            if ([feature isKindOfClass:[SimpleKMLFolder class]]) {
                SimpleKMLFolder *asd = (SimpleKMLFolder *)feature;
                SimpleKMLDocument *doccc = (SimpleKMLDocument *)asd.document;
                NSArray *addsads = doccc.flattenedPlacemarks;
                for (SimpleKMLPlacemark *pm in addsads) {
                    SimpleKMLPoint *point = pm.point;
                    
                    NSLog(@"pm.description: %@ Lat %.5f Long %.5f", pm.featureDescription, point.coordinate.latitude, point.coordinate.longitude);
                }
            }
        }
    }
    return YES;
}

- (void)initializeGoogleMapsApi {
    [GMSServices provideAPIKey:@"AIzaSyD3VT-JDnPAKhNiStoUpVAxOyIUUrWUsz0"];
}

@end
