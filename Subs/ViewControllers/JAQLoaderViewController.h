//
//  JAQLoaderViewController.h
//  Subs
//
//  Created by Javier Querol on 02/09/14.
//  Copyright (c) 2014 Javier Querol. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JAQLoaderViewController : NSViewController

@property (nonatomic, weak) IBOutlet NSTextField *fileTitleField;

- (void)showText:(NSAttributedString *)text;
- (void)showAlertWithTitle:(NSAttributedString *)title play:(void (^)())playBlock cancel:(void (^)())cancelBlock;
- (void)endAnimation;

@end
