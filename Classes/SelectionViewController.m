//
//  SelectionViewController.m
//  HRIVIPhoneApp
//

#import "SelectionViewController.h"
#import "FactoryProvider.h"
#import "Constants.h"
#import "MapViewController.h"


@implementation SelectionViewController

@synthesize mapView;

-(IBAction)OnDutyUnitButtonClick:(id)sender {
	[FactoryProvider getCurrentUnitInformation].currentUnitType = DUTY_UNIT;
	[[self navigationController] pushViewController:self.mapView  animated:YES];
}

-(IBAction)OnEmergencyUnitButtonClick:(id)sender {
	[FactoryProvider getCurrentUnitInformation].currentUnitType = EMERGENCY_UNIT;
	[[self navigationController] pushViewController:self.mapView  animated:YES];
}

-(IBAction)OnCareUnitButtonClick:(id)sender {
	[FactoryProvider getCurrentUnitInformation].currentUnitType = CARE_UNIT;
	[[self navigationController] pushViewController:self.mapView  animated:YES];

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {	
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    self.mapView = nil;
}

- (void)dealloc {
    [super dealloc];
    [mapView release];
}

@end
