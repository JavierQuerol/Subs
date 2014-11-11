//
//  JAQUtils.m
//  Subs
//
//  Created by Javier Querol on 02/08/14.
//  Copyright (c) 2014 Javier Querol. All rights reserved.
//

#import "JAQUtils.h"

@implementation JAQUtils

+ (NSString *)getShortTextFromLong:(NSString *)input {
	NSArray *longStringsArray = longStrings;
	NSArray *shortStringsArray = shortStrings;
	__block NSString *output = [NSString string];
	[longStringsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([[obj lowercaseString] isEqualToString:[input lowercaseString]]) output = shortStringsArray[idx];
	}];
	return output;
}

+ (NSString *)getLongTextFromShort:(NSString *)input {
	NSArray *longStringsArray = longStrings;
	NSArray *shortStringsArray = shortStrings;
	__block NSString *output = [NSString string];
	[shortStringsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([[obj lowercaseString] isEqualToString:[input lowercaseString]]) output = longStringsArray[idx];
	}];
	return output;
}

+ (NSString *)getSubsTextFromShort:(NSString *)input {
	NSArray *subsStringsArray = subsStrings;
	NSArray *shortStringsArray = shortStrings;
	__block NSString *output = [NSString string];
	[shortStringsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([[obj lowercaseString] isEqualToString:[input lowercaseString]]) output = subsStringsArray[idx];
	}];
	return output;
}

+ (NSString *)getShortTextFromSubs:(NSString *)input {
	NSArray *shortStringsArray = shortStrings;
	NSArray *substStringsArray = subsStrings;
	__block NSString *output = [NSString string];
	[substStringsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([[obj lowercaseString] isEqualToString:[input lowercaseString]]) output = shortStringsArray[idx];
	}];
	return output;
}

+ (NSFont *)calculateFontToFitRect:(NSRect)rect minFont:(CGFloat)minFont maxFont:(CGFloat)maxFont currentFontName:(NSString *)currentFontName text:(NSString *)text {
	NSRect myrect = rect;
	for (int i=minFont; i<maxFont; i++) {
		NSSize strSize = [text sizeWithAttributes:@{NSFontAttributeName:[NSFont fontWithName:currentFontName size:i]}];
		if (strSize.width > myrect.size.width || strSize.height > myrect.size.height) {
			return [NSFont fontWithName:currentFontName size:i];
			break;
		}
	}
	return nil;
}

+ (NSAttributedString *)attributedStringWithHeader:(NSString *)header text:(NSString *)text {
	NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@",header,text]];
	[result addAttributes:@{NSFontAttributeName:[NSFont boldSystemFontOfSize:15]} range:NSMakeRange(0, header.length)];
	return result;
}

@end
