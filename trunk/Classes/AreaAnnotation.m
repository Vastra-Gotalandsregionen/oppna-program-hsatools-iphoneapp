//
//  AreaAnnotation.m
//  PBolaget
//


#import "AreaAnnotation.h"


@implementation AreaAnnotation

@synthesize image;
@synthesize latitude;
@synthesize longitude;
@synthesize title, subtitle, areaId;
@synthesize coordinate;
@synthesize careUnit;
@synthesize distanceInMeters;
@synthesize hasDistance;

- (void)viewDidUnload {
    self.careUnit = nil;
    self.image = nil;
	self.title = nil;
	self.subtitle = nil;
	self.areaId = nil;
	self.hasDistance = nil;
}
- (void)dealloc {
	[image release];
	[careUnit release];
    [title release];
	[subtitle release];
	[areaId release];
    [super dealloc];
}

-(CLLocationCoordinate2D) coordinate {
	CLLocationCoordinate2D coord = 
	{self.latitude, self.longitude};	
	return coord;	
}

-(void) updateDistance:(CLLocation*) userLocation {	
	
	if (self.latitude > 0 && self.longitude > 0)
	{
		CLLocation *unitLocation = [[CLLocation alloc] initWithLatitude:self.latitude longitude:self.longitude];
		CLLocationDistance distance = [unitLocation distanceFromLocation:userLocation];
		self.distanceInMeters = distance;
		[unitLocation release];	
		self.hasDistance = TRUE;
	}
	else {
		self.hasDistance = FALSE;
		self.distanceInMeters = 100000000;
	}
	
}

@end