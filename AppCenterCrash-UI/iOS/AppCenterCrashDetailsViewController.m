//
//  AppCenterCrashDetailsViewController.m
//  AppCenterCrash-UI-iOS
//
//  Created by Christian Beer on 17.11.14.
//  Copyright (c) 2014 Christian Beer. All rights reserved.
//

#import "AppCenterCrashDetailsViewController.h"

#import "AppCenterCrash_UI.h"

typedef enum {
    CBCrashReportUISectionInfo,
    CBCrashReportUISectionUserInfo,
    CBCrashReportUISectionComments,
    CBCrashReportUISectionAction,
    CBCrashReportUISectionCount
} CBCrashReportUISection;

typedef enum {
    CBCrashReportUIUserInfoCellName,
    CBCrashReportUIUserInfoCellEMail,
    CBCrashReportUIUserInfoCellCount
} CBCrashReportUIUserInfoCell;

NSString *CBLocalizedString(NSString *key, NSString *comment) {
    NSBundle *bundle = [NSBundle bundleForClass:[AppCenterCrashDetailsViewController class]];
    return NSLocalizedStringFromTableInBundle(key, @"AppCenterCrash-UI", bundle, comment);
}

@interface AppCenterCrashDetailsViewController () <UITextFieldDelegate,UITextViewDelegate>

@property (nonatomic, strong) UITextField   *userNameTextField;
@property (nonatomic, strong) UITextField   *userEMailTextField;
@property (nonatomic, strong) UITextView    *commentsTextView;
@property (nonatomic, strong) UIButton      *sendReportButton;

@property (nonatomic, assign) CGFloat commentMinRowHeight;

@end


@implementation AppCenterCrashDetailsViewController
{
    CGFloat _commentRowHeight;
    
    BOOL _hasLayoutManager; // for height calculation
    BOOL _hasSeparatorInsets;
    
    NSString *_userName;
    NSString *_userEMail;
}

#pragma mark -

- (instancetype) initWithErrorReports:(NSArray<MSErrorReport*>*)errorReports
                          companyName:(NSString *)companyName
                      applicationName:(NSString *)applicationName
                     privacyPolicyURL:(NSURL*)privacyPolicyURL
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (!self) return nil;
    
    _applicationName = applicationName;
    _errorReports = errorReports;
    
    _userName = [[NSUserDefaults standardUserDefaults] stringForKey:kAppCenterCrashUI_UserNameKey];
    _userEMail = [[NSUserDefaults standardUserDefaults] stringForKey:kAppCenterCrashUI_EMailKey];
    
    self.title = [NSString stringWithFormat:CBLocalizedString(@"WindowTitle", @""), applicationName];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    
    if ([self.tableView respondsToSelector:@selector(setKeyboardDismissMode:)]) {
        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    }
    
    _commentMinRowHeight = 100;
    
    _hasLayoutManager = NSClassFromString(@"NSLayoutManager") != nil;
    _hasSeparatorInsets = [self.tableView respondsToSelector:@selector(setSeparatorInset:)];
    
    return self;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // reload data to get the correct separatorInsets
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return CBCrashReportUISectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case CBCrashReportUISectionInfo:
            return 0;
            break;
        case CBCrashReportUISectionUserInfo:
            return CBCrashReportUIUserInfoCellCount;
            break;
        case CBCrashReportUISectionComments:
            return 1;
        case CBCrashReportUISectionAction:
            return 1;
            
        default:
            return 0;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case CBCrashReportUISectionComments:
            return CBLocalizedString(@"CommentsDisclosureTitle", @"");
            break;
            
        default:
            return nil;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == CBCrashReportUISectionInfo) {
        NSString *infoFormat = CBLocalizedString(@"IntroductionText", @"Crash reporter info message");
        NSString *appName = self.applicationName;
        NSString *infoString = [NSString stringWithFormat:infoFormat, appName];
        return infoString;
    } else if (section == CBCrashReportUISectionComments) {
        return CBLocalizedString(@"UserDescriptionPlaceholder", @"");
    } else if (section == CBCrashReportUISectionAction) {
        return CBLocalizedString(@"PrivacyNote", @"");
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // intentional reuse identifier for each cell
    NSString *reuseIdentifier = [NSString stringWithFormat:@"Cell_%ld_%ld", (long)indexPath.section,
                                 (long)indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:reuseIdentifier];
    }
    
    UIView *control = nil;
    CGRect controlFrame;
    if (_hasSeparatorInsets) {
        controlFrame = CGRectInset(cell.contentView.bounds, cell.separatorInset.left,
                                        cell.separatorInset.top);
    } else {
        controlFrame = CGRectInset(cell.contentView.bounds, 20,0);
    }
    
    if (indexPath.section == CBCrashReportUISectionUserInfo && indexPath.row == CBCrashReportUIUserInfoCellName) {
        if (!self.userNameTextField) {
            UITextField *textField = [UITextField new];
            textField.placeholder = CBLocalizedString(@"NameTextTitle", @"");
            textField.text = _userName;
            textField.delegate = self;
            textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            textField.returnKeyType = UIReturnKeyNext;
            self.userNameTextField = textField;
            control = textField;
        } else {
            self.userNameTextField.frame = controlFrame;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    } else if (indexPath.section == CBCrashReportUISectionUserInfo && indexPath.row == CBCrashReportUIUserInfoCellEMail) {
        if (!self.userEMailTextField) {
            UITextField *textField = [UITextField new];
            textField.placeholder = CBLocalizedString(@"EmailTextTitle", @"");
            textField.text = _userEMail;
            textField.delegate = self;
            textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            textField.keyboardType = UIKeyboardTypeEmailAddress;
            textField.returnKeyType = UIReturnKeyNext;
            self.userEMailTextField = textField;
            control = textField;
        } else {
            self.userEMailTextField.frame = controlFrame;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    } else if (indexPath.section == CBCrashReportUISectionComments) {
        controlFrame = CGRectInset(controlFrame, -4, 0);
        
        if (!self.commentsTextView) {
            UITextView *textView = [[UITextView alloc] init];
            textView.font = [UIFont systemFontOfSize:17];
            textView.scrollEnabled = NO;
            textView.scrollsToTop = NO;
            textView.delegate = self;
            textView.contentInset = UIEdgeInsetsMake(8, 0, 8, 0);
            self.commentsTextView = textView;
            control = textView;
        } else {
            self.commentsTextView.frame = controlFrame;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    } else if (indexPath.section == CBCrashReportUISectionAction) {
        if (!self.sendReportButton) {
            UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            actionButton.userInteractionEnabled = NO; // just a dummy. Action is done via table
            [actionButton setTitle:CBLocalizedString(@"SendButtonTitle", @"")
                          forState:UIControlStateNormal];
            control = actionButton;
            self.sendReportButton = actionButton;
        } else {
            self.sendReportButton.frame = controlFrame;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
    }
    
    if (control) {
        control.frame = controlFrame;
        control.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        control.backgroundColor = [UIColor clearColor];
        control.opaque = NO;
        
        [cell.contentView addSubview:control];
    }

    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == CBCrashReportUISectionComments) {
        return MAX(_commentRowHeight, self.commentMinRowHeight);
    } else {
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == CBCrashReportUISectionAction) {
        [self send:indexPath];
    }
}

#pragma mark - Actions

- (IBAction) cancel:(id)sender
{
    if (self.delegate) [self.delegate appCenterCrashUIDidCancel];
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (IBAction) send:(NSIndexPath*)sender
{
    NSString *userName = self.userNameTextField.text;
    NSString *eMail = self.userEMailTextField.text;
    NSString *comment = self.commentsTextView.text;
    
    if (self.delegate) [self.delegate appCenterCrashUIShouldSendUserName:userName
                                                                   eMail:eMail
                                                                 comment:comment];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.userNameTextField) {
        [self.userEMailTextField becomeFirstResponder];
    } else if (textField == self.userEMailTextField) {
        [self.commentsTextView becomeFirstResponder];
    }
    
    return YES;
}

#pragma mark - Text view delegate

- (void)textViewDidChange:(UITextView *)textView
{
    if (_hasLayoutManager) { // >= iOS 7
        _commentRowHeight = [textView sizeThatFits:CGSizeMake(textView.bounds.size.width, CGFLOAT_MAX)].height + 16;
    } else {
        _commentRowHeight = textView.contentSize.height;
    }
    _commentRowHeight = ceil(_commentRowHeight);
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

@end
