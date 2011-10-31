//
//  MapViewController.m
//  HRIVIPhoneApp
//

#import "MapViewController.h"
#import "AreaAnnotation.h"
#import "CareUnit.h"
#import "FactoryProvider.h"
#import "Constants.h"
#import <CoreLocation/CoreLocation.h>
#import "HRIVIPhoneAppAppDelegate.h"
#import	"DetailViewController.h"

#define TAG_NO_DISTANCE 1;

@implementation MapViewController

@synthesize mapView, 
areaPoints, 
detailViewController, 
isMapSegment,
locationManager,
userLocation,
Segment,
tableView,
isZoomed;

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	//MKAnnotationView *mKAnnotationView = nil;
	// if it's the user location, just return nil.
	if ([annotation isKindOfClass:[MKUserLocation class]])
	{		MKUserLocation *userAnnotation = (MKUserLocation*) annotation;
        /*if (mapLoadedFirstTime == YES)
        {	
            if (userLocation != nil) {
                MKCoordinateRegion newRegion;
                newRegion.center.latitude = userLocation.coordinate.latitude;
                newRegion.center.longitude = userLocation.coordinate.longitude;
                newRegion.span.latitudeDelta = 3;
                newRegion.span.longitudeDelta = 3;
                [self.mapView setRegion:newRegion animated:YES];
                mapLoadedFirstTime = NO;
            }
			else{
                MKCoordinateRegion newRegion;
                newRegion.center.latitude = 57.70404;
                newRegion.center.longitude = 11.96919;
                newRegion.span.latitudeDelta = 0.112872;
                newRegion.span.longitudeDelta = 0.109863;
                [self.mapView setRegion:newRegion animated:YES];
                mapLoadedFirstTime = NO;
            }
        }*/
		
		userAnnotation.title = @"Din Position";
		return nil;
	}	
	
	AreaAnnotation *areaAnnotation = (AreaAnnotation*)annotation;
	NSString *annotationId = areaAnnotation.areaId;
	
	MKAnnotationView* annotationView = [[[MKAnnotationView alloc]
                                         initWithAnnotation:annotation reuseIdentifier:annotationId] autorelease];
	
	UIImage *flagImage = [UIImage imageNamed:@"stangt_kartnal.png"];
	if ([areaAnnotation.careUnit isCenterOpen]) {
		flagImage = [UIImage imageNamed:@"oppet_kartnal.png"];		
	}
	annotationView.image = flagImage;
	
	annotationView.canShowCallout = YES;
	UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	annotationView.rightCalloutAccessoryView = rightButton;
	
	return annotationView;
}

-(void)setDefaultMapLocation {
    if (userLocation != nil){
        MKCoordinateRegion newRegion;
        newRegion.center.latitude = userLocation.coordinate.latitude;
        newRegion.center.longitude = userLocation.coordinate.longitude;
        newRegion.span.latitudeDelta = 0.1;
        newRegion.span.longitudeDelta = 0.1;
        [self.mapView setRegion:newRegion animated:YES];
    }
    else{
        MKCoordinateRegion newRegion;
        //Sets map zoom coordinates to start out from Gothenburg.
        newRegion.center.latitude = 57.70404;
        newRegion.center.longitude = 11.96919;
        newRegion.span.latitudeDelta = 0.1;	
        newRegion.span.longitudeDelta = 0.1;
        [mapView setRegion:newRegion animated:YES];
	}
		
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad{
    [[self locationManager] startUpdatingLocation];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnUnitDataProviderLoadedFailed:)name:UNIT_DATA_LOADED_FAILED_EVENT object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnUnitDataProviderLoaded:)name:UNIT_DATA_LOADED_SUCCESS_EVENT object:nil];
    
	self.areaPoints = [[NSMutableArray array] retain];
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"position.png"] style:UIBarButtonItemStylePlain target:self action:@selector(userZoom)] autorelease];
    }

- (CLLocationManager *)locationManager {
	
    if (locationManager != nil) {
		return locationManager;
	}
	
	locationManager = [[CLLocationManager alloc] init];
	[locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
	[locationManager setDelegate:self];
	
	return locationManager;
}

- (void) userZoom{
    if (userLocation != nil) {
        if(!isZoomed) {
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 500, 500);
            // for correcting map aspect view
            MKCoordinateRegion adjustRegion = [self.mapView regionThatFits:region]; 
            [self.mapView setRegion:adjustRegion animated:YES];
            isZoomed = YES;
        }
        else if (isZoomed) {
            isZoomed = NO;
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 8000, 8000);
            // for correcting map aspect view
            MKCoordinateRegion adjustRegion = [self.mapView regionThatFits:region]; 
            [self.mapView setRegion:adjustRegion animated:YES];
        }
        
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"Kan ej faställa din position."  delegate:self cancelButtonTitle:nil otherButtonTitles: @"OK", nil];
        [alert show];
        [alert release];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [self setDefaultMapLocation];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    self.mapView.showsUserLocation = YES;
        
    // Start activity indicator.
	if([FactoryProvider getCurrentUnitInformation].currentUnitType == CARE_UNIT){
		self.title=@"Vårdcentraler";
	}else if([FactoryProvider getCurrentUnitInformation].currentUnitType == DUTY_UNIT){
		self.title=@"Jourmottagningar";
	}else if([FactoryProvider getCurrentUnitInformation].currentUnitType == EMERGENCY_UNIT){
		self.title=@"Akutmottagningar";
	}
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //isLoading = YES;
    //[self loadsDataHUD:@"Hämtar platser"];
    
    // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	
    // Add HUD to screen
    [self.navigationController.view addSubview:HUD];
	
    // Regisete for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
	
    HUD.labelText = @"Ansluter";
	[HUD show:YES];
	[[FactoryProvider getUnitDataProviderInstance] loadCurrentUnits];
}

-(void)OnUnitDataProviderLoaded: (NSNotification *) notification{
	NSMutableDictionary *units = [notification userInfo];
	[self PopulateAnnotations:units];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;	
    //isLoading = NO;
	[HUD hide:YES];
	HUD = nil;
    for (int i = 0; i < [areaPoints count]; i++) {
		[[areaPoints objectAtIndex:i] updateDistance:self.userLocation];
	}
    [self sortTableListView];
}

-(void)OnUnitDataProviderLoadedFailed: (NSNotification *) notification{
	[HUD hide:YES];
	HUD = nil;
   	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Kopplingsfel" message:@"Ingen kontakt med server eller ingen internetuppkoppling." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

-(void)PopulateAnnotations: (NSMutableDictionary*) units  
{
	[self.mapView removeAnnotations:self.mapView.annotations];
	[self.areaPoints removeAllObjects];
	for (CareUnit *careUnit in [units objectEnumerator])
	{
		AreaAnnotation *tempAreaAnnotation = [[[AreaAnnotation alloc]init]autorelease];
		tempAreaAnnotation.latitude = careUnit.latitude;
		tempAreaAnnotation.longitude = careUnit.longitude;
		tempAreaAnnotation.areaId = careUnit.hsaIdentity;
		tempAreaAnnotation.title = careUnit.name;	
		tempAreaAnnotation.careUnit = careUnit;
		//tempAreaAnnotation.subtitle = @"Beräknad kötid: 34 min";
		
		[self.areaPoints addObject:tempAreaAnnotation];
	}
	[self.mapView addAnnotations:self.areaPoints];	
}

-(void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning 
{
	[super didReceiveMemoryWarning];
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	
	AreaAnnotation *areaAnnotation = (AreaAnnotation*) view.annotation;		
	self.detailViewController.unit =  areaAnnotation.careUnit; 
	[self.navigationController pushViewController:self.detailViewController animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
        
    // test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0) return;
    // test the age of the location measurement to determine if the measurement is cached
    // in most cases you will not want to rely on cached measurements
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
    
    [userLocation release];
    userLocation = newLocation;
    [userLocation retain];
    
	for (int i = 0; i < [areaPoints count]; i++) {
		[[areaPoints objectAtIndex:i] updateDistance:newLocation];
	}
    [self sortTableListView];
    
    if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
        [locationManager stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if ([error code] != kCLErrorLocationUnknown) {
        [self stopUpdatingLocation:NSLocalizedString(@"Error", @"Error")];
    }
}

//Stop updating the user location
- (void)stopUpdatingLocation:(NSString *)state {
    [locationManager stopUpdatingLocation];
    locationManager.delegate = nil;
}

#pragma mark -
#pragma mark List vy av kartdata
-(IBAction)changeSeg{
	if(Segment.selectedSegmentIndex == 0){
		[[self view]sendSubviewToBack:tableView];
		[[self view]bringSubviewToFront:mapView];
		self.isMapSegment = TRUE;
	}
    
	if(Segment.selectedSegmentIndex == 1){
		self.isMapSegment = FALSE;	
		[[self view]sendSubviewToBack:mapView];
		[[self view]bringSubviewToFront:tableView];
	}
	[[self view]bringSubviewToFront:Segment];
}

-(void)sortTableListView{
	if (userLocation != nil) {
		NSSortDescriptor *distanceSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distanceInMeters" ascending:YES];
		[areaPoints sortUsingDescriptors:[NSArray arrayWithObject:distanceSortDescriptor]];
		[distanceSortDescriptor release];			 
	}
	
	else {			
        //Sorts the areapoints array by title since current GPS location cannot be found.			
		NSSortDescriptor *titleSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
		[areaPoints sortUsingDescriptors:[NSArray arrayWithObject:titleSortDescriptor]];
		[titleSortDescriptor release];
	}
    [tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [areaPoints count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)thisTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString *CellIdentifier = @"Cell";
	AreaAnnotation * areaPoint = [areaPoints objectAtIndex:[indexPath row]];
    UITableViewCell *cell = [thisTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {		
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    } 
	
	cell.textLabel.text = [[areaPoint careUnit]name];
	cell.textLabel.numberOfLines = 0; //Separera text i flera rader
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    
	if (areaPoint.distanceInMeters < 1000) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f%@%@", areaPoint.distanceInMeters, @" m, ",areaPoint.careUnit.locale];
		//cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f%@%@, Kötid: 34 min", areaPoint.distanceInMeters, @" m, ",areaPoint.careUnit.locale];
	}
	else if (areaPoint.hasDistance == FALSE) {
        cell.detailTextLabel.text = [@"Avstånd saknas, " stringByAppendingString:areaPoint.careUnit.locale];
	}
    
	else {
		float distanceInKm = areaPoint.distanceInMeters / 1000;
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f%@%@", distanceInKm, @" km, ", areaPoint.careUnit.locale];
        //cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f%@%@, Kötid: 34 min", distanceInKm, @" km, ", areaPoint.careUnit.locale];
	}	
	
	UIImage *flagImage = [UIImage imageNamed:@"oppet_symbol.png"];
	if (![areaPoint.careUnit isCenterOpen]) {
		flagImage = [UIImage imageNamed:@"stangt_symbol.png"];		
	}	
	
	cell.imageView.image = flagImage;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self pushDetailViewController:indexPath];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	[self pushDetailViewController:indexPath];	
}

-(void) pushDetailViewController:(NSIndexPath *)index
{
	AreaAnnotation *areaAnnotation = [areaPoints objectAtIndex: index.row];		
	self.detailViewController.unit =  areaAnnotation.careUnit;	
	
	[self.navigationController pushViewController:self.detailViewController animated:YES];	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat     result = 34.0f;
	NSString*   text = nil;
	CGFloat     width = 300.0f;      
	text = [[[areaPoints objectAtIndex:[indexPath row]]careUnit]name];
		
	if (text) {
		CGSize textSize = { width, 20000.0f };
		CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];
		size.height += 40.0f;
		result = MAX(size.height, 40.0f);
	}
    return result;
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    [HUD release];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.locationManager = nil;
    self.mapView = nil;
	self.areaPoints = nil;
	self.detailViewController = nil;
	//self.Segment = nil;
	self.tableView = nil;
	self.isMapSegment = nil;
	HUD = nil;
    self.userLocation = nil;
}

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter]removeObserver:self];
	[detailViewController release];
	[Segment release];
    [userLocation release];
	[HUD dealloc];
	[areaPoints release];
	mapView.delegate = nil;
	[mapView release];
	mapView.showsUserLocation = NO;
	[tableView release];
	//[Segment release];
    locationManager.delegate = nil;
    [locationManager release];
	[super dealloc];
}

@end
