//
//  JAQSubsDownloader.h
//  Subs
//
//  Created by Javier Querol on 11/11/14.
//  Copyright (c) 2014 Javier Querol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JAQSubtitleResult.h"
#import <XMLRPC.h>

@class JAQSubtitleDownloader;

typedef enum {
	JAQOpenSubtitleStateLoggingIn,
	JAQOpenSubtitleStateLoggedIn,
	JAQOpenSubtitleStateSearching,
	JAQOpenSubtitleStateDownloading,
	JAQOpenSubtitleStateDownloaded
} JAQOpenSubtitleState;


@protocol JAQSubsDownloaderDelegate <NSObject>
@optional
- (void)openSubtitlerDidLogIn:(JAQSubtitleDownloader *)downloader;
- (void)subtitleDownloadInvalid:(JAQSubtitleDownloader *)downloader;
@end

@interface JAQSubtitleDownloader : NSObject <XMLRPCConnectionDelegate>

- (instancetype)initWithUserAgent:(NSString *)userAgent;

@property (nonatomic, weak) NSObject <JAQSubsDownloaderDelegate> *delegate;
@property (nonatomic, readonly) JAQOpenSubtitleState state;
@property (nonatomic, copy) NSString *languageString;

- (void)searchForSubtitlesWithHash:(NSString *)hash
					   andFilesize:(NSNumber *)filesize
								  :(void(^)(NSArray *subtitles))searchResult;

- (void)downloadSubtitlesForString:(NSString *)result
							toPath:(NSString *)path
								  :(void(^)())onResultsFound;

@end
