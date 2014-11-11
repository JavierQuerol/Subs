//
//  JAQTutorialViewController.m
//  Subs
//
//  Created by Javier Querol on 13/10/14.
//  Copyright (c) 2014 Javier Querol. All rights reserved.
//

#import "JAQTutorialViewController.h"
#import "KBButton.h"

@interface JAQTutorialViewController ()
@property (nonatomic, weak) IBOutlet NSTextField *instructions;
@property (nonatomic, weak) IBOutlet KBButton *startButton;
@end

@implementation JAQTutorialViewController

- (void)windowDidLoad {
    [super windowDidLoad];
	[self.instructions setStringValue:NSLocalizedString(@"Drag and drop video file onto the icon on menubar", nil)];
	[self.startButton setTitle:NSLocalizedString(@"OK", nil)];
	[[self.startButton cell] setKBButtonType:BButtonTypeSuccess];
}

- (IBAction)closeWindow:(id)sender {
	[self close];
	if (self.closePressed) self.closePressed();
}

- (IBAction)showWeb:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://javierquerol.es/subs"]];
}

@end
