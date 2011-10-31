//
//  HRIVIPhoneAppAppDelegate.m
//  HRIVIPhoneApp
//

#import "HRIVIPhoneAppAppDelegate.h"

@implementation HRIVIPhoneAppAppDelegate

@synthesize window;
@synthesize navigationController; 

#pragma mark -
#pragma mark Application lifecycle

//- (void)applicationDidFinishLaunching:(UIApplication *)application {
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
    // Override point for customization after app launch
	
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
    
    return YES;
	
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
	
}

- (void)applicationWillEnterForeground:(UIApplication *)application{

}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
	
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}


@end

