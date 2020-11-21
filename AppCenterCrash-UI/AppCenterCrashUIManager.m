//
//  AppCenterCrashUIManager.m
//  AppCenterCrash-UI
//
//  Created by Christian Beer on 14.04.20.
//

#import "AppCenterCrashUIManager.h"

#import <AppCenter/AppCenter.h>

@interface AppCenterCrashUIManager (Private) <MSACCrashesDelegate, AppCenterCrashUIDelegate>
@end

@implementation AppCenterCrashUIManager
{
    NSArray<MSACErrorAttachmentLog*> *_attachments;
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
    
    [MSACCrashes setDelegate:self];
    [MSACCrashes setUserConfirmationHandler:^BOOL(NSArray<MSACErrorReport *> * _Nonnull errorReports) {
        return [self userConfirmationHandler:errorReports];
    }];
}

#pragma mark - MSACCrashesDelegate

- (BOOL)crashes:(MSACCrashes *)crashes shouldProcessErrorReport:(MSACErrorReport *)errorReport
{
    return YES;
}

- (void)crashes:(MSACCrashes *)crashes willSendErrorReport:(MSACErrorReport *)errorReport
{
    // TODO: show activity indicator
}

- (void)crashes:(MSACCrashes *)crashes didSucceedSendingErrorReport:(MSACErrorReport *)errorReport
{
    // TODO: show success
}

- (void)crashes:(MSACCrashes *)crashes didFailSendingErrorReport:(MSACErrorReport *)errorReport withError:(NSError *)error
{
    // TODO: present error
}

- (NSArray<MSACErrorAttachmentLog *> *)attachmentsWithCrashes:(MSACCrashes *)crashes forErrorReport:(MSACErrorReport *)errorReport
{
    NSArray<MSACErrorAttachmentLog*> *attachments = _attachments;
    _attachments = nil;
    return attachments;
}

#pragma mark - AppCenterCrashUIDelegate

- (void) appCenterCrashUIDidCancel
{
    [MSACCrashes notifyWithUserConfirmation:MSACUserConfirmationDontSend];
}

- (void) appCenterCrashUIShouldSendUserName:(NSString*)userName eMail:(NSString*)eMail comment:(NSString*)comment
{
    NSMutableArray<MSACErrorAttachmentLog*> *attachments = [NSMutableArray array];
    if (userName.length > 0 || eMail.length > 0) {
        NSString *name = [NSString stringWithFormat:@"%@ (%@)", userName, eMail];
        [attachments addObject:[MSACErrorAttachmentLog attachmentWithText:name filename:@"user"]];
    }
    if (comment.length > 0) {
        [attachments addObject:[MSACErrorAttachmentLog attachmentWithText:comment filename:@"description"]];
    }
    _attachments = attachments;
    [MSACCrashes notifyWithUserConfirmation:MSACUserConfirmationSend];
}

@end
