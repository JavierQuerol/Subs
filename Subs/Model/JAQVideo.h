//
//  JAQVideo.h
//  Subs
//
//  Created by Javier Querol on 11/11/14.
//  Copyright (c) 2014 Javier Querol. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JAQVideo : NSObject

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *fileHash;
@property (nonatomic, copy) NSNumber *fileSize;

+ (JAQVideo *)videoFromFilePath:(NSString *)filePath;
- (NSString *)subtitleFilePath;

@end
