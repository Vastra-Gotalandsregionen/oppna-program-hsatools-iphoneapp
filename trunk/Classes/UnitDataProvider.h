//
//  UnitDataProvider.h
//  HRIVIPhoneApp
//


#import <Foundation/Foundation.h>
#import "CareUnit.h"

@interface UnitDataProvider : NSObject {
	NSMutableDictionary * careUnits;
	NSMutableDictionary	* emergencyUnits;
	NSMutableDictionary * dutyUnits;
	NSMutableData *responseData;
	int activeUnit;
}

@property (nonatomic, retain) NSMutableData *responseData;

-(BOOL) isEmpty;
-(void) loadCurrentUnits;
-(void) getCareUnits;
- (void) getEmergencyUnits;
-(void *)getDutyUnits;
-(void)getDataFromServer: (NSString *)urlMethod;
-(void)stopApplication:(NSString*) alertWithTitle
andUserFriendlyMessage:(NSString*) userMessage
	   failedWithError:(NSError*) errorMessage;
-(NSMutableDictionary *)ReadAndMapCareUnitsFromJSON:(NSDictionary *)responseData theJSONTupleKey: (NSString *)jSONTupleKey theTypeOfUnit:(NSString *) unitType;
-(CareUnit *)TranslateJSONObjectToCareUnit:(NSDictionary *)unitJSON;
@end
