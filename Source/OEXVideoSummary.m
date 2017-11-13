//
//  OEXVideoSummaryList.m
//  edXVideoLocker
//
//  Created by Rahul Varma on 17/06/14.
//  Copyright (c) 2014 edX. All rights reserved.
//

#import "OEXVideoSummary.h"

#import "edX-Swift.h"
#import "OEXVideoEncoding.h"
#import "OEXVideoPathEntry.h"
#import "NSMutableDictionary+OEXSafeAccess.h"
#import "NSArray+OEXFunctional.h"
#import "NSArray+OEXSafeAccess.h"
#import "NSMutableDictionary+OEXSafeAccess.h"

@interface OEXVideoSummary ()

@property (nonatomic, copy) NSString* sectionURL;       // 网页的学习页面，用于在浏览器中打开

@property (nonatomic, copy) NSArray* path; // 章节数组 OEXVideoPathEntry array
@property (strong, nonatomic) OEXVideoPathEntry* chapterPathEntry;
@property (strong, nonatomic) OEXVideoPathEntry* sectionPathEntry;

@property (nonatomic, copy) NSString* category;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* videoThumbnailURL;
@property (nonatomic, copy) NSString* videoID;
@property (nonatomic, copy) NSString* unitURL;

@property (nonatomic, assign) BOOL onlyOnWeb;
@property (nonatomic, strong) NSDictionary* transcripts;
@property (nonatomic, strong) OEXVideoEncoding *defaultEncoding;
    
@end

@implementation OEXVideoSummary

- (id)initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    if(self != nil) {
        
        if([[dictionary objectForKey:@"section_url"] isKindOfClass:[NSString class]]) { //Section url
            self.sectionURL = [dictionary objectForKey:@"section_url"];
        }

        self.path = [[dictionary objectForKey:@"path"] oex_map:^(NSDictionary* pathEntryDict){
            return [[OEXVideoPathEntry alloc] initWithDictionary:pathEntryDict];
        }];

        self.unitURL = [dictionary objectForKey:@"unit_url"];

        NSDictionary* summary = [dictionary objectForKey:@"summary"];
        self.category = [summary objectForKey:@"category"]; // Data from inside summary dictionary

        self.name = [summary objectForKey:@"name"];
        if([self.name length] == 0 || self.name == nil) {
            self.name = TDLocalizeSelect(@"UNTITLED", nil);
        }
        
        self.videoThumbnailURL = [summary objectForKey:@"video_thumbnail_url"];
        self.videoID = [summary objectForKey:@"id"] ;
        
        //        self.duration = [OEXSafeCastAsClass([summary objectForKey:@"duration"], NSNumber) doubleValue];
        NSString *timeStr = summary[@"duration"];
        if (![timeStr isEqual:[NSNull null]]) {
            self.duration = [OEXSafeCastAsClass([NSNumber numberWithDouble:[summary[@"duration"] doubleValue]], NSNumber) stringValue];
        }
        
        self.onlyOnWeb = [[summary objectForKey:@"only_on_web"] boolValue];
        self.transcripts = [summary objectForKey:@"transcripts"];
        
        NSMutableDictionary* encodings = [[NSMutableDictionary alloc] init];
        NSDictionary* rawEncodings = OEXSafeCastAsClass(summary[@"encoded_videos"], NSDictionary);
        
        [rawEncodings enumerateKeysAndObjectsUsingBlock:^(NSString* name, NSDictionary* encodingInfo, BOOL *stop) {//遍历字典中中所有的key－value
            
            OEXVideoEncoding* encoding = [[OEXVideoEncoding alloc] initWithDictionary:encodingInfo name:name]; //将字典转为model
            [encodings safeSetObject:encoding forKey:name];
        }];
        self.encodings = encodings;
        
        if (_encodings.count <= 0) {
            _defaultEncoding = [[OEXVideoEncoding alloc] initWithName:OEXVideoEncodingFallback URL:[summary objectForKey:@"video_url"] size:[summary objectForKey:@"size"]];
        }
        
        NSLog(@"---------------------->>>>>>  %@",rawEncodings);
    }

    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary videoID:(NSString *)videoID name:(NSString *)name {
    
    self = [self initWithDictionary:dictionary];
    
//    NSLog(@"---------------------->>>>>>  %@",dictionary);
    
    if(self != nil) {
        self.videoID = videoID;
        self.name = name;
    }
    return self;
}

- (id)initWithVideoID:(NSString *)videoID name:(NSString *)name path:(NSArray *)path {
    
    self = [super init];
    if(self != nil) {
        
        self.videoID = videoID;
        self.name = name;
        self.path = path;
    }
    return self;
}

- (id)initWithVideoID:(NSString *)videoID name:(NSString *)name encodings:(NSDictionary<NSString*, OEXVideoEncoding *> *)encodings {
    
    self = [super init];
    if(self != nil) {
        
        self.name = name;
        self.videoID = videoID;
        self.encodings = encodings;
    }
    return self;
}

- (OEXVideoEncoding *)preferredEncoding {
    
    for(NSString* name in [OEXVideoEncoding knownEncodingNames]) {
        
        OEXVideoEncoding* encoding = self.encodings[name];
        if (encoding != nil) {
            return encoding;
        }
    }
    return self.defaultEncoding; // Don't have a known encoding, so return default encoding
}

- (BOOL)isYoutubeVideo {
    
    for(NSString* name in [OEXVideoEncoding knownEncodingNames]) {
        OEXVideoEncoding* encoding = self.encodings[name];
        
        NSString *name = [encoding name];
        if ([name isEqualToString:OEXVideoEncodingMobileHigh] || [name isEqualToString:OEXVideoEncodingMobileLow]) {
            return false;
            
        } else if ([[encoding name] isEqualToString:OEXVideoEncodingYoutube]) {
            return true;
        }
    }
    
    return false;
}

- (BOOL)isSupportedVideo {
    
    BOOL isSupportedEncoding = false;
    
    for(NSString* name in [OEXVideoEncoding knownEncodingNames]) {
        
        OEXVideoEncoding* encoding = self.encodings[name];
        NSString *name = [encoding name];
        
        if (([encoding URL] && [OEXInterface isURLForVideo:[encoding URL]]) && ([name isEqualToString:OEXVideoEncodingMobileHigh] || [name isEqualToString:OEXVideoEncodingMobileLow]))   {// fallback encoding can be with unsupported type like webm
            
            isSupportedEncoding = true;
            break;
        }
    }
    return !self.onlyOnWeb && isSupportedEncoding; //不仅仅在网页，且支持
}

- (NSString *)videoURL {
    return self.preferredEncoding.URL;
}

- (NSNumber *)size {
    return self.preferredEncoding.size;
}

- (OEXVideoPathEntry *)chapterPathEntry {
    __block OEXVideoPathEntry* result = nil;
    [self.path enumerateObjectsUsingBlock:^(OEXVideoPathEntry* entry, NSUInteger idx, BOOL* stop) {//遍历数组
        if(entry.category == OEXVideoPathEntryCategoryChapter) {
            result = entry;
            *stop = YES;
        }
    }];
    return result;
}

- (OEXVideoPathEntry *)sectionPathEntry {
    
    __block OEXVideoPathEntry* result = nil;
    [self.path enumerateObjectsUsingBlock:^(OEXVideoPathEntry* entry, NSUInteger idx, BOOL* stop) { //遍历数组
        if(entry.category == OEXVideoPathEntryCategorySection) {
            result = entry;
            *stop = YES;
        }
    }];
    return result;
}

- (NSArray *)displayPath {
    
    NSMutableArray* result = [[NSMutableArray alloc] init];
    if(self.chapterPathEntry != nil) {
        [result addObject:self.chapterPathEntry];
    }
    
    if(self.sectionPathEntry) {
        [result addObject:self.sectionPathEntry];
    }
    return result;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, video_id=%@>", [self class], self, self.videoID];
}


@end
