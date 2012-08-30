//
//  MapViewAnnotation.m
//  ThisVersusThat
//
//  Created by David Lu on 8/29/12.
//
//http://maybelost.com/2011/01/a-basic-mapview-and-annotation-tutorial/

#import "MapViewAnnotation.h"

@implementation MapViewAnnotation

@synthesize title, coordinate;

- (id)initWithTitle:(NSString *)ttl andCoordinate:(CLLocationCoordinate2D)c2d {
	self = [super init];
	title = ttl;
	coordinate = c2d;
	return self;
}


@end