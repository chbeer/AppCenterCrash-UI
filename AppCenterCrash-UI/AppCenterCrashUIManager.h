//
//  AppCenterCrashUIManager.h
//  AppCenterCrash-UI
//
//  Created by Christian Beer on 14.04.20.
//

#import <Foundation/Foundation.h>

@import AppCenterCrashes;

NS_ASSUME_NONNULL_BEGIN

@protocol AppCenterCrashUIDelegate
- (void) appCenterCrashUIDidCancel;
- (void) appCenterCrashUIShouldSendUserName:(NSString*)userName eMail:(NSString*)eMail comment:(NSString*)comment;
@end


@interface AppCenterCrashUIManager: NSObject <MSCrashesDelegate>

@property (nonatomic, copy) NSString *companyName;
@property (nonatomic, copy) NSURL    *privacyPolicyURL;

+ (instancetype) shared;

- (void) setupWithCompanyName:(NSString*)companyName privacyPolicyURL:(NSURL*)privacyPolicyURL;

- (BOOL) userConfirmationHandler:(NSArray<MSErrorReport*>*)reports;

@end

NS_ASSUME_NONNULL_END
