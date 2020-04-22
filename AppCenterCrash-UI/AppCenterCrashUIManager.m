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
{
    NSArray<MSErrorAttachmentLog*> *_attachments;
}

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
    
    [MSCrashes setDelegate:self];
    [MSCrashes setUserConfirmationHandler:^BOOL(NSArray<MSErrorReport *> * _Nonnull errorReports) {
        return [self userConfirmationHandler:errorReports];
    }];
}

#pragma mark - MSCrashesDelegate

- (BOOL)crashes:(MSCrashes *)crashes shouldProcessErrorReport:(MSErrorReport *)errorReport
{
    return YES;
}

- (void)crashes:(MSCrashes *)crashes willSendErrorReport:(MSErrorReport *)errorReport
{
    // TODO: show activity indicator
}

- (void)crashes:(MSCrashes *)crashes didSucceedSendingErrorReport:(MSErrorReport *)errorReport
{
    // TODO: show success
}

- (void)crashes:(MSCrashes *)crashes didFailSendingErrorReport:(MSErrorReport *)errorReport withError:(NSError *)error
{
    // TODO: present error
}

- (NSArray<MSErrorAttachmentLog *> *)attachmentsWithCrashes:(MSCrashes *)crashes forErrorReport:(MSErrorReport *)errorReport
{
    NSArray<MSErrorAttachmentLog*> *attachments = _attachments;
    _attachments = nil;
    return attachments;
}

#pragma mark - AppCenterCrashUIDelegate

- (void) appCenterCrashUIDidCancel
{
    [MSCrashes notifyWithUserConfirmation:MSUserConfirmationDontSend];
}

- (void) appCenterCrashUIShouldSendUserName:(NSString*)userName eMail:(NSString*)eMail comment:(NSString*)comment
{
    NSString *name = [NSString stringWithFormat:@"%@ (%@)", userName, eMail];
    NSArray<MSErrorAttachmentLog*> *attachments = @[
        [MSErrorAttachmentLog attachmentWithText:name filename:@"user"],
        [MSErrorAttachmentLog attachmentWithText:comment filename:@"description"]
    ];
    _attachments = attachments;
    [MSCrashes notifyWithUserConfirmation:MSUserConfirmationSend];
}

@end
