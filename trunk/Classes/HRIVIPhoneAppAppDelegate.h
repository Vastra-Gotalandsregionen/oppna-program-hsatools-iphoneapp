//
//  HRIVIPhoneAppAppDelegate.h
//  HRIVIPhoneApp
//

#import <UIKit/UIKit.h>

@interface HRIVIPhoneAppAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;


@end

