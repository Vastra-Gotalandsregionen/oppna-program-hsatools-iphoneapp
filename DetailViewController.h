//
//  DetailViewController.h
//  HRIVIPhoneApp
//

#import <UIKit/UIKit.h>
#import "CareUnit.h"
#import <CoreLocation/CoreLocation.h>


@interface DetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate> {
	
	UILabel *unitNameLabel;
	UITextView *openingHoursTextView;
	UILabel *dropinLabel;
	UILabel *managementLabel;
	UILabel *visitingRuleAgeLabel;
	UITextView *descriptionTextView;
	UITableView *tableView;
	UIScrollView *scrollView;
	NSString *hsaIdentity;
	CareUnit *unit;
	NSMutableArray *detailsList;
	NSMutableArray *contactInfoList;
	NSMutableArray *descriptionList;
    CLLocationManager *locationManager;
    CLLocation *userLocation;
	
}

@property (nonatomic, retain) UILabel *unitNameLabel;
@property (nonatomic, retain) UITextView *openingHoursTextView;
@property (nonatomic, retain) UILabel *dropinLabel;
@property (nonatomic, retain) UILabel *managementLabel;
@property (nonatomic, retain) UILabel *visitingRuleAgeLabel;
@property (nonatomic, retain) UITextView *descriptionTextView; 
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSString *hsaIdentity;
@property (nonatomic, retain) CareUnit *unit;
@property (nonatomic, retain) NSMutableArray *listOfDescriptionItems, *listOfContactInfoItems;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *userLocation;


- (UILabel *)convertTextToLabel:(NSString *)labelText isHeading: (Boolean) isBold;
-(void) makeTheCall: (id) sender;
-(void) goToWebPage: (id) sender;
- (void)routeMeButtonClicked: (id) sender;
-(NSString*)secureWebRequest:(NSString*) ur;
-(Boolean) isValid:(NSString *) number;
- (void)stopUpdatingLocation:(NSString *)state;

@end
