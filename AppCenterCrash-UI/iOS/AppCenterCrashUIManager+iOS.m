//
//  Test.swift
//  AppCenterCrash-UI
//
//  Created by Christian Beer on 14.04.20.
//

#import "AppCenterCrashUIManager+iOS.h"
#import "AppCenterCrashUIManager.h"

#import "AppCenterCrashDetailsViewController.h"

@import AppCenterCrashes;

@implementation AppCenterCrashUIManager (iOS)

- (BOOL) userConfirmationHandler:(NSArray<MSErrorReport*>*)reports// callback:(void(^)(BOOL, NSArray<MSErrorAttachmentLog*>*))callback
{
    NSString *appName = [NSBundle.mainBundle objectForInfoDictionaryKey:kCFBundleNameKey];
    
    AppCenterCrashDetailsViewController *ctrl = [[AppCenterCrashDetailsViewController alloc] initWithErrorReports:reports
                                                                                                      companyName:self.companyName
                                                                                                  applicationName:appName
                                                                                                 privacyPolicyURL:self.privacyPolicyURL];
    ctrl.delegate = (id<AppCenterCrashUIDelegate>)self;
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:ctrl];
    nc.modalPresentationStyle = UIModalPresentationFormSheet;
    
    UIViewController *vc = [self topViewController];
    [vc presentViewController:nc animated:YES completion:nil];
    
    return YES;
}

- (UIViewController*) topViewController
{
    UIViewController *topViewController = UIApplication.sharedApplication.keyWindow.rootViewController;
    while (topViewController.presentedViewController) {
        topViewController = topViewController.presentedViewController;
    }
    return topViewController;
}

@end
