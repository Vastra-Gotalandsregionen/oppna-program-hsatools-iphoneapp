//
//  AreaAnnotation.h
//  PBolaget
//


#import <MapKit/MapKit.h>
#import	<Foundation/Foundation.h>
#import	"CareUnit.h"


@interface AreaAnnotation : NSObject <MKAnnotation> {
	
	UIImage *image;
    float latitude;
    float longitude;	
	NSString *title;
	NSString *subtitle;
	NSString *areaId;	
	CareUnit *careUnit;
	CLLocationCoordinate2D coordinate;
	float distanceInMeters;
	bool hasDistance;
}

@property (nonatomic, retain) UIImage *image;
@property (nonatomic) float latitude;
@property (nonatomic) float longitude;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, retain) NSString * areaId;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) CareUnit *careUnit;
@property (nonatomic) float distanceInMeters;
@property (nonatomic) bool hasDistance;

-(void) updateDistance:(CLLocation*) userLocation;

@end
