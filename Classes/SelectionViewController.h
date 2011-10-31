//
//  SelectionViewController.h
//  HRIVIPhoneApp
//

#import <UIKit/UIKit.h>


@class MapViewController;

@interface SelectionViewController : UIViewController {

	IBOutlet MapViewController *mapView;

}

@property (nonatomic,retain) MapViewController *mapView;

-(IBAction)OnDutyUnitButtonClick: (id) sender;
-(IBAction)OnEmergencyUnitButtonClick: (id) sender;
-(IBAction)OnCareUnitButtonClick: (id) sender;

@end
