//
//  JAQLoaderViewController.m
//  Subs
//
//  Created by Javier Querol on 02/09/14.
//  Copyright (c) 2014 Javier Querol. All rights reserved.
//

#import "JAQLoaderViewController.h"
#import "JAQUtils.h"
#import "JAQSubtitleDownloader.h"
#import "YRKSpinningProgressIndicator.h"
#import "JAQTutorialViewController.h"
#import "JAQConstants.h"
#import "AppDelegate.h"

@interface JAQLoaderViewController ()
@property (nonatomic, weak) IBOutlet NSMenu *langMenu;
@property (nonatomic, weak) IBOutlet NSPopUpButtonCell *buttonCell;

@property (nonatomic, weak) IBOutlet NSView *optionsHolder;
@property (nonatomic, weak) IBOutlet NSView *loaderHolder;
@property (nonatomic, weak) IBOutlet NSView *alertView;

@property (nonatomic, weak) IBOutlet YRKSpinningProgressIndicator *spin;
@property (nonatomic, weak) IBOutlet NSTextField *textField;
@property (nonatomic, weak) IBOutlet NSMenuItem	*versionItem;
@property (nonatomic, weak) IBOutlet NSImageView *logoImageView;

@property (nonatomic, weak) IBOutlet NSTextField *alertTitle;
@property (nonatomic, weak) IBOutlet NSButton *cancelButton;
@property (nonatomic, weak) IBOutlet NSButton *playButton;

@property (nonatomic, weak) IBOutlet NSButton *startAtLoginButton;
@property (nonatomic, weak) IBOutlet NSTextField *selectedLang;
@property (nonatomic, weak) IBOutlet NSTextField *instructions;
@property (nonatomic, weak) IBOutlet NSMenuItem *quitMenu;

@property (nonatomic, strong) JAQTutorialViewController *tutorialVC;

@property (nonatomic, copy) void(^alertClosePressed)();
@property (nonatomic, copy) void(^alertPlayPressed)();
@end

@implementation JAQLoaderViewController

- (void)loadView {
	[super loadView];
	
	self.spin.color = [NSColor whiteColor];
	self.spin.hidden = YES;
	
	self.startAtLoginButton.title = NSLocalizedString(@"Launch at Login", nil);
	self.selectedLang.stringValue = NSLocalizedString(@"Select Language:", nil);
	self.instructions.stringValue = NSLocalizedString(@"Drag and drop video file onto the icon on menubar", nil);
	
	[self.cancelButton setTitle:NSLocalizedString(@"Cancel", nil)];
	[self.playButton setTitle:NSLocalizedString(@"Play Anyway", nil)];
	
	self.quitMenu.title = NSLocalizedString(@"Quit", nil);
	
	self.instructions.font = [JAQUtils calculateFontToFitRect:NSMakeRect(0, 0, self.view.bounds.size.width-10, self.instructions.frame.size.height-1)
													  minFont:7
													  maxFont:11
											  currentFontName:[NSFont systemFontOfSize:11].familyName
														 text:self.instructions.stringValue];
	
	NSString *versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	NSString *buildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
	[self.versionItem setTitle:[NSString stringWithFormat:@"v%@ (%@)", versionString, buildString]];
	
	[self.loaderHolder setHidden:YES];
	[self.spin startAnimation:nil];
	
	NSString *currentShortLang = [[NSUserDefaults standardUserDefaults] valueForKey:JAQ_LANG];
	NSString *selectedLongLang = [JAQUtils getLongTextFromShort:currentShortLang];
		
	NSArray *longLangs = longStrings;
	for (NSString *longLang in longLangs) {
		NSMenuItem *item = [_langMenu addItemWithTitle:longLang
												action:@selector(selectLanguage:)
										 keyEquivalent:[JAQUtils getShortTextFromLong:longLang]];
		[item setTarget:self];
		
		if ([longLang isEqualToString:selectedLongLang]) {
			[_buttonCell setTitle:longLang];
		}
	}
}

- (void)selectLanguage:(id)sender {
	NSMenuItem *item = (NSMenuItem *)sender;
	NSString *shortLang = [JAQUtils getShortTextFromLong:item.title];
	[[NSUserDefaults standardUserDefaults] setValue:shortLang forKey:JAQ_LANG];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)showText:(NSAttributedString *)text {
	[self.instructions setHidden:YES];
	[self.spin setHidden:NO];
	[self.spin startAnimation:nil];
	[self.optionsHolder setHidden:YES];
	[self.loaderHolder setHidden:NO];
	[self.alertView setHidden:YES];
	[self.logoImageView setImage:[NSImage imageNamed:@"subsclean"]];
	[_textField setAttributedStringValue:text];
}

- (void)showAlertWithTitle:(NSAttributedString *)title play:(void (^)())playBlock cancel:(void (^)())cancelBlock {
	[self.instructions setHidden:YES];
	[self.alertView setHidden:NO];
	[self.optionsHolder setHidden:YES];
	[self.loaderHolder setHidden:YES];
	[self.alertTitle setAttributedStringValue:title];
	
	self.alertClosePressed = ^{cancelBlock();};
	self.alertPlayPressed = ^{playBlock();};
}

- (IBAction)playButtonPressed:(id)sender {
	self.alertPlayPressed();
}

- (IBAction)cancelButtonPressed:(id)sender {
	self.alertClosePressed();
}

- (void)endAnimation {
	[self.instructions setHidden:NO];
	[self.spin stopAnimation:nil];
	[self.spin setHidden:YES];
	[self.optionsHolder setHidden:NO];
	[self.loaderHolder setHidden:YES];
	[self.alertView setHidden:YES];
	[self.logoImageView setImage:[NSImage imageNamed:@"subsIcon"]];
	[_textField setStringValue:@""];
}

- (IBAction)exitApp:(id)sender {
	[[NSApplication sharedApplication] terminate:sender];
}

- (IBAction)showTutorial:(id)sender {
	_tutorialVC = [[JAQTutorialViewController alloc] initWithWindowNibName:@"JAQTutorialViewController"];
	[_tutorialVC showWindow:nil];
	_tutorialVC.closePressed = ^{
		AppDelegate *appDelegate = [NSApplication sharedApplication].delegate;
		[appDelegate showPopover];
	};
}

@end
