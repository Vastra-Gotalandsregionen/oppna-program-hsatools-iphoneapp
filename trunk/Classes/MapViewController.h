//
//  MapViewController.h
//  HRIVIPhoneApp
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MBProgressHUD.h"
#import "HRIVIPhoneAppAppDelegate.h"

@class DetailViewController;

@interface MapViewController : UIViewController<MKMapViewDelegate, UITableViewDelegate, MBProgressHUDDelegate, CLLocationManagerDelegate> {

	MKMapView *mapView;
	float latitude;
	float longitude;
	float latitudeDelta;
	float longitudeDelta;
	Boolean mapLoadedFirstTime;
	NSMutableArray *areaPoints;
	DetailViewController IBOutlet *detailViewController;
	IBOutlet UISegmentedControl *Segment;
	IBOutlet UITableView *tableView;
	bool isMapSegment;
	MBProgressHUD *HUD;
    CLLocationManager *locationManager;
    CLLocation *userLocation;
    bool isZoomed;
    
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic) bool isMapSegment;
@property (nonatomic, retain) NSMutableArray *areaPoints;
@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *userLocation;
@property (nonatomic, retain) IBOutlet UISegmentedControl *Segment;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic) bool isZoomed;

-(IBAction)changeSeg;

-(void)sortTableListView;
-(void) pushDetailViewController:(NSIndexPath *)index;
-(void)PopulateAnnotations: (NSMutableDictionary*) units;
-(void)setDefaultMapLocation;
- (void)stopUpdatingLocation:(NSString *)state;

@end
