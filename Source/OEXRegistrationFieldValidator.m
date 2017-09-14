//
//  OEXRegistrationFieldValidation.m
//  edXVideoLocker
//
//  Created by Jotiram Bhagat on 03/03/15.
//  Copyright (c) 2015 edX. All rights reserved.
//

#import "OEXRegistrationFieldValidator.h"

#import "edX-Swift.h"
#import "NSString+OEXFormatting.h"

@implementation OEXRegistrationFieldValidator

+ (NSString*)validateField:(OEXRegistrationFormField*)field withText:(NSString*)currentValue {
    NSString* errorMessage;
    if(field.isRequired && (currentValue == nil || [currentValue isEqualToString:@""])) {
        if(!field.errorMessage.required) {
            return [TDLocalizeSelect(@"REGISTRATION_FIELD_EMPTY_ERROR", nil) oex_formatWithParameters:@{@"field_name" : field.label}];
        }
        else {
            return field.errorMessage.required;
        }
    }

    NSInteger length = [currentValue length];
    if(length < field.restriction.minLength) {
        if(!field.errorMessage.minLength) {
            return [Strings registrationFieldMinLengthError:field.label count:@(field.restriction.minLength).description](field.restriction.minLength);
        }
        else {
            return field.errorMessage.minLength;
        }
    }
    if(length > field.restriction.maxLength && field.restriction.maxLength != 0) {
        if(!field.errorMessage.maxLength) {
            NSString* errorMessage = [Strings registrationFieldMaxLengthError:field.label count:@(field.restriction.maxLength).description](field.restriction.maxLength);
            return errorMessage;
        }
        else {
            return field.errorMessage.maxLength;
        }
    }
    return errorMessage;
}
@end
