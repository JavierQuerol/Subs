//
//  JAQSubsDownloader.m
//  Subs
//
//  Created by Javier Querol on 11/11/14.
//  Copyright (c) 2014 Javier Querol. All rights reserved.
//

#import "JAQSubtitleDownloader.h"
#import <zlib.h>
#import <AFNetworking.h>

@interface JAQSubtitleDownloader ()
@property (nonatomic, copy) NSString *authToken;
@property (nonatomic, copy) NSString *userAgent;
@property (nonatomic, strong) NSMutableDictionary *blockResponses;
@end

@implementation JAQSubtitleDownloader

- (instancetype)initWithUserAgent:(NSString *)userAgent {
	self = [super init];
	if (!self) return nil;
	
	_userAgent = userAgent;
	_blockResponses = [NSMutableDictionary dictionary];
	_state = JAQOpenSubtitleStateLoggingIn;
	
	if(!_languageString) _languageString = @"eng";
	
	[self login];
	return self;
}

- (void)notifyDelegateSomethingWrong {
	if (_delegate && [_delegate respondsToSelector:@selector(subtitleDownloadInvalid:)]) {
		[_delegate subtitleDownloadInvalid:self];
	}
}

#pragma mark API

- (void)setLanguageString:(NSString *)languageString {
	if (!languageString) languageString = @"eng";
	_languageString = languageString;
}

- (void)login {
	XMLRPCRequest *request = [self generateRequest];
	[request setMethod: @"LogIn" withParameters:@[@"", @"" , @"" , _userAgent]];
	
	XMLRPCConnectionManager *manager = [XMLRPCConnectionManager sharedManager];
	[manager spawnConnectionWithXMLRPCRequest:request delegate:self];
}

- (void)searchForSubtitlesWithHash:(NSString *)hash andFilesize:(NSNumber *)filesize :(void(^) (NSArray *subtitles))searchResult  {
	XMLRPCRequest *request = [self generateRequest];
	NSDecimalNumber *decimalFilesize = [NSDecimalNumber decimalNumberWithString:filesize.stringValue];
	
	if (decimalFilesize &&hash && _languageString && _authToken){
		NSDictionary *params = @{@"moviebytesize":decimalFilesize,
								 @"moviehash":hash,
								 @"sublanguageid":_languageString};
		
		[request setMethod:@"SearchSubtitles" withParameters:@[_authToken,@[params]]];
		
		NSString *searchHashCompleteID  = [NSString stringWithFormat:@"Search%@Complete", hash];
		[_blockResponses setObject:[searchResult copy] forKey:searchHashCompleteID];
		
		XMLRPCConnectionManager *manager = [XMLRPCConnectionManager sharedManager];
		[manager spawnConnectionWithXMLRPCRequest:request delegate:self];
	}
}

- (void)downloadSubtitlesForString:(NSString *)result toPath:(NSString *)path :(void(^)())onResultsFound {
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:result]];
	
	AFHTTPRequestOperation *subtitleDownloadRequest = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
	[subtitleDownloadRequest setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"subtitle.gzip"];
		[operation.responseData writeToFile:tempPath atomically:YES];
		[self unzipFileAtPath:tempPath toPath:path];
		onResultsFound(path);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[self notifyDelegateSomethingWrong];
	}];
	
	[subtitleDownloadRequest start];
}

- (XMLRPCRequest *)generateRequest {
	return [[XMLRPCRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.opensubtitles.org/xml-rpc"]];
}

- (void)unzipFileAtPath:(NSString *)fromPath toPath:(NSString *)toPath {
	int zipChunk = 16384;
	gzFile gZipFileRef = gzopen([fromPath UTF8String], "rb");
	FILE *fileRef = fopen([toPath UTF8String], "w");
	
	unsigned char buffer[zipChunk];
	int uncompressedLength;
	while ((uncompressedLength = gzread(gZipFileRef, buffer, zipChunk))) {
		if(fwrite(buffer, 1, uncompressedLength, fileRef) != uncompressedLength || ferror(fileRef)) {
			[self notifyDelegateSomethingWrong];
		}
	}
	
	fclose(fileRef);
	gzclose(gZipFileRef);
}

#pragma mark XMLRPC delegate methods

- (void)request:(XMLRPCRequest *)request didReceiveResponse:(XMLRPCResponse *)response {
	NSString *status = response.object[@"status"];
	if ([status isEqualToString:@"414 Unknown User Agent"]) {
		[self notifyDelegateSomethingWrong];
		return;
	}
	
	if ([request.method isEqualToString:@"LogIn"]) {
		_authToken = response.object[@"token"];
		_state = JAQOpenSubtitleStateLoggingIn;
		
		if (_delegate && [_delegate respondsToSelector:@selector(openSubtitlerDidLogIn:)]) {
			[_delegate openSubtitlerDidLogIn:self];
		}
	}
	
	if ([request.method isEqualToString:@"SearchSubtitles"]) {
		_state = JAQOpenSubtitleStateDownloading;
		NSMutableArray *searchResults = [NSMutableArray array];
		
		if ([response.object[@"data"] isKindOfClass:[NSArray class]]) {
			for (NSDictionary *dictionary in response.object[@"data"]) {
				[searchResults addObject:[JAQSubtitleResult resultFromDictionary:dictionary]];
			}
		}
		
		NSString *hash = request.parameters[1][0][@"moviehash"];
		NSString *searchHashCompleteID  = [NSString stringWithFormat:@"Search%@Complete", hash];
		
		void (^resultsBlock)(NSArray *subtitles) = [_blockResponses objectForKey:searchHashCompleteID];
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
			resultsBlock(searchResults);
		});
	}
}

- (void)request:(XMLRPCRequest *)request didFailWithError:(NSError *)error {
	[self notifyDelegateSomethingWrong];
}

- (BOOL)request:(XMLRPCRequest *)request canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	return YES;
}

- (void)request:(XMLRPCRequest *)request didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	
}

- (void)request:(XMLRPCRequest *)request didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	[self notifyDelegateSomethingWrong];
}

@end
