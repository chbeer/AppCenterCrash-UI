#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AppCenterCrashUIManager.h"
#import "AppCenterCrash_UI.h"
#import "AppCenterCrashDetailsWindowController.h"
#import "AppCenterCrashUIManager+macOS.h"

FOUNDATION_EXPORT double AppCenterCrash_UIVersionNumber;
FOUNDATION_EXPORT const unsigned char AppCenterCrash_UIVersionString[];

