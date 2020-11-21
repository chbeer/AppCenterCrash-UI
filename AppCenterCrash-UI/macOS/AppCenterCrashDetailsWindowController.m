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

#import "AppCenterCrashDetailsWindowController.h"
#import "AppCenterCrash_UI.h"

#import <sys/sysctl.h>

NSString *CBLocalizedString(NSString *key, NSString *comment) {
    NSBundle *bundle = [NSBundle bundleForClass:[AppCenterCrashDetailsWindowController class]];
    return NSLocalizedStringFromTableInBundle(key, @"AppCenterCrash-UI", bundle, comment);
}

@import AppCenterCrashes;

@interface AppCenterCrashDetailsWindowController(private)
- (void) askCrashReportDetails;
- (void) endCrashReporter;
@end

const CGFloat kUserHeight = 50;
const CGFloat kCommentsHeight = 105;

@implementation AppCenterCrashDetailsWindowController

@synthesize userName = _userName;
@synthesize userEmail = _userEmail;


- (instancetype)initWithErrorReports:(NSArray<MSACErrorReport*>*)errorReports
                         companyName:(NSString *)companyName
                     applicationName:(NSString *)applicationName
                    privacyPolicyURL:(NSURL*)privacyPolicyURL
                      askUserDetails:(BOOL)askUserDetails
{
    self = [super initWithWindowNibName:@"AppCenterCrashDetailsWindowController"];
    if ( self != nil) {
        _mainAppMenu = [NSApp mainMenu];
        _errorReports = errorReports;
        _companyName = [companyName copy];
        _privacyPolicyURL = [privacyPolicyURL copy];
        _applicationName = [applicationName copy];
        
        self.userName = [[NSUserDefaults standardUserDefaults] stringForKey:kAppCenterCrashUI_UserNameKey];
        if (self.userName == nil) self.userName = @"";
        
        self.userEmail = [[NSUserDefaults standardUserDefaults] stringForKey:kAppCenterCrashUI_EMailKey];
        if (self.userEmail == nil) self.userEmail = @"";
        
        [self setShowComments: YES];
        [self setShowUserDetails:askUserDetails];
        
        NSRect windowFrame = [[self window] frame];
        
        if (!askUserDetails) {
            windowFrame.size = NSMakeSize(windowFrame.size.width, windowFrame.size.height - kUserHeight);
            windowFrame.origin.y -= kUserHeight;
            
            NSRect frame = commentsTextFieldTitle.frame;
            frame.origin.y += kUserHeight;
            commentsTextFieldTitle.frame = frame;
            
            frame = disclosureButton.frame;
            frame.origin.y += kUserHeight;
            disclosureButton.frame = frame;
            
            frame = descriptionTextField.frame;
            frame.origin.y += kUserHeight;
            descriptionTextField.frame = frame;
        }
        
        if (privacyPolicyURL == nil) {
            [noteText setHidden:YES];
            [privacyPolicyButton setHidden:YES];
        }
        
        NSAssert([self window] != nil, @"Window did not load");
        [[self window] setFrame: windowFrame
                        display: YES
                        animate: NO];
        
    }
    return self;
}

- (void)endCrashReporter {
    [self close];
    [NSApp stopModal];
    [NSApp setMainMenu:_mainAppMenu];
}


- (IBAction)showComments: (id) sender {
    NSRect windowFrame = [[self window] frame];
    
    if ([sender intValue]) {
        [self setShowComments: NO];
        
        windowFrame.size = NSMakeSize(windowFrame.size.width, windowFrame.size.height + kCommentsHeight);
        windowFrame.origin.y -= kCommentsHeight;
        [[self window] setFrame: windowFrame
                        display: YES
                        animate: YES];
        
        [self setShowComments: YES];
    } else {
        [self setShowComments: NO];
        
        windowFrame.size = NSMakeSize(windowFrame.size.width, windowFrame.size.height - kCommentsHeight);
        windowFrame.origin.y += kCommentsHeight;
        [[self window] setFrame: windowFrame
                        display: YES
                        animate: YES];
    }
}


- (IBAction)cancelReport:(id)sender {
    [self endCrashReporter];
    
    if (self.delegate) [self.delegate appCenterCrashUIDidCancel];
}

- (IBAction)submitReport:(id)sender {
    [cancelButton setEnabled:NO];
    [submitButton setEnabled:NO];
    
    [[self window] makeFirstResponder: nil];
    
    NSString *userName = @"";
    NSString *eMail = @"";
    NSString *comment = [descriptionTextField stringValue];

    if (showUserDetails) {
        userName = [nameTextField stringValue];
        eMail = [emailTextField stringValue];
    }
    
    if (self.delegate) [self.delegate appCenterCrashUIShouldSendUserName:userName
                                                                   eMail:eMail
                                                                 comment:comment];
    
    [self endCrashReporter];
}

- (IBAction)showPrivacyPolicy:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:_privacyPolicyURL];
}

- (void)askCrashReportDetails {
#define DISTANCE_BETWEEN_BUTTONS		3
    
    NSString *title = CBLocalizedString(@"WindowTitle", @"");
    [[self window] setTitle:[NSString stringWithFormat:title, _applicationName]];
    
    [[nameTextFieldTitle cell] setTitle:CBLocalizedString(@"NameTextTitle", @"")];
    [[nameTextField cell] setTitle:self.userName];
    if ([[nameTextField cell] respondsToSelector:@selector(setUsesSingleLineMode:)]) {
        [[nameTextField cell] setUsesSingleLineMode:YES];
    }
    
    [[emailTextFieldTitle cell] setTitle:CBLocalizedString(@"EmailTextTitle", @"")];
    [[emailTextField cell] setTitle:self.userEmail];
    if ([[emailTextField cell] respondsToSelector:@selector(setUsesSingleLineMode:)]) {
        [[emailTextField cell] setUsesSingleLineMode:YES];
    }
    
    title = CBLocalizedString(@"IntroductionText", @"");
    [[introductionText cell] setTitle:[NSString stringWithFormat:title, _applicationName, _companyName]];
    [[commentsTextFieldTitle cell] setTitle:CBLocalizedString(@"CommentsDisclosureTitle", @"")];
    
    [[descriptionTextField cell] setPlaceholderString:CBLocalizedString(@"UserDescriptionPlaceholder", @"")];
    [noteText setStringValue:CBLocalizedString(@"PrivacyNote", @"")];
    
    [cancelButton setTitle:CBLocalizedString(@"CancelButtonTitle", @"")];
    [submitButton setTitle:CBLocalizedString(@"SendButtonTitle", @"")];
    
    // adjust button sizes
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys: [submitButton font], NSFontAttributeName, nil];
    NSSize titleSize = [[submitButton title] sizeWithAttributes: attrs];
    titleSize.width += (16 + 8) * 2;	// 16 px for the end caps plus 8 px padding at each end
    NSRect submitBtnBox = [submitButton frame];
    submitBtnBox.origin.x += submitBtnBox.size.width -titleSize.width;
    submitBtnBox.size.width = titleSize.width;
    [submitButton setFrame: submitBtnBox];
    
    titleSize = [[cancelButton title] sizeWithAttributes: attrs];
    titleSize.width += (16 + 8) * 2;	// 16 px for the end caps plus 8 px padding at each end
    NSRect cancelBtnBox = [cancelButton frame];
    cancelBtnBox.origin.x = submitBtnBox.origin.x -DISTANCE_BETWEEN_BUTTONS -titleSize.width;
    cancelBtnBox.size.width = titleSize.width;
    [cancelButton setFrame: cancelBtnBox];
    
    NSBeep();
    [NSApp runModalForWindow:[self window]];
}


- (BOOL)showUserDetails {
    return showUserDetails;
}
- (void)setShowUserDetails:(BOOL)value {
    showUserDetails = value;
}


- (BOOL)showComments {
    return showComments;
}
- (void)setShowComments:(BOOL)value {
    showComments = value;
}


#pragma mark NSTextField Delegate

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    BOOL commandHandled = NO;
    
    if (commandSelector == @selector(insertNewline:)) {
        [textView insertNewlineIgnoringFieldEditor:self];
        commandHandled = YES;
    }
    
    return commandHandled;
}

@end

