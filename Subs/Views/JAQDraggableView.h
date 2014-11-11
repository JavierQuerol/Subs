//
//  JAQDraggableView.h
//  Subs
//
//  Created by Javier Querol on 21/10/14.
//  Copyright (c) 2014 Javier Querol. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol JAQDragStatusViewDelegate <NSObject>
- (void) droppedSingleFile: (NSString*)withFile;
@end

@interface JAQDraggableView : NSView
@property (retain, nonatomic) id <JAQDragStatusViewDelegate> delegate;
@end
