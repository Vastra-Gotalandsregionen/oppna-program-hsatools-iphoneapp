//
//  FactoryProvider.h
//  HRIVIPhoneApp
//


#import <Foundation/Foundation.h>
#import "UnitDataProvider.h"
#import "CurrentUnitInformation.h"

@interface FactoryProvider : NSObject {
}
+(UnitDataProvider*) getUnitDataProviderInstance;
+(CurrentUnitInformation*) getCurrentUnitInformation;
+(NSMutableDictionary*) getCurrentUnits;

@end
