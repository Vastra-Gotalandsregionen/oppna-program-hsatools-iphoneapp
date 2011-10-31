//
//  CurrentUnitInformation.m
//  HRIVIPhoneApp
//


#import "CurrentUnitInformation.h"


@implementation CurrentUnitInformation

@synthesize currentUnitType;


-(void) dealloc{
	[currentUnitType release];
	[super dealloc];
}

@end
