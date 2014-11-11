//
//  JAQUtils.h
//  Subs
//
//  Created by Javier Querol on 02/08/14.
//  Copyright (c) 2014 Javier Querol. All rights reserved.
//

#import <Foundation/Foundation.h>

#define longStrings @[@"English",@"Español",@"Deutsch",@"Italiano",@"Français",@"русский",@"Português",@"繁體中文",@"日本語"];
#define subsStrings @[@"eng",@"spa",@"ger",@"ita",@"fre",@"rus",@"por",@"chi",@"jpn"];
#define shortStrings @[@"en",@"es",@"de",@"it",@"fr",@"ru",@"po",@"ch",@"jp"];

@interface JAQUtils : NSObject

+ (NSString *)getShortTextFromLong:(NSString *)input;
+ (NSString *)getLongTextFromShort:(NSString *)input;
+ (NSString *)getSubsTextFromShort:(NSString *)input;
+ (NSString *)getShortTextFromSubs:(NSString *)input;

+ (NSFont *)calculateFontToFitRect:(NSRect)rect
						   minFont:(CGFloat)minFont
						   maxFont:(CGFloat)maxFont
				   currentFontName:(NSString *)currentFontName
							  text:(NSString *)text;

+ (NSAttributedString *)attributedStringWithHeader:(NSString *)header
											  text:(NSString *)text;
@end
