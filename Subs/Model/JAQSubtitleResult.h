//
//  JAQSubtitleResult.h
//  Subs
//
//  Created by Javier Querol on 11/11/14.
//  Copyright (c) 2014 Javier Querol. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JAQSubtitleResult : NSObject

+ (instancetype)resultFromDictionary:(NSDictionary *)dictionary;

@property (copy) NSString *subtitleID;
@property (copy) NSString *imdbID;
@property (copy) NSString *subtitleLanguage;
@property (copy) NSString *iso639Language;
@property (copy) NSString *subtitleDownloadAddress;

@end
