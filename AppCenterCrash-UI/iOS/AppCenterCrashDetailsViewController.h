//
//  AppCenterCrashDetailsViewController.h
//  AppCenterCrash-UI-iOS
//
//  Created by Christian Beer on 17.11.14.
//  Copyright (c) 2014 Christian Beer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppCenterCrashUIManager.h"

/*! View controller that provides (nearly) the same dialog as the HockeySDK-Mac BITCrashReportUI window.
 */
@interface AppCenterCrashDetailsViewController : UITableViewController

@property (nonatomic, weak) id<AppCenterCrashUIDelegate> delegate;
                                                                                                   
@property (nonatomic, strong, readonly) NSArray<MSErrorReport*> *errorReports;
@property (nonatomic, strong, readonly) NSString                *companyName;
@property (nonatomic, strong, readonly) NSString                *applicationName;

/*! Initialize with details about the crash and the app's name 
 *
 * @param errorReports Details about the crash as given by AppCenter.
 * @param appName Name of the app to show in the dialog.
 * @return initialized instance.
 */
- (instancetype) initWithErrorReports:(NSArray<MSErrorReport*>*)errorReports
                          companyName:(NSString *)companyName
                      applicationName:(NSString *)applicationName
                      privacyPolicyURL:(NSURL*)privacyPolicyURL;

@end