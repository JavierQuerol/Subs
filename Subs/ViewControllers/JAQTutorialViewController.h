//
//  JAQTutorialViewController.h
//  Subs
//
//  Created by Javier Querol on 13/10/14.
//  Copyright (c) 2014 Javier Querol. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JAQTutorialViewController : NSWindowController

@property (nonatomic, copy) void(^closePressed)();

@end
