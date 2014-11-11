//
//  JAQSubtitleResult.m
//  Subs
//
//  Created by Javier Querol on 11/11/14.
//  Copyright (c) 2014 Javier Querol. All rights reserved.
//

#import "JAQSubtitleResult.h"

@implementation JAQSubtitleResult

+ (instancetype)resultFromDictionary:(NSDictionary *)dictionary {
	JAQSubtitleResult *object = [JAQSubtitleResult new];
	
	object.subtitleID = dictionary[@"IDSubtitleFile"];
	object.imdbID = dictionary[@"IDMovieImdb"];
	object.subtitleLanguage = dictionary[@"SubLanguageID"];
	object.iso639Language = dictionary[@"ISO639"];
	object.subtitleDownloadAddress = dictionary[@"SubDownloadLink"];
	
	return object;
}

@end
