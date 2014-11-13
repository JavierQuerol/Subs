//
//  JAQVideo.m
//  Subs
//
//  Created by Javier Querol on 11/11/14.
//  Copyright (c) 2014 Javier Querol. All rights reserved.
//

#import "JAQVideo.h"

typedef struct {
	uint64_t fileHash;
	uint64_t fileSize;
} JAQVideoHashValues;

@implementation JAQVideo

- (NSString *)subtitleFilePath {
	NSString *fileWithoutExtension = [self.filePath stringByDeletingPathExtension];
	return [NSString stringWithFormat:@"%@.srt",fileWithoutExtension];
}

+ (JAQVideo *)videoFromFilePath:(NSString *)filePath {
	JAQVideo *video = [JAQVideo new];
	video.filePath = filePath;
	video.name = [[video.filePath componentsSeparatedByString:@"/"].lastObject stringByDeletingPathExtension];

	[video calculateHash];
	return video;
}

- (void)calculateHash {
	JAQVideoHashValues hash;
	hash.fileHash =0;
	hash.fileSize =0;
	
	NSFileHandle *readFile = [NSFileHandle fileHandleForReadingAtPath:self.filePath];
	hash = [JAQVideo hashForFile:readFile];
	[readFile closeFile];
	
	self.fileHash = [NSString stringWithFormat:@"%llX", hash.fileHash];
	self.fileSize = [NSNumber numberWithUnsignedLongLong:hash.fileSize];
}

+ (JAQVideoHashValues)hashForFile:(NSFileHandle*)handle {
	JAQVideoHashValues retHash;
	retHash.fileHash =0;
	retHash.fileSize =0;
	
	if( handle == nil )
		return retHash;
	
	const NSUInteger CHUNK_SIZE=65536;
	NSData *fileDataBegin, *fileDataEnd;
	uint64_t hash=0;
	
	
	fileDataBegin = [handle readDataOfLength:(NSUInteger)CHUNK_SIZE];
	[handle seekToEndOfFile];
	unsigned long long fileSize = [handle offsetInFile];
	if (fileSize < CHUNK_SIZE) return retHash;
	
	[handle seekToFileOffset:MAX(0,fileSize-CHUNK_SIZE) ];
	fileDataEnd = [handle readDataOfLength:(NSUInteger)CHUNK_SIZE];
	
	hash += fileSize;
	
	uint64_t * data_bytes= (uint64_t*)[fileDataBegin bytes];
	for (int i=0; i< CHUNK_SIZE/sizeof(uint64_t); i++) {
		hash+=data_bytes[i];
	}
	
	data_bytes= (uint64_t*)[fileDataEnd bytes];
	for (int i=0; i< CHUNK_SIZE/sizeof(uint64_t); i++) {
		hash+= data_bytes[i];
	}
	
	retHash.fileHash = hash;
	retHash.fileSize = fileSize;
	
	return retHash;
}

@end
