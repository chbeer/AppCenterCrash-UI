//
//  Test.swift
//  AppCenterCrash-UI
//
//  Created by Christian Beer on 14.04.20.
//

#import "AppCenterCrashUIManager.h"

#import "AppCenterCrashDetailsWindowController.h"

@import AppCenterCrashes;


@implementation AppCenterCrashUIManager (macOS)

- (BOOL) userConfirmationHandler:(NSArray<MSErrorReport*>*)reports
{
    NSString *appName = [NSBundle.mainBundle objectForInfoDictionaryKey:kCFBundleNameKey];
    
    AppCenterCrashDetailsWindowController *ctrl = [[AppCenterCrashDetailsWindowController alloc] initWithErrorReports:reports
                                                                                                          companyName:self.companyName
                                                                                                      applicationName:appName
                                                                                                     privacyPolicyURL:self.privacyPolicyURL
                                                                                                       askUserDetails:YES];
    ctrl.delegate = (id<AppCenterCrashUIDelegate>)self;
    
    [ctrl askCrashReportDetails];
    
    return YES;
}

@end
