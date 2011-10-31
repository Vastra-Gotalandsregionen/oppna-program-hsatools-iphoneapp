//
//  DetailViewController.m
//  HRIVIPhoneApp
//


#import "DetailViewController.h"
#import "CareUnit.h"
#import "MultipleStringObject.h"
#import "HRIVIPhoneAppAppDelegate.h"

#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 20.0f
#define TAG_PHONE_BUTTON 1
#define TAG_URI_BUTTON 2
#define TAG_ROUTE_BUTTON 3
#define K_CELL_WITH_BUTTONS @"CellWithButtons"

NSString * const PHONE_MISSING_STRING = @"Nummer saknas";
NSString * const URI_MISSING_STRING = @"Webbplats saknas";
NSString * const UNIT_GPS_POSITION_MISSING = @"Adress saknas";

@implementation DetailViewController
@synthesize hsaIdentity, unitNameLabel, openingHoursTextView, dropinLabel, visitingRuleAgeLabel, descriptionTextView, managementLabel, unit, tableView, listOfDescriptionItems, listOfContactInfoItems, scrollView, locationManager, userLocation;


- (UILabel *)convertTextToLabel:(NSString *)labelText isHeading: (Boolean) isBold {
	UILabel *label = [[[UILabel alloc] init] autorelease];		
	label.lineBreakMode = UILineBreakModeWordWrap;
	label.numberOfLines = 0;
	
	NSString *fontName = @""; 
	
	if (isBold)
		fontName = @"Helvetica-Bold";
	else {
		fontName = @"Helvetica";
	}
	
	label.font = [UIFont fontWithName:fontName size:14];
	label.text = labelText;
	
	CGSize maximumLabelSize = CGSizeMake(296,9999);
	
	CGSize expectedLabelSize = [labelText sizeWithFont:label.font 
									  constrainedToSize:maximumLabelSize 
										  lineBreakMode:label.lineBreakMode]; 


	label.frame = CGRectMake(25.0f, 5.0f, 275.0f, expectedLabelSize.height);
	
	return label;
}

- (void)populateUnitDetails {	
	if (self.unit != nil)
	{
		if ([contactInfoList count] > 0 || [detailsList count] > 0 || [descriptionList count] > 0 ) {
			[contactInfoList removeAllObjects];
			[detailsList removeAllObjects];
			[descriptionList removeAllObjects];
			
		}
		detailsList = [[NSMutableArray array]retain];
		contactInfoList = [[NSMutableArray array]retain];
		descriptionList = [[NSMutableArray array]retain];
				
		MultipleStringObject * openingHoursObject = [[MultipleStringObject alloc]autorelease];
		openingHoursObject.string1 = @"Öppettider";
		openingHoursObject.string2 = [unit getOpeningHoursAsString];		
		[detailsList addObject: openingHoursObject];
		
		MultipleStringObject * dropinObject = [[MultipleStringObject alloc]autorelease];
		dropinObject.string1 = @"Dropin";
		dropinObject.string2 = [unit getHsaDropInHours];		
		[detailsList addObject: dropinObject];				
		
		MultipleStringObject * managementInfoObject = [[MultipleStringObject alloc]autorelease];
		managementInfoObject.string1 = @"Drivs av";
		
		if([self.unit.hsaManagementCodeText isEqualToString: @"Landsting/Region"]) {
			managementInfoObject.string2 = @"Offentlig vårdgivare";					
		}
		else if([self.unit.hsaManagementCodeText isEqualToString: @"Privat, vårdavtal"]){
			managementInfoObject.string2 = @"Privat vårdgivare";
		}
			
		else {
			managementInfoObject.string2 = @"Uppgifter saknas";				
		}
		[detailsList addObject: managementInfoObject];
				
		MultipleStringObject * visitingRuleAgeObject = [[MultipleStringObject alloc]autorelease];
		visitingRuleAgeObject.string1 = @"Tar emot åldersintervall";
		//[detailsList addObject: [self convertTextToLabel:@"Tar emot åldersintervall" isHeading:YES]];
		
		if([self.unit.hsaVisitingRuleAge isEqualToString: @"0-99"]) {
			visitingRuleAgeObject.string2 = @"Alla åldrar";					
		}
		
		else if([self.unit.hsaVisitingRuleAge isEqualToString: @"16-99"]) {
			visitingRuleAgeObject.string2 = @"16 år eller äldre";					
		}
		
		else {
			visitingRuleAgeObject.string2 = self.unit.hsaVisitingRuleAge;				
		}
		
		[detailsList addObject: visitingRuleAgeObject];
								
		//Items for contact information section		
		MultipleStringObject * phoneHoursObject = [[MultipleStringObject alloc]autorelease];
		phoneHoursObject.string1 = @"Telefontid";
		phoneHoursObject.string2 = [unit getPhoneHoursAsString];		
		[contactInfoList addObject: phoneHoursObject];		
		
		MultipleStringObject * phoneNumberObject = [[MultipleStringObject alloc]autorelease];		
		//Check if there is a number
		if ([self isValid:self.unit.hsaPublicTelephoneNumber]) {		
			
			NSRange countryMatch = [self.unit.hsaPublicTelephoneNumber rangeOfString:@"+46"];
				//Check if string contains +46
			if (countryMatch.location == NSNotFound) {
				phoneNumberObject.string1 = self.unit.hsaPublicTelephoneNumber;
			}
			else {
					//Removes +46 from the telephonenumber given by the web service.
				NSMutableString * phoneNumberWithoutLanguageCode = [NSMutableString stringWithString:self.unit.hsaPublicTelephoneNumber];
				[phoneNumberWithoutLanguageCode replaceCharactersInRange:countryMatch withString:@"0"];
				phoneNumberObject.string1 = phoneNumberWithoutLanguageCode;
				
			}
			
			
		}
		else {			
			phoneNumberObject.string1 = PHONE_MISSING_STRING;//@"Nummer saknas";
		}
	
		//Webbpage in same phone object because ease of traversing in table
		//Check if there is a valid url
		if ([self isValid:self.unit.labeleduri]) {			
			phoneNumberObject.string2 = self.unit.labeleduri;			
		}
		else {
			phoneNumberObject.string2 = URI_MISSING_STRING; //@"Webbplats saknas";			
		}
		
		[contactInfoList addObject: phoneNumberObject];		

			//Lägg till plats för enhet
		if (unit.latitude > 0 && unit.longitude > 0) {
			CLLocation *location = [[CLLocation alloc]initWithLatitude:unit.latitude longitude:unit.longitude];
			[contactInfoList addObject:location];
			[location release];
		}
		else {
			[contactInfoList addObject:UNIT_GPS_POSITION_MISSING];
		}
		
		//Items for description section		
		MultipleStringObject * descriptionObject = [[MultipleStringObject alloc]autorelease];
		descriptionObject.string1 = @"";
		descriptionObject.string2 = self.unit.description;	
		
		[descriptionList addObject: descriptionObject];	
	}
}
	//Kan inte göra en bättre koll eftersom det kommer in +46 i vissa enheter.
-(Boolean) isValid:(NSString *) number {
	if([number length] == 0)
		return NO;
	return YES;
}

-(UIButton *) convertPhoneNumberToButton: (NSString*) buttonTitle {
	
	UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.frame = CGRectMake(10, 12, 140, 35);
	[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	button.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE];	
	button.backgroundColor = [UIColor clearColor];
	[button setTitle:[NSString stringWithFormat:@"%@", buttonTitle] forState:UIControlStateNormal];
	button.tag = TAG_PHONE_BUTTON;
	[button addTarget:self action:@selector(makeTheCall:) forControlEvents:UIControlEventTouchUpInside];
	return button;
}

-(UIButton *) convertLocationToButton: (NSString*) buttonTitle {
	
	UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.frame = CGRectMake(10, 12, 300, 35);
	[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	button.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE];	
	button.backgroundColor = [UIColor clearColor];
	button.tag = TAG_ROUTE_BUTTON;
	[button setTitle:buttonTitle forState:UIControlStateNormal];
	[button addTarget:self action:@selector(routeMeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	return button;
}

-(UIButton *) convertURIToButton: (NSString*) uri{	
	UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.frame = CGRectMake(160, 12, 150, 35);
	[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	button.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
	button.backgroundColor = [UIColor clearColor];
	button.tag = TAG_URI_BUTTON;
	[button setTitle:@"Webbplats" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(goToWebPage:) forControlEvents:UIControlEventTouchUpInside];
	return button;
}

-(void) makeTheCall: (id) sender{
	NSString *number = self.unit.hsaPublicTelephoneNumber;
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"tel://",[number stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
}

-(void) goToWebPage: (id) sender{
	NSString* url = [self secureWebRequest:self.unit.labeleduri];	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}

-(void) routeMeButtonClicked: (id) sender {    
	if (userLocation != nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Färdbeskrivning" message:@"Du lämnar nu applikationen för att se färdbeskrivningen i en annan applikation."  delegate:self cancelButtonTitle:@"Avbryt" otherButtonTitles: @"OK", nil];
        [alert show];
        [alert release];
	}
	else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Din position kunde inte hittas!" message:@"Färdbeskrivning kan inte visas eftersom din position saknas."  delegate:self cancelButtonTitle:nil otherButtonTitles: @"OK", nil];
        [alert show];
        [alert release];
	}
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        NSString *urlString = @"http://maps.google.com/maps?";		
        NSString *saddrString = [NSString stringWithFormat:@"%@%f%@%f%@", @"saddr=", userLocation.coordinate.latitude, @", ", userLocation.coordinate.longitude, @"&"];
        NSString *daddrString = [NSString stringWithFormat:@"%@%f%@%f", @"daddr=", unit.latitude, @", ", unit.longitude];		
        NSString * urlPath = [NSString stringWithFormat:@"%@%@%@", urlString, saddrString, daddrString];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[urlPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];	
    }
}

-(NSString*)secureWebRequest:(NSString*) url {
	NSURL* result = [[[NSURL alloc] initWithString:url] autorelease];
	NSRange schemaMarkerRange = [url rangeOfString: @"://"];
	if (schemaMarkerRange.location == NSNotFound) {
		result = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", url]];
	}
	else {//Some weird url - do nothing
	}

    return [result absoluteString];		
}

- (void)loadView {
	
	// create a new table using the full application frame
	// we'll ask the datasource which type of table to use (plain or grouped)
	UITableView *thetableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 370) style:UITableViewStylePlain]; 
	
	// set the autoresizing mask so that the table will always fill the view
	thetableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	
	// set the cell separator to a single straight line.
	thetableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
	// set the tableview delegate to this object and the datasource to the datasource which has already been set
	thetableView.delegate = self;
	thetableView.dataSource = self;
	
	thetableView.sectionIndexMinimumDisplayRowCount=10;
	
	// set the tableview as the controller view
    self.tableView = thetableView;
	self.view = thetableView;
	[thetableView release];
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self locationManager] startUpdatingLocation];
}

- (CLLocationManager *)locationManager {
	
    if (locationManager != nil) {
		return locationManager;
	}
	
	locationManager = [[CLLocationManager alloc] init];
	[locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
	[locationManager setDelegate:self];
	
	return locationManager;
}

//Updating user's location
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
    
    if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
        [locationManager stopUpdatingLocation];
        locationManager.delegate=nil;
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

- (void) viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	
	[self populateUnitDetails];	
	self.title=@"Information";
	
	if ([detailsList count] > 0) {
		NSIndexPath *ip = [NSIndexPath indexPathForRow: 0 inSection:0];
		[self.tableView selectRowAtIndexPath:ip	animated:NO scrollPosition:UITableViewScrollPositionTop];		
	}

	[self.tableView reloadData];
	[self.tableView setNeedsDisplay];
	

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	return 3;	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	if(section == 0) {
		return [detailsList count];
	}
	else if(section == 1) {		
		return [contactInfoList count];		
	}
	else if(section == 2) {		
		return [descriptionList	count];		
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

	if(section == 0)
		return  [NSString stringWithFormat:@"%@%@%@", unit.name, @", ", unit.locale];
	else if (section == 1)
		return @"Kontaktinformation";
	else if (section == 2)
		return @"Beskrivning";
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	CGSize constraintSize = CGSizeMake(296, MAXFLOAT);
	MultipleStringObject *object = nil;
	CGSize labelSize; 
	
	if (indexPath.section == 0) {
		object = [detailsList objectAtIndex: indexPath.row]; 
		
	}
	if (indexPath.section == 1) {
		if (indexPath.row > 0) {
			return 60;
		}
		
		object = [contactInfoList objectAtIndex: indexPath.row]; 
	}
		
	if (indexPath.section == 2) {
		object = [descriptionList objectAtIndex: indexPath.row]; 
	}
	
	labelSize = [object.string2 sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];

	return labelSize.height + 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath {
		
	static NSString *SubTitleCellIdentifier = @"SubTitleCell";
	static NSString *ButtonCellIdentifier = @"ButtonCell";

	if (indexPath.section == 1 && indexPath.row == 1) { 
	
		UITableViewCell *buttonCell = nil;
		buttonCell = [tableview dequeueReusableCellWithIdentifier:ButtonCellIdentifier];
		
		if (buttonCell == nil) {
			buttonCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ButtonCellIdentifier] autorelease];		
			buttonCell.selectionStyle = UITableViewCellSelectionStyleNone;	
		}
			
			//PHONE BUTTON		
		/*UIView *teleButtonView = [buttonCell.contentView viewWithTag:TAG_ROUTE_BUTTON];
		[teleButtonView removeFromSuperview];*/
		UIButton *teleButton = nil;
		MultipleStringObject * object = [contactInfoList objectAtIndex:indexPath.row];
			
			//Inte giltigt nummer	
		if (object.string1 == PHONE_MISSING_STRING) {
			teleButton = [self convertPhoneNumberToButton:PHONE_MISSING_STRING];
			[teleButton setEnabled:NO];
		} 
			//Giltigt nummer 
		else	{
			teleButton = [self convertPhoneNumberToButton:[NSString stringWithFormat:@"%@%@",@"Ring ", object.string1]];
			[teleButton setEnabled:YES];
		}
		[buttonCell.contentView addSubview:teleButton];
		
			//URI BUTTON
			 UIView *uriButtonView = [buttonCell.contentView viewWithTag:TAG_URI_BUTTON];
			 UIButton *uriButton = nil;
			 
			 if (uriButtonView == nil) {
				if (object.string2 == URI_MISSING_STRING) {
					uriButton = [self convertURIToButton:URI_MISSING_STRING];
					[uriButton setEnabled:NO];
				}
				else {
				 uriButton = [self convertURIToButton:object.string2];	
				}				
			 
				 [buttonCell.contentView addSubview:uriButton];				
			 }	
			 else {
			 
				 uriButton = (UIButton*)[buttonCell.contentView viewWithTag:TAG_URI_BUTTON];
				 if (object.string2 == URI_MISSING_STRING) {					
					 [uriButton setTitle:URI_MISSING_STRING forState:UIControlStateNormal];
					 [uriButton setEnabled:NO];
				 }
				 else {
					 [uriButton setTitle:@"Webbplats" forState:UIControlStateNormal];
					 [uriButton setEnabled:YES];
				 }
			 }		
		return buttonCell;
	}
	
		//Kontaktinformation (route) sektion rad 3 (index 2)
	if (indexPath.section == 1 && indexPath.row == 2) {
		UITableViewCell *buttonCell = nil;
		buttonCell = [tableview dequeueReusableCellWithIdentifier:ButtonCellIdentifier];
		if (buttonCell == nil) {
			buttonCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ButtonCellIdentifier] autorelease];		
			buttonCell.selectionStyle = UITableViewCellSelectionStyleNone;	
		}
		
		UIView *routeButtonView = [buttonCell.contentView viewWithTag:TAG_ROUTE_BUTTON];
		[routeButtonView removeFromSuperview];
		UIButton *routeButton = nil;
		id object = [contactInfoList objectAtIndex:indexPath.row];
		
		
		if ([object isKindOfClass:[NSString class]] || unit.longitude <= 0 && unit.latitude <= 0) {
			routeButton = [self convertLocationToButton:UNIT_GPS_POSITION_MISSING];
			[routeButton setEnabled:NO];
		} 
			//Det finns en position 
		else if ([object isKindOfClass:[CLLocation class]])	{
			routeButton = [self convertLocationToButton:@"Färdbeskrivning"];
			[routeButton setEnabled:YES];
		}
		[buttonCell.contentView addSubview:routeButton];
		return buttonCell;
	}
	
	else {
		
		UITableViewCell *cell = nil;
		cell = [tableview dequeueReusableCellWithIdentifier:SubTitleCellIdentifier];
		
		 if (cell == nil) {
			 cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SubTitleCellIdentifier] autorelease];		
			 cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;			
			 cell.detailTextLabel.numberOfLines = 0;	
			 cell.selectionStyle = UITableViewCellSelectionStyleNone;
			 [cell.detailTextLabel sizeToFit];	
		 }
		 else {
			 
			 //Clear labels to avoid wrong information in wrong table section and cell.
			 cell.textLabel.text = @"";
			 cell.detailTextLabel.text = @"";
		 }

		if (indexPath.section == 0)	{
			MultipleStringObject * object = [detailsList objectAtIndex:indexPath.row];
			cell.textLabel.text = object.string1;
			cell.detailTextLabel.text = object.string2;			
		}
		if (indexPath.section == 1) {
		
			if (indexPath.row == 0) {
				MultipleStringObject * object = [contactInfoList objectAtIndex:indexPath.row];
				cell.textLabel.text = object.string1;	
				cell.detailTextLabel.text = object.string2;			
			}
		}
		
		else if (indexPath.section == 2) {
			
			MultipleStringObject * object = [descriptionList objectAtIndex:indexPath.row];		
			cell.detailTextLabel.text = object.string2;
		}
		return cell;
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.unitNameLabel = nil;
	self.openingHoursTextView = nil;
	self.dropinLabel = nil;
	self.managementLabel = nil;
	self.visitingRuleAgeLabel = nil;
	self.descriptionTextView = nil;
	self.tableView = nil;
	self.scrollView = nil;
	self.hsaIdentity = nil;	
	self.unit = nil;
	//detailsList = nil;
	//contactInfoList = nil;
	//descriptionList = nil;
	self.locationManager = nil;
    self.userLocation = nil;

}

- (void)dealloc {
    [super dealloc];
	[locationManager release];
    [userLocation release];
	[unitNameLabel release];
	[openingHoursTextView release];
	[dropinLabel release];
	[managementLabel release];
	[visitingRuleAgeLabel release];
	[descriptionTextView release];
	[tableView release];
	[scrollView release];
	[hsaIdentity release];	
	[unit release];
    //[detailsList release];
	//[contactInfoList release];
	//[descriptionList release];
}

@end
