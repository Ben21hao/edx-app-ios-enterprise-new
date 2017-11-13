//
//  OEXVideoPathEntry.h
//  edXVideoLocker
//
//  Created by Akiva Leffert on 1/20/15.
//  Copyright (c) 2015-2016 edX. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSUInteger, OEXVideoPathEntryCategory) {
    OEXVideoPathEntryCategoryUnknown,
    OEXVideoPathEntryCategoryChapter, //章
    OEXVideoPathEntryCategorySection //节
};

@interface OEXVideoPathEntry : NSObject

- (id)initWithDictionary:(NSDictionary*)dictionary;
- (id)initWithEntryID:(NSString*)entryID name:(NSString*)name category:(NSString*)category;

@property (readonly, assign, nonatomic) OEXVideoPathEntryCategory category; //类型
@property (readonly, copy, nonatomic, nullable) NSString* entryID; //章节的ID
@property (readonly, copy, nonatomic, nullable) NSString* name;

@end

NS_ASSUME_NONNULL_END
