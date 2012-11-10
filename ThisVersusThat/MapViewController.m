//
//  MapViewController.m
//  ThisVersusThat
//
//  Created by David Lu on 11/9/12.
//
//

#import "MapViewController.h"
#import <Parse/Parse.h>
#import "REVClusterMap/REVClusterMapView.h"
#import "REVClusterMap/REVClusterPin.h"
#import "REVClusterMap/REVClusterMap.h"
#import "REVClusterMap/REVClusterManager.h"
#import "REVClusterMap/REVAnnotationsCollection.h"
#import "REVClusterAnnotationView.h"
#import "VLMConstants.h"
@interface MapViewController ()
@property (nonatomic, strong) NSMutableArray *pins;
@end

@implementation MapViewController
@synthesize pins;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)initWithPins:(NSMutableArray *)pins_in{
    self = [super init];
    if ( self ){
        self.pins = pins_in;
    }
    return  self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.title = @"Where";
    CGRect bounds = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height - HEADER_HEIGHT);
    REVClusterMapView *mapview = [[REVClusterMapView alloc] initWithFrame:bounds];
    mapview.delegate = self;
    
    
    //[mapview addAnnotations:pins];
    
    for ( int i = 0; i < pins.count; i++ ){
        REVClusterPin *pin = (REVClusterPin *)[pins objectAtIndex:i];
        [mapview addAnnotation:pin];
    }
    
    [self zoomMapViewToFitAnnotations:mapview animated:NO];
    [mapview removeAnnotations:mapview.annotations];
    [mapview addAnnotations:pins];
    [mapview setDelegate:self];
    [self.view addSubview:mapview];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//http://brianreiter.org/2012/03/02/size-an-mkmapview-to-fit-its-annotations-in-ios-without-futzing-with-coordinate-systems/
#define MINIMUM_ZOOM_ARC 0.014 //approximately 1 miles (1 degree of arc ~= 69 miles)
#define ANNOTATION_REGION_PAD_FACTOR 1.15
#define MAX_DEGREES_ARC 360
//size the mapView region to fit its annotations
- (void)zoomMapViewToFitAnnotations:(MKMapView *)mapView animated:(BOOL)animated
{
    NSArray *annotations = mapView.annotations;
    int count = [mapView.annotations count];
    if ( count == 0) { return; } //bail if no annotations
    
    //convert NSArray of id <MKAnnotation> into an MKCoordinateRegion that can be used to set the map size
    //can't use NSArray with MKMapPoint because MKMapPoint is not an id
    MKMapPoint points[count]; //C array of MKMapPoint struct
    for( int i=0; i<count; i++ ) //load points C array by converting coordinates to points
    {
        CLLocationCoordinate2D coordinate = [(id <MKAnnotation>)[annotations objectAtIndex:i] coordinate];
        points[i] = MKMapPointForCoordinate(coordinate);
    }
    //create MKMapRect from array of MKMapPoint
    MKMapRect mapRect = [[MKPolygon polygonWithPoints:points count:count] boundingMapRect];
    //convert MKCoordinateRegion from MKMapRect
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    
    //add padding so pins aren't scrunched on the edges
    region.span.latitudeDelta  *= ANNOTATION_REGION_PAD_FACTOR;
    region.span.longitudeDelta *= ANNOTATION_REGION_PAD_FACTOR;
    //but padding can't be bigger than the world
    if( region.span.latitudeDelta > MAX_DEGREES_ARC ) { region.span.latitudeDelta  = MAX_DEGREES_ARC; }
    if( region.span.longitudeDelta > MAX_DEGREES_ARC ){ region.span.longitudeDelta = MAX_DEGREES_ARC; }
    
    //and don't zoom in stupid-close on small samples
    if( region.span.latitudeDelta  < MINIMUM_ZOOM_ARC ) { region.span.latitudeDelta  = MINIMUM_ZOOM_ARC; }
    if( region.span.longitudeDelta < MINIMUM_ZOOM_ARC ) { region.span.longitudeDelta = MINIMUM_ZOOM_ARC; }
    //and if there is a sample of 1 we want the max zoom-in instead of max zoom-out
    if( count == 1 )
    {
        region.span.latitudeDelta = MINIMUM_ZOOM_ARC;
        region.span.longitudeDelta = MINIMUM_ZOOM_ARC;
    }
    [mapView setRegion:region animated:animated];
}


#pragma mark -
#pragma mark Map view delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if([annotation class] == MKUserLocation.class) {
		//userLocation = annotation;
		return nil;
	}
    
    REVClusterPin *pin = (REVClusterPin *)annotation;
    
    MKAnnotationView *annView;
    if( [pin nodeCount] > 0 ){
        pin.title = @"___";
        
        annView = (REVClusterAnnotationView*)
        [mapView dequeueReusableAnnotationViewWithIdentifier:@"cluster"];
        
        if( !annView )
            annView = (REVClusterAnnotationView*)
            [[REVClusterAnnotationView alloc] initWithAnnotation:annotation
                                                 reuseIdentifier:@"cluster"];
        
        annView.image = [UIImage imageNamed:@"cluster.png"];
        
        [(REVClusterAnnotationView*)annView setClusterText:
         [NSString stringWithFormat:@"%i",[pin nodeCount]]];
        
        annView.canShowCallout = NO;
    } else {
        pin.title = @"___";
        
        annView = (REVClusterAnnotationView*)
        [mapView dequeueReusableAnnotationViewWithIdentifier:@"cluster"];
        
        if( !annView )
            annView = (REVClusterAnnotationView*)
            [[REVClusterAnnotationView alloc] initWithAnnotation:annotation
                                                 reuseIdentifier:@"cluster"];
        
        annView.image = [UIImage imageNamed:@"cluster.png"];
        
        [(REVClusterAnnotationView*)annView setClusterText:@"1"];
        
        annView.canShowCallout = NO;
    }
    return annView;
}

- (void)mapView:(MKMapView *)mapView
didSelectAnnotationView:(MKAnnotationView *)view
{
    /*
     //NSlog(@"REVMapViewController mapView didSelectAnnotationView:");
     
     if (![view isKindOfClass:[REVClusterAnnotationView class]])
     return;
     
     CLLocationCoordinate2D centerCoordinate = [(REVClusterPin *)view.annotation coordinate];
     
     MKCoordinateSpan newSpan =
     MKCoordinateSpanMake(mapView.region.span.latitudeDelta/2.0,
     mapView.region.span.longitudeDelta/2.0);
     
     //mapView.region = MKCoordinateRegionMake(centerCoordinate, newSpan);
     
     [mapView setRegion:MKCoordinateRegionMake(centerCoordinate, newSpan)
     animated:YES];
     */
}

@end
