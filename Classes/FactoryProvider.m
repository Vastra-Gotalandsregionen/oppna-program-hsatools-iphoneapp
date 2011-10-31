//
//  FactoryProvider.m
//  HRIVIPhoneApp
//


#import "FactoryProvider.h"
#import "UnitDataProvider.h"

@implementation FactoryProvider
	
	//UNITDATAPROVER
static UnitDataProvider *unitDataProviderInstance;

+(UnitDataProvider *)getUnitDataProviderInstance{
		if (unitDataProviderInstance == nil || [unitDataProviderInstance isEmpty] ) {
            unitDataProviderInstance = nil;
            unitDataProviderInstance = [[UnitDataProvider alloc]init];
		return unitDataProviderInstance;
		}
		else {
			return unitDataProviderInstance;
		}

	}

	//CURRENTUNITINFORMATION
static CurrentUnitInformation * currentUnitInformation;
+(CurrentUnitInformation *)getCurrentUnitInformation{
	if (currentUnitInformation == nil) {
		currentUnitInformation = [[CurrentUnitInformation alloc]init];
		return currentUnitInformation;
	}
	else {
		return currentUnitInformation;
	}
	
}

+(NSMutableDictionary*) getCurrentUnits
{
	return [[self getUnitDataProviderInstance] getCurrentUnits];
}

@end
