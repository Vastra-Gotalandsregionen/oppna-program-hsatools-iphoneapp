//
//  CareUnit.m
//  HRIVIPhoneApp
//

#import "CareUnit.h"

@implementation CareUnit

@synthesize latitude, longitude,  name, locale, hsaPublicTelephoneNumber, hsaTelephoneTime, hsaRoute,hsaDropInHours,  hsaVisitingRuleAge,   description,hsaSurgeryHours,hsaManagementCodeText, hsaIdentity, labeleduri;


- (Boolean) isCenterOpen{
	Boolean returnValue = NO;
	
	// Get todays date.
	NSDate *today = [NSDate date];
    //NSDate * today = [[NSDate alloc] initWithString:@"2011-05-22 10:45:32 +0200"];
	NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];	
	
	// Create weekdayComponents to get current weekday from system date. and convert day in integer to day in string representation.
	NSDateComponents *weekdayComponents = [gregorian components:(NSDayCalendarUnit | NSWeekdayCalendarUnit) fromDate:today];
	
	
	NSInteger weekday = [weekdayComponents weekday];
    weekday = weekday - 1; //Sweden date and time
    if (weekday == 0) {
        weekday = 7;
    }
	NSString *currentDayInString = [self getWeekDayName:weekday];
    //NSLog(@"Day: %@", currentDayInString);
	NSMutableArray *officeHour = [hsaSurgeryHours objectForKey:currentDayInString] ;
	
	// Go through every opening Hours in a day.
	for (NSMutableDictionary *officeHourItem in  officeHour) {
	
		// Create NSDateComponents from a care unit opening time ond closing time. 
		NSString *openingTime = [officeHourItem objectForKey:@"openingHour"];
		NSString *closingTime = [officeHourItem objectForKey:@"closingHour"];
		
		// Create systemdates and set time to opening time and closing time. To enable comparing against current system date. 
		NSDateComponents *openingComponents = [self createDateComponentsFromString:openingTime];
		NSDateComponents *closingComponents = [self createDateComponentsFromString:closingTime];
		
		NSDate *openingDateResult = [gregorian dateFromComponents:openingComponents];
		NSDate *closingDateResult = [gregorian dateFromComponents:closingComponents];		
		
		// Convert dates to time intervals in double from 1970
		NSTimeInterval openingSince1970 =[openingDateResult timeIntervalSince1970];
		NSTimeInterval closingSince1970 =[closingDateResult timeIntervalSince1970];
		
			//Om öppettiden sträcker sig över ett dygn blir skillnaden negativ och vi lägger på ett dygn (86400 sekunder) på stängningstiden.
		NSTimeInterval difference = [closingDateResult timeIntervalSinceDate:openingDateResult];
		
		if (difference < 0) {
				closingSince1970 += 86400;
		}

		NSTimeInterval todaySince1970 =[today timeIntervalSince1970];
		
		
		// Check that current date is between opening time and closing time.
		if (todaySince1970 >= openingSince1970 && todaySince1970 <= closingSince1970) {
			returnValue = YES;
			break;
		}
	}
		[gregorian release];
		return returnValue;
}

-(NSString*) getOpeningHoursAsString{
	return [self createOfficeHours:hsaSurgeryHours defaultValue:@"Uppgifter saknas"];
}


- (NSString *) getPhoneHoursAsString{
	return [self createOfficeHours:hsaTelephoneTime defaultValue:@"Uppgifter saknas"];
}

- (NSString *) getHsaDropInHours{
	return [self createOfficeHours:hsaDropInHours defaultValue:@"Ingen dropin"];
}			

- (NSString*) createOfficeHours:(NSMutableDictionary*) officeHours defaultValue: (NSString*) defValue{
	if (officeHours == nil || ([officeHours count] == 0)) {
		return defValue;
	}
	
		// All days and opening hours for a unit
	NSMutableDictionary *openingHours = [[NSMutableDictionary alloc] init];							
		 
	
	// Go through all opening hours for a unit.
	for (NSString * day in [hsaSurgeryHours allKeys]) {
		
			// Fetch one day
		NSMutableArray * openingAndClosingTimes = [officeHours objectForKey:day];
		//NSLog([NSString stringWithFormat:@"DAY: %@", day]);
		NSString * officeHoursCurrentDay = @"";

		// Convert to NSDate weekday specifier
		NSNumber * weekdayNumber = [NSNumber numberWithInt:[self getWeekDayNumber:day]];

		//More then one time per day?
		for (NSDictionary * time in openingAndClosingTimes) {
				// Fetch opening & closing hours for the current day
			NSString * opening = [time objectForKey:@"openingHour"];
			NSString * closing = [time objectForKey:@"closingHour"];

				// Format openinghours
			officeHoursCurrentDay = [NSString stringWithFormat:@"%@ - %@", opening, closing];
			
				// Convert if its all hours
			if ([officeHoursCurrentDay isEqualToString: @"00:00 - 24:00"]) {
				officeHoursCurrentDay = @"Dygnet runt";
			}
			
				// Handle multiple opening/closing hours
			[self addValueToDictionary: openingHours withValue: weekdayNumber forKey: officeHoursCurrentDay];
		}
	}
	
	
	

	NSString *result = @"";	

	//Every Hour
	NSMutableArray * reverseSortOrderList = [[[NSMutableArray alloc] init] autorelease]; 
	
	for(NSString *daysAndHours in [openingHours allKeys]){		
		NSMutableArray * days = [openingHours objectForKey: daysAndHours];
		
		[days sortUsingFunction:lengthSort context:nil];
		
		NSString *daySpan = @"";
		//int tmpDay = 0;
		
		for (int i = 0; i < [days count]; i++) {
			
			int currentDay = [[days objectAtIndex:i]intValue];
			
			if (i == 0 ) {
				daySpan = [daySpan stringByAppendingString:[self getWeekDayNameInSwedish: currentDay]];
			} 
			
			if ((i == [days count] -1)) {
				daySpan = [daySpan stringByAppendingString:@"- "];
				daySpan = [daySpan stringByAppendingString:[self getWeekDayNameInSwedish: currentDay]];
			}
		}
		
		if ([daySpan isEqualToString: @"Mån - Sön "]) {
			daySpan = @"";
		}
		
		daySpan = [daySpan stringByAppendingString:daysAndHours];		
		[reverseSortOrderList addObject:daySpan];				
	}
	
	for (NSString *dayResult in reverseSortOrderList){
		result = [result stringByAppendingString:dayResult];
		result = [result stringByAppendingString:@"\n"];
	}
	[openingHours release];
	
	return result;
	
}


int lengthSort( id obj1, id obj2, void *context ) {
		// Get string lengths
	int int1 = [obj1 intValue];
	int int2 = [obj2 intValue];
	
		// Compare and return
	if( int1 < int2 )
		return NSOrderedAscending;
	else if( int1 == int2 )
		return NSOrderedSame;
	else
		return NSOrderedDescending;
} // lengthSort( id, id, void * )



-(void) addValueToDictionary: (NSMutableDictionary *) arrOpeningHours withValue: (NSNumber *) numWeekday forKey: (NSString *) strHours {

	// Fetch opening hours for the current 
	NSMutableArray * days =  [arrOpeningHours objectForKey: strHours];
	
	if (days == nil) {
		NSMutableArray * days = [[NSMutableArray alloc] init];
		[days addObject:numWeekday];
		[arrOpeningHours setObject:days forKey:strHours];
		[days release];
		days = nil;
	} else {
		[days addObject:numWeekday];
	}
} 

- (NSDateComponents *) createDateComponentsFromString: (NSString *) timeString{
	
	NSDateComponents *returnValueDateComponent = nil;//[[NSDateComponents alloc] autorelease];

	
	// Split time string with regex ":" to get hours and minutes in an array.
	NSArray *chunks = [timeString componentsSeparatedByString: @":"];
	
	NSDate *today = [NSDate date];
    //NSDate * today = [[NSDate alloc] initWithString:@"2011-05-22 10:45:32 +0200"];
	NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];	
	
	returnValueDateComponent = [gregorian components:( NSWeekdayCalendarUnit | 
															 NSYearCalendarUnit | NSMonthCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSWeekCalendarUnit) fromDate:today];
	
	[gregorian release];
	gregorian = nil;
	
	// Set new hours and minutes for current time dateComponent.
	[returnValueDateComponent setHour:[[chunks objectAtIndex:0]integerValue]]; 
	[returnValueDateComponent setMinute:[[chunks objectAtIndex:1]integerValue]]; 

	return returnValueDateComponent;
}

// American standard sets sunday as day one of week.
- (NSString*) getWeekDayName: (int) dayNumber{
	NSString *dayName = nil;
	switch (dayNumber) {
		case 1:
			dayName = @"monday";
			break;
		case 2:
			dayName = @"tuesday";
			break;
		case 3:
			dayName = @"wednesday";
			break;
		case 4:
			dayName = @"thursday";
			break;
		case 5:
			dayName = @"friday";
			break;
		case 6:
			dayName = @"saturday";
			break;
		case 7:
			dayName = @"sunday";
			break;
		default:
			dayName = @"not valid";
			break;
	}
	return dayName;
}

- (int) getWeekDayNumber: (NSString *) dayName{
	int dayNumber = 0;
	if ([dayName isEqualToString:@"monday"]){
		dayNumber  = 1;
		}
		else if ([dayName isEqualToString:@"tuesday"]){
			dayNumber = 2;
		}
		else if ([dayName isEqualToString:@"wednesday"]){
			dayNumber = 3;
		}
		else if ([dayName isEqualToString:@"thursday"]) {
			dayNumber = 4;
		}
		else if ([dayName isEqualToString:@"friday"]){
			dayNumber = 5;
		}
		else if ([dayName isEqualToString:@"saturday"]){
			dayNumber = 6;
		}
		else if ([dayName isEqualToString:@"sunday"]){
			dayNumber = 7;
		}		
	
	return dayNumber;

}
- (NSString*) getWeekDayNameInSwedish: (int) dayNumber{
	NSString *dayName = nil;
	switch (dayNumber) {
		case 1:
			dayName = @"Mån ";
			break;
		case 2:
			dayName = @"Tis ";
			break;
		case 3:
			dayName = @"Ons ";
			break;
		case 4:
			dayName = @"Tors ";
			break;
		case 5:
			dayName = @"Fre ";
			break;
		case 6:
			dayName = @"Lör ";
			break;
		case 7:
			dayName = @"Sön ";
			break;
		default:
			dayName = @"Inte giltig ";
			break;
	}
	return dayName;
}

- (void)viewDidUnload {
    self.hsaIdentity = nil;
	self.hsaSurgeryHours = nil;
	self.name = nil;
	self.description = nil;	
	self.locale = nil;
	self.hsaPublicTelephoneNumber = nil;
	self.hsaTelephoneTime = nil;
	self.hsaRoute = nil;
	self.hsaDropInHours = nil;
	self.hsaVisitingRuleAge = nil;
	self.hsaManagementCodeText = nil;
	self.labeleduri = nil;
}

- (void) dealloc
{
	[hsaIdentity release];
	[hsaSurgeryHours release];
	[name release];
	[description release];	
	[locale release];
	[hsaPublicTelephoneNumber release];
	[hsaTelephoneTime release];
	[hsaRoute release];
	[hsaDropInHours release];
	[hsaVisitingRuleAge release];
	[hsaManagementCodeText release];
	[labeleduri release];
	[super dealloc];
}


@end
