//
//  AppDelegate.h
//  inspire
//
//  Created by Yuji on 2015/08/27.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
@interface InspireAppDelegate : UIResponder <UIApplicationDelegate,AppDelegate>

@property (strong, nonatomic) UIWindow *window;

+(id<AppDelegate>)appDelegate;

@end

