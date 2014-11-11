//
//  JAQDraggableView.m
//  Subs
//
//  Created by Javier Querol on 21/10/14.
//  Copyright (c) 2014 Javier Querol. All rights reserved.
//

#import "JAQDraggableView.h"

@implementation JAQDraggableView

- (instancetype)initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	if (self) {
		NSArray *dragTypes = @[NSURLPboardType, NSFileContentsPboardType, NSFilenamesPboardType];
		[self registerForDraggedTypes:dragTypes];
	}
	return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
	return NSDragOperationCopy;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
	NSPasteboard *pboard;
	NSDragOperation sourceDragMask;
	
	sourceDragMask = [sender draggingSourceOperationMask];
	pboard = [sender draggingPasteboard];
	
	if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
		NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
		NSString *file = [files objectAtIndex:0];
		[_delegate droppedSingleFile:file];
	}
	return YES;
}

@end
