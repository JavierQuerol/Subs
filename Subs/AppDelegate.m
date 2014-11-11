//
//  AppDelegate.m
//  Subs
//
//  Created by Javier Querol on 11/11/14.
//  Copyright (c) 2014 Javier Querol. All rights reserved.
//

#import "AppDelegate.h"
#import "JAQUtils.h"
#import "JAQSubtitleDownloader.h"
#import "JAQLoaderViewController.h"
#import "JAQTutorialViewController.h"
#import "JAQDraggableView.h"
#import "JAQVideo.h"
#import "JAQConstants.h"

typedef enum : NSUInteger {
	JAQVideoPlaying,
	JAQVideoSubsNotFound,
	JAQVideoNoConnection,
} JAQVideoStatus;

@interface AppDelegate () <NSPopoverDelegate, NSAlertDelegate, JAQDragStatusViewDelegate, JAQSubsDownloaderDelegate>
@property (nonatomic, strong) JAQLoaderViewController *loaderView;
@property (nonatomic, strong) JAQTutorialViewController *tutorialVC;
@property (nonatomic, strong) JAQDraggableView *dragView;
@property (nonatomic, strong) JAQVideo *currentVideo;
@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) NSPopover *popover;
@property (strong, nonatomic) NSEvent *popoverTransiencyMonitor;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	const AEEventClass class = kCoreEventClass;
	[[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
													   andSelector:@selector(handleAppleEvent:withReplyEvent:)
													 forEventClass:class
														andEventID:kAEOpenDocuments];
	
	if (![[NSUserDefaults standardUserDefaults] valueForKey:JAQ_LANG]) {
		[[NSUserDefaults standardUserDefaults] setValue:@"en" forKey:JAQ_LANG];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	_loaderView = [[JAQLoaderViewController alloc] initWithNibName:@"JAQLoaderViewController" bundle:nil];
	[_loaderView loadView];
	
	[self configurePopover];
	
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"entered"]) {
		_tutorialVC = [[JAQTutorialViewController alloc] initWithWindowNibName:@"JAQTutorialViewController"];
		[_tutorialVC showWindow:nil];
		
		__weak AppDelegate *weakSelf = self;
		_tutorialVC.closePressed = ^{
			[weakSelf showPopover];
		};
		
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"entered"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (void)handleAppleEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
	AEKeyword keyword = [event keywordForDescriptorAtIndex:1];
	NSAppleEventDescriptor *descriptor = [event paramDescriptorForKeyword:keyword];
	NSString *filePath = [descriptor stringValue];
	
	JAQVideo *video = [JAQVideo videoFromFilePath:filePath];
	[self openFile:video];
}

- (void)configurePopover {
	_popover = [NSPopover new];
	_popover.delegate = self;
	_popover.contentViewController = _loaderView;
	
	NSImage *image = [NSImage imageNamed:@"miniIcon"];
	[image setTemplate:YES];
	
	_statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
	[_statusItem setImage:image];
	[_statusItem setAlternateImage:image];
	[_statusItem setHighlightMode:YES];
	[_statusItem setAction:@selector(showPopover)];
	
	self.dragView = [[JAQDraggableView alloc] initWithFrame:_statusItem.button.frame];
	self.dragView.delegate = self;
	[_statusItem.button addSubview:self.dragView];
}

- (void)showPopover {
	_popover.behavior = NSPopoverBehaviorTransient;
	[_popover showRelativeToRect:NSZeroRect ofView:_statusItem.button preferredEdge:NSMinYEdge];
	
	if (self.popoverTransiencyMonitor == nil) {
		self.popoverTransiencyMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:(NSLeftMouseDownMask | NSRightMouseDownMask | NSKeyUpMask) handler:^(NSEvent* event) {
			[NSEvent removeMonitor:self.popoverTransiencyMonitor];
			self.popoverTransiencyMonitor = nil;
			[self.popover close];
		}];
	}
}

- (void)openFile:(JAQVideo *)video {
	if (video) {
		_currentVideo = video;
		[_loaderView showText:[JAQUtils attributedStringWithHeader:NSLocalizedString(@"Loading file",nil) text:video.name]];
		[self showPopover];
		
		JAQSubtitleDownloader *downloader = [[JAQSubtitleDownloader alloc] initWithUserAgent:@"Remo"];
		downloader.delegate = self;
	}
}

- (void)downloadSubtitle:(JAQSubtitleDownloader *)downloader video:(JAQVideo *)video {
	NSString *shortLang = [[NSUserDefaults standardUserDefaults] valueForKey:JAQ_LANG];
	if (!shortLang || shortLang.length==0) shortLang = @"en";
	downloader.languageString = [JAQUtils getSubsTextFromShort:shortLang];
	[downloader searchForSubtitlesWithHash:video.fileHash andFilesize:video.fileSize :^(NSArray *subtitles) {
		if (subtitles.count>0) {
			JAQSubtitleResult *result = subtitles.firstObject;
			NSString *subAddress = result.subtitleDownloadAddress;
			if (subAddress.length>0) {
				[_loaderView showText:[JAQUtils attributedStringWithHeader:NSLocalizedString(@"Downloading subtitles",nil) text:video.name]];
				[downloader downloadSubtitlesForString:subAddress toPath:[video subtitleFilePath] :^{
					[_loaderView showText:[JAQUtils attributedStringWithHeader:NSLocalizedString(@"Playing video",nil) text:video.name]];
					NSUserNotification *notification = [NSUserNotification new];
					notification.title = NSLocalizedString(@"Playing with subtitles",nil);
					notification.informativeText = video.name;
					notification.soundName = NSUserNotificationDefaultSoundName;
					
					[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
					[self endAndLaunch:video withPlay:YES];
				}];
			} else {
				[self prepareVideo:video withStatus:JAQVideoSubsNotFound];
			}
		} else {
			[self prepareVideo:video withStatus:JAQVideoSubsNotFound];
		}
	}];
}

- (void)endAndLaunch:(JAQVideo *)video withPlay:(BOOL)play {
	[_loaderView endAnimation];
	[_popover performClose:nil];
	if (play) [self launchMovie:video];
	_currentVideo = nil;
}

- (void)launchMovie:(JAQVideo *)video {
	NSTask *task = [NSTask new];
	[task setLaunchPath:@"/usr/bin/open"];
	[task setArguments:@[video.filePath]];
	[task launch];
}

- (void)droppedSingleFile:(NSString *)filePath {
	JAQVideo *video = [JAQVideo videoFromFilePath:filePath];
	[self openFile:video];
	[self showPopover];
}

- (void)prepareVideo:(JAQVideo *)video withStatus:(JAQVideoStatus)status {
	NSAttributedString *text;
	switch (status) {
		case JAQVideoPlaying:
			text = [JAQUtils attributedStringWithHeader:NSLocalizedString(@"Downloading subtitles",nil) text:video.name];
			break;
		case JAQVideoSubsNotFound:
			text = [JAQUtils attributedStringWithHeader:NSLocalizedString(@"Subtitles not found", nil) text:video.name];
			break;
		case JAQVideoNoConnection:
			text = [JAQUtils attributedStringWithHeader:NSLocalizedString(@"No connection, playing video",nil) text:nil];
			break;
		default:
			break;
	}
	
	[_loaderView showText:text];
	if (status==JAQVideoPlaying) return;
	
	[_loaderView showAlertWithTitle:text play:^{
		[self endAndLaunch:video withPlay:YES];
	} cancel:^{
		[self endAndLaunch:video withPlay:NO];
	}];
}

#pragma mark - JAQSubsDownloaderDelegate

- (void)openSubtitlerDidLogIn:(JAQSubtitleDownloader *)downloader {
	[self downloadSubtitle:downloader video:_currentVideo];
}

- (void)subtitleDownloadInvalid:(JAQSubtitleDownloader *)downloader {
	[self prepareVideo:_currentVideo withStatus:JAQVideoNoConnection];
}

@end
