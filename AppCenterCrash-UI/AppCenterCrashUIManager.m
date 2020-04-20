//
//  AppCenterCrashUIManager.m
//  AppCenterCrash-UI
//
//  Created by Christian Beer on 14.04.20.
//

#import "AppCenterCrashUIManager.h"

#import <AppCenter/AppCenter.h>

@interface AppCenterCrashUIManager (Private) <MSCrashesDelegate, AppCenterCrashUIDelegate>
@end

@implementation AppCenterCrashUIManager

+ (instancetype) shared
{
    static AppCenterCrashUIManager *sharedInstance = nil;
    if (sharedInstance)  return sharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AppCenterCrashUIManager alloc] init];
    });
    return sharedInstance;
}

- (void) setupWithCompanyName:(NSString*)companyName privacyPolicyURL:(NSURL*)privacyPolicyURL
{
    self.companyName = companyName;
    self.privacyPolicyURL = privacyPolicyURL;
    
    [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:@"MSUserConfirmation"];
    [MSCrashes setDelegate:self];
    [MSCrashes setUserConfirmationHandler:^BOOL(NSArray<MSErrorReport *> * _Nonnull errorReports) {
#if DEBUG
        NSLog(@"🧚‍♂️ userConfirmationHandler");
#endif
        return [self userConfirmationHandler:errorReports];
    }];
}

#pragma mark - MSCrashesDelegate

- (BOOL)crashes:(MSCrashes *)crashes shouldProcessErrorReport:(MSErrorReport *)errorReport
{
#if DEBUG
    NSLog(@"🧚‍♂️ shouldProcessErrorReport...");
#endif
    return YES;
}

- (void)crashes:(MSCrashes *)crashes willSendErrorReport:(MSErrorReport *)errorReport
{
    // TODO: show activity indicator
#if DEBUG
    NSLog(@"🧚‍♂️ willSendErrorReport ...");
#endif
}

- (void)crashes:(MSCrashes *)crashes didSucceedSendingErrorReport:(MSErrorReport *)errorReport
{
    // TODO: show success
#if DEBUG
    NSLog(@"🧚‍♂️ didSucceedSendingErrorReport");
#endif
}

- (void)crashes:(MSCrashes *)crashes didFailSendingErrorReport:(MSErrorReport *)errorReport withError:(NSError *)error
{
    // TODO: present error
#if DEBUG
    NSLog(@"🧚‍♂️ didFailSendingErrorReport: %@", error);
#endif
}

- (NSArray<MSErrorAttachmentLog *> *)attachmentsWithCrashes:(MSCrashes *)crashes forErrorReport:(MSErrorReport *)errorReport
{
#if DEBUG
    NSLog(@"🧚‍♂️ attachmentsWithCrashes...");
#endif
    return @[];
}

#pragma mark - AppCenterCrashUIDelegate

- (void) appCenterCrashUIDidCancel
{}

- (void) appCenterCrashUIShouldSendUserName:(NSString*)userName eMail:(NSString*)eMail comment:(NSString*)comment
{
    NSString *name = [NSString stringWithFormat:@"%@ (%@)", userName, eMail];
    NSArray<MSErrorAttachmentLog*> *attachments = @[
        [MSErrorAttachmentLog attachmentWithText:name filename:@"user"],
        [MSErrorAttachmentLog attachmentWithText:comment filename:@"description"]
    ];
#if DEBUG
    NSLog(@"🧚‍♂️ # attachments: %@", attachments);
#endif
}

@end
