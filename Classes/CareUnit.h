//
//  CareUnit.h
//  HRIVIPhoneApp
//
//	The CareUnit class serves as a data transfer object for the VGR domainobject "Unit".
//	The naming conventions for properties on the real VGR domain name (for easy mapping to the webservice)

@interface CareUnit : NSObject {
	
	
	NSString *hsaIdentity;
	NSMutableDictionary *hsaSurgeryHours;
	NSString *name;
	NSString *description;	
	float latitude;							
	float longitude;
	NSString *locale;
	NSString *hsaPublicTelephoneNumber;		
	NSMutableDictionary *hsaTelephoneTime;
	NSString *hsaRoute;
	NSMutableDictionary *hsaDropInHours;
	NSString *hsaVisitingRuleAge;
	NSString *hsaManagementCodeText;
	NSString *labeleduri;

}



@property(nonatomic,retain) NSString *hsaIdentity;
@property(nonatomic,retain) NSMutableDictionary *hsaSurgeryHours;
@property(nonatomic,retain) NSString *name;
@property(nonatomic,retain) NSString *description;	
@property(nonatomic) float latitude;							
@property(nonatomic) float longitude;
@property(nonatomic,retain) NSString *locale;
@property(nonatomic,retain) NSString *hsaPublicTelephoneNumber;		
@property(nonatomic,retain) NSMutableDictionary *hsaTelephoneTime;
@property(nonatomic,retain) NSString *hsaRoute;
@property(nonatomic,retain) NSMutableDictionary *hsaDropInHours;
@property(nonatomic,retain) NSString *hsaVisitingRuleAge;
@property(nonatomic,retain) NSString *hsaManagementCodeText;
@property(nonatomic,retain) NSString *labeleduri;

- (Boolean) isCenterOpen;
- (NSString*) getOpeningHoursAsString;
- (NSString*) getPhoneHoursAsString;
- (NSString*) getHsaDropInHours;
- (NSString*) getWeekDayName: (int) dayNumber;
- (NSDateComponents *) createDateComponentsFromString: (NSString *) timeString;
- (NSString*) createOfficeHours:(NSMutableDictionary*) officeHours defaultValue: (NSString*) defValue;
-(void) addValueToDictionary: (NSMutableDictionary *) arrOpeningHours withValue: (NSNumber *) numWeekday forKey: (NSString *) strHours;
- (int) getWeekDayNumber: (NSString *) dayName;
- (NSString*) getWeekDayNameInSwedish: (int) dayNumber;

int lengthSort( id obj1, id obj2, void *context );

@end
