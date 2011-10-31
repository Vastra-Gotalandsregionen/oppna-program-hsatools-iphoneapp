//
//  UnitDataProvider.m
//  HRIVIPhoneApp
//

#import "UnitDataProvider.h"
#import	"JSON.h"
#import "CareUnit.h"
#import "Constants.h"
#import "FactoryProvider.h"

// V.v. kontakta VGR för URL:er för data 

@implementation UnitDataProvider

@synthesize responseData;

-(BOOL) isEmpty{
    NSString* currentUnitType = [FactoryProvider getCurrentUnitInformation].currentUnitType;
	BOOL isEmpty = true;
    if([currentUnitType isEqualToString:CARE_UNIT]){
		if ([careUnits count] > 0) {
            isEmpty = false;
        }
	}
	else if ([currentUnitType isEqualToString:EMERGENCY_UNIT]){
        if ([emergencyUnits count] > 0) {
            isEmpty = false;
        }
	}
	else if ([currentUnitType isEqualToString:DUTY_UNIT]){
        if ([dutyUnits count] > 0) {
            isEmpty = false;
        }
	}
         return isEmpty;
	
}
-(void) loadCurrentUnits{
	NSString* currentUnitType = [FactoryProvider getCurrentUnitInformation].currentUnitType;
	if([currentUnitType isEqualToString:CARE_UNIT]){
		[self getCareUnits];
	}
	else if ([currentUnitType isEqualToString:EMERGENCY_UNIT]){
		[self getEmergencyUnits];
	}
	else if ([currentUnitType isEqualToString:DUTY_UNIT]){
		[self getDutyUnits];
	}
	
	
}
//Vårdmottagning
-(void) getCareUnits {	
    NSString* path = [[NSBundle mainBundle] pathForResource:@"Security" ofType:@"plist"];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSString *urlMethod = [plistDictionary objectForKey:@"CARE_UNITS_URL"];

	if (careUnits == nil) 
	{
		careUnits = [[NSMutableDictionary alloc] init];
		[self getDataFromServer:urlMethod];			
	}
	else {
		[[NSNotificationCenter defaultCenter] postNotificationName:UNIT_DATA_LOADED_SUCCESS_EVENT object:self userInfo:careUnits ];		
	}
	
}

//Jourmottagning
-(void *)getDutyUnits {
    NSString* path = [[NSBundle mainBundle] pathForResource:@"Security" ofType:@"plist"];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSString *urlMethod = [plistDictionary objectForKey:@"DUTY_UNITS_URL"];

	if (dutyUnits == nil) {
		dutyUnits = [[NSMutableDictionary alloc] init];
		[self getDataFromServer:urlMethod];		
	}
	else {		
		[[NSNotificationCenter defaultCenter] postNotificationName:UNIT_DATA_LOADED_SUCCESS_EVENT object:self userInfo:dutyUnits ];		
	}
	return 0;
}

	//Akutmottagning
- (void) getEmergencyUnits {
    NSString* path = [[NSBundle mainBundle] pathForResource:@"Security" ofType:@"plist"];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSString *urlMethod = [plistDictionary objectForKey:@"EMERGENCY_UNITS_URL"];
	
	if (emergencyUnits == nil) {
		emergencyUnits = [[NSMutableDictionary alloc] init];
		[self getDataFromServer:urlMethod];		
	}
	else {		
		[[NSNotificationCenter defaultCenter] postNotificationName:UNIT_DATA_LOADED_SUCCESS_EVENT object:self userInfo:emergencyUnits ];				
	}
}

-(void)getDataFromServer: (NSString *)urlMethod{
	self.responseData = [[NSMutableData data] retain];
    
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlMethod]
											 cachePolicy:NSURLRequestUseProtocolCachePolicy
										 timeoutInterval:60.0];
    
	[NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
	
}

//This error method only gets called if there was an actually error fetching the URL (like the network went down, or the host doesn't exist, etc).
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[responseData release];
	responseData = nil;
	[self stopApplication:@"Kopplingsfel" andUserFriendlyMessage:@"Ingen kontakt med server eller ingen internetuppkoppling." failedWithError:error];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[[NSNotificationCenter defaultCenter] postNotificationName:UNIT_DATA_LOADED_FAILED_EVENT object:self userInfo:nil];
}


-(void)stopApplication:(NSString*) alertWithTitle  andUserFriendlyMessage:(NSString*)userMessage failedWithError:(NSError*)errorMessage
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertWithTitle message:userMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alertView show];
	[alertView release];	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	[responseData release];
	
		// Create a dictionary from the JSON string
	NSDictionary *results = [responseString JSONValue];
    [responseString release];
    if ([results count] <= 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:UNIT_DATA_LOADED_FAILED_EVENT object:self userInfo:nil];
        return;
    }
    
	NSString* currentUnitType = [FactoryProvider getCurrentUnitInformation].currentUnitType;
	NSMutableDictionary *unitResult = nil;
    
	if([currentUnitType isEqualToString:CARE_UNIT])
	{
		unitResult =[self ReadAndMapCareUnitsFromJSON:results theJSONTupleKey:@"careUnits" theTypeOfUnit:CARE_UNIT];
	}
	else if ([currentUnitType isEqualToString:EMERGENCY_UNIT])
	{
		unitResult =[self ReadAndMapCareUnitsFromJSON:results theJSONTupleKey:@"emergencyUnits" theTypeOfUnit:EMERGENCY_UNIT];
	}
	else if ([currentUnitType isEqualToString:DUTY_UNIT])
	{
		unitResult =[self ReadAndMapCareUnitsFromJSON:results theJSONTupleKey:@"dutyUnits" theTypeOfUnit:DUTY_UNIT];
	}
	if (unitResult != nil) {
			[[NSNotificationCenter defaultCenter] postNotificationName:UNIT_DATA_LOADED_SUCCESS_EVENT object:self userInfo:unitResult ];		
	}

}

-(NSMutableDictionary *)ReadAndMapCareUnitsFromJSON:(NSDictionary *)responseDatas theJSONTupleKey: (NSString *)jSONTupleKey theTypeOfUnit:(NSString *) unitType{
	
		NSArray *unitsJSON = [responseDatas objectForKey:jSONTupleKey];
		
		if ([unitType isEqualToString:CARE_UNIT]) {
			for (NSDictionary *unitJSON in unitsJSON)
			{
				if (unitJSON != nil) {
					CareUnit* unit = [self TranslateJSONObjectToCareUnit: unitJSON];		
					[careUnits setObject:unit forKey:unit.hsaIdentity];	
				}
			}
			return careUnits;
		}
		else if ([unitType isEqualToString:DUTY_UNIT]) {
			for (NSDictionary *unitJSON in unitsJSON)
			{
				if (unitJSON != nil) {
				CareUnit* unit = [self TranslateJSONObjectToCareUnit: unitJSON];		
				[dutyUnits setObject:unit forKey:unit.hsaIdentity];			
				}
			}
			return dutyUnits;
		}
		else if ([unitType isEqualToString:EMERGENCY_UNIT]) {
			for (NSDictionary *unitJSON in unitsJSON)
			{
				if (unitJSON != nil) {
				CareUnit* unit = [self TranslateJSONObjectToCareUnit: unitJSON];	
				[emergencyUnits setObject:unit forKey:unit.hsaIdentity];			
				}
			}
			return emergencyUnits;
		}
	return 0;
}

-(CareUnit *)TranslateJSONObjectToCareUnit: (NSDictionary *) unitJSON
{
	CareUnit * genericUnit = [[CareUnit alloc]autorelease];
	genericUnit.latitude					= [[unitJSON objectForKey:@"latitude"] floatValue];
	genericUnit.longitude					= [[unitJSON objectForKey:@"longitude"] floatValue];
	genericUnit.name						= [unitJSON objectForKey:@"name"];
	genericUnit.hsaSurgeryHours				= [unitJSON objectForKey:@"hsaSurgeryHours"];
	genericUnit.hsaTelephoneTime			= [unitJSON objectForKey:@"hsaTelephoneTime"];
	genericUnit.hsaDropInHours				= [unitJSON objectForKey:@"hsaDropInHours"];
	genericUnit.hsaManagementCodeText		= [unitJSON objectForKey:@"hsaManagementCodeText"];
	genericUnit.locale						= [unitJSON objectForKey:@"locale"];
	genericUnit.description					= [unitJSON objectForKey:@"description"];
	genericUnit.hsaVisitingRuleAge			= [unitJSON objectForKey:@"hsaVisitingRuleAge"];
	genericUnit.hsaPublicTelephoneNumber	= [unitJSON objectForKey:@"hsaPublicTelephoneNumber"];
	genericUnit.labeleduri					= [unitJSON objectForKey:@"labeleduri"];
	genericUnit.hsaIdentity					= [unitJSON objectForKey:@"hsaIdentity"];
	
		return genericUnit;
}

- (void)dealloc {
	[careUnits release];
	[dutyUnits release];
	[emergencyUnits release];
    [super dealloc];
}
 

@end
