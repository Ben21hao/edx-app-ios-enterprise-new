//
//  NSError+OEXKnownErrors.m
//  edXVideoLocker
//
//  Created by Akiva Leffert on 3/19/15.
//  Copyright (c) 2015 edX. All rights reserved.
//

#import "NSError+OEXKnownErrors.h"

#import "edX-Swift.h"

#import "OEXCoursewareAccess.h"
#import "OEXCourse.h"
#import "OEXDateFormatting.h"
#import "OEXTextStyle.h"
#import "NSAttributedString+OEXFormatting.h"

NSString* const OEXErrorDomain = @"org.edx.error";

@implementation NSError (OEXKnownErrors)

+ (NSError*)oex_errorWithCode:(OEXErrorCode)code message:(nonnull NSString *)message {
    return [self errorWithDomain:OEXErrorDomain code:code userInfo:@{
                                                                     NSLocalizedDescriptionKey: message
                                                                     }];
}

+ (NSError*)oex_courseContentLoadError {
    return [self oex_errorWithCode:OEXErrorCodeCouldNotLoadCourseContent message:TDLocalizeSelect(@"UNABLE_TO_LOAD_COURSE_CONTENT", nil)];
}

+ (NSError*)oex_invalidURLError {
    return [self oex_errorWithCode:OEXErrorCodeInvalidURL message:TDLocalizeSelect(@"UNABLE_TO_LOAD_COURSE_CONTENT", nil)];
}

+ (NSError*)oex_unknownError {
    return [self oex_errorWithCode:OEXErrorCodeUnknown message:TDLocalizeSelect(@"UNABLE_TO_LOAD_COURSE_CONTENT", nil)];
}

@end

@interface OEXCoursewareAccessError ()

@property (strong, nonatomic) OEXCoursewareAccess* access;
@property (strong, nonatomic) OEXCourseStartDisplayInfo* displayInfo;

@end

@implementation OEXCoursewareAccessError

- (id)initWithCoursewareAccess:(OEXCoursewareAccess*)access displayInfo:(nullable OEXCourseStartDisplayInfo*)displayInfo {
    self = [super initWithDomain: OEXErrorDomain
            code:OEXErrorCodeCoursewareAccess
            userInfo:@{
                       NSLocalizedDescriptionKey : access.user_message ?: TDLocalizeSelect(@"UNABLE_TO_LOAD_COURSE_CONTENT", nil)
                       }];
    if(self != nil) {
        self.access = access;
        self.displayInfo = displayInfo;
    }
    return self;
}

- (NSAttributedString*)attributedDescriptionWithBaseStyle:(OEXTextStyle*)style {

    switch (self.access.error_code) {
        case OEXStartDateError: {
            
            NSAttributedString*(^template)(NSAttributedString*) = [style apply:^(NSString* s){ return [TDLocalizeSelect(@"COURSE_WILL_START_AT", nil) oex_formatWithParameters:@{@"date" : s}]; }];
            if(self.displayInfo.type == OEXStartTypeString && self.displayInfo.displayDate.length > 0) {
                NSAttributedString* styledDate = [style.withWeight(OEXTextWeightBold) attributedStringWithText:self.displayInfo.displayDate];
                NSAttributedString* message = template(styledDate);
                return message;
            }
            else if(self.displayInfo.type == OEXStartTypeTimestamp && self.displayInfo.date != nil) {
                NSString* displayDate = [OEXDateFormatting formatAsMonthDayYearString: self.displayInfo.date];
                NSAttributedString* styledDate = [style.withWeight(OEXTextWeightBold) attributedStringWithText:displayDate]; 
                NSAttributedString* message = template(styledDate);
                return message;
            }
            else {
                return [style attributedStringWithText: TDLocalizeSelect(@"COURSE_NOT_STARTED", nil)];
            }
        }
        case OEXMilestoneError:
        case OEXVisibilityError:
        case OEXUnknownError:
            return [style attributedStringWithText: self.access.user_message ?: TDLocalizeSelect(@"COURSEWARE_UNAVAILABLE", nil)];
    }

}

@end
