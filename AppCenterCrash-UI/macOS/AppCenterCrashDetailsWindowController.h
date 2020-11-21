/*
 * Adaption to AppCenter:
 * Author: Christian Beer <christian@chbeer.de>
 * Copyright (c) 2020 Christian Beer
 *
 * Based on BWQuincyUI, taken from https://github.com/bitstadium/QuincyKit
 * Original Code:
 *
 * Author: Andreas Linde <mail@andreaslinde.de>
 *         Kent Sutherland
 *
 * Copyright (c) 2012-2013 HockeyApp, Bit Stadium GmbH.
 * Copyright (c) 2011 Andreas Linde & Kent Sutherland.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

#import <Cocoa/Cocoa.h>
#import "AppCenterCrashUIManager.h"

@interface AppCenterCrashDetailsWindowController : NSWindowController {
    IBOutlet NSTextField  *nameTextField;
    IBOutlet NSTextField  *emailTextField;
    IBOutlet NSTextField  *descriptionTextField;
    
    IBOutlet NSTextField  *nameTextFieldTitle;
    IBOutlet NSTextField  *emailTextFieldTitle;
    
    IBOutlet NSTextField  *introductionText;
    IBOutlet NSTextField  *commentsTextFieldTitle;
    
    IBOutlet NSTextField  *noteText;
    IBOutlet NSButton     *privacyPolicyButton;
    
    IBOutlet NSButton   *disclosureButton;
    IBOutlet NSButton   *cancelButton;
    IBOutlet NSButton   *submitButton;
    
    NSMenu              *_mainAppMenu;
    
    NSString          *_companyName;
    NSURL             *_privacyPolicyURL;
    NSString          *_applicationName;
    
    NSArray<MSACErrorReport*> *_errorReports;
    NSString                  *_userName;
    NSString                  *_userEmail;
    
    BOOL showUserDetails;
    BOOL showComments;
    BOOL showDetails;
}

@property (nonatomic, weak) id<AppCenterCrashUIDelegate> delegate;

// defines the users name or user id
@property (nonatomic, retain) NSString *userName;

// defines the users email address
@property (nonatomic, retain) NSString *userEmail;


- (instancetype)initWithErrorReports:(NSArray<MSACErrorReport*>*)errorReports
                         companyName:(NSString *)companyName
                     applicationName:(NSString *)applicationName
                      privacyPolicyURL:(NSURL*)privacyPolicyURL
                      askUserDetails:(BOOL)askUserDetails;

- (void)askCrashReportDetails;

- (IBAction)cancelReport:(id)sender;
- (IBAction)submitReport:(id)sender;
- (IBAction)showComments:(id)sender;

- (BOOL)showUserDetails;
- (void)setShowUserDetails:(BOOL)value;

- (BOOL)showComments;
- (void)setShowComments:(BOOL)value;

@end
