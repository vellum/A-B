//
//  MapViewController.h
//  ThisVersusThat
//
//  Created by David Lu on 11/9/12.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface MapViewController : UIViewController<MKMapViewDelegate>
- (id)initWithPins:(NSMutableArray *)pins;
@end

