//
//  MapViewAnnotation.h
//  ThisVersusThat
//
//  Created by David Lu on 8/29/12.
//
//http://maybelost.com/2011/01/a-basic-mapview-and-annotation-tutorial/
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapViewAnnotation : NSObject <MKAnnotation> {
    
	NSString *title;
	CLLocationCoordinate2D coordinate;
    
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithTitle:(NSString *)ttl andCoordinate:(CLLocationCoordinate2D)c2d;

@end