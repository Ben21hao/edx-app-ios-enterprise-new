//
//  OEXUserDetails.m
//  edXVideoLocker
//
//  Created by Rahul Varma on 05/06/14.
//  Copyright (c) 2014 edX. All rights reserved.
//

#import "OEXUserDetails.h"
#import "OEXSession.h"
#import "NSMutableDictionary+OEXSafeAccess.h"
#import <MJExtension/MJExtension.h>
#import "LanguageChangeTool.h"

static OEXUserDetails* user = nil;

static NSString* const OEXUserDetailsEmailKey = @"email";
static NSString* const OEXUserDetailsUserNameKey = @"username";
static NSString* const OEXUserDetailsCourseEnrollmentsKey = @"course_enrollments";
static NSString* const OEXUserDetailsNameKey = @"name";
static NSString* const OEXUserDetailsUserIdKey = @"id";
static NSString* const OEXUserDetailsUrlKey = @"url";

static NSString* const OEXUserDetailsPhoneNubmerKey = @"mobile";//手机号码
static NSString* const OEXUserDetailsNickNameKey = @"nick_name";//昵称
static NSString* const OEXUserDetailsCompanyLanguageKey = @"language";//语言习惯

static NSString* const OEXUserDetailsCompanyKey = @"company"; //公司key
static NSString* const OEXUserDetailsCompanyIdKey = @"id";//公司id
static NSString* const OEXUserDetailsCompanyLogoKey = @"logo";//公司logo
static NSString* const OEXUserDetailsCompanyRemainAmoutKey = @"remain_amount";//公司剩余金额
static NSString* const OEXUserDetailsCompanyTotalAmountKey = @"total_amount";//公司总金额
static NSString* const OEXUserDetailsCompanyRemainCoinKey = @"remain_coin";//公司剩余宝典
static NSString* const OEXUserDetailsCompanyTotalCoinKey = @"total_coin";//公司总宝典
static NSString* const OEXUserDetailsCompanyIsActiveKey = @"is_active";//公司有效性，默认为true
static NSString* const OEXUserDetailsCompanyFullNameKey = @"full_name";//公司全名
static NSString* const OEXUserDetailsCompanyShortNameKey = @"short_name";//公司简称
static NSString* const OEXUserDetailsCompanyEnglishNameKey = @"english_name";//公司英文名字
static NSString* const OEXUserDetailsCompanyIntroductionKey = @"introduction";//公司介绍
static NSString* const OEXUserDetailsCompanyDomainNameKey = @"domain_name";//公司域名

@implementation OEXUserDetails

//- (id)copyWithZone:(NSZone*)zone {
//    id copy = [[OEXUserDetails alloc] initWithUserName:self.username email:self.email courseEnrollments:self.course_enrollments name:self.name userId:self.userId andUrl:self.url];
//    ;
//    return copy;
//}
- (id)copyWithZone:(NSZone*)zone {
    id copy = [[OEXUserDetails alloc] initWithUserName:self.username email:self.email courseEnrollments:self.course_enrollments name:self.name userId:self.userId Url:self.url PhoneNumber:self.mobile andNickName:self.nick_name];
    ;
    return copy;
}


//- (id)initWithUserName:(NSString*)username email:(NSString*)email courseEnrollments:(NSString*)course_enrollments name:(NSString*)name userId:(NSNumber*)userId andUrl:(NSString*)url {
//    if((self = [super init])) {
//        _username = [username copy];
//        _email = [email copy];
//        _course_enrollments = [course_enrollments copy];
//        _name = [name copy];
//        _userId = [userId copy];
//        _url = [url copy];
//    }
//    return self;
//}
- (id)initWithUserName:(NSString*)username email:(NSString*)email courseEnrollments:(NSString*)course_enrollments name:(NSString*)name userId:(NSNumber*)userId Url:(NSString*)url PhoneNumber:(NSString *)phoneNumber andNickName:(NSString *)nickName{
    
    if((self = [super init])) {
        _username = [username copy];
        _email = [email copy];
        _course_enrollments = [course_enrollments copy];
        _name = [name copy];
        _userId = [userId copy];
        _url = [url copy];
        
        _mobile = [_mobile copy];//手机号码
        _nick_name = [_nick_name copy];//昵称
        _language = [_language copy];
        
        /*公司信息*/
        _company_id = [_company_id copy];
        _logo = [_logo copy];
        _remain_amount = [_remain_amount copy];
        _total_amount = [_total_amount copy];
        _remain_coin = [_remain_coin copy];
        _total_coin = [_total_coin copy];
        _is_active = [_is_active copy];
        _full_name = [_full_name copy];
        _short_name = [_short_name copy];
        _english_name = [_english_name copy];
        _introduction = [_introduction copy];
        _domain_name = [_domain_name copy];
        
    }
    return self;
}

//- (id)initWithUserDictionary:(NSDictionary*)userDetailsDictionary {
//    self = [super init];
//    if(self) {
//        NSString* dictionaryUserName = userDetailsDictionary[OEXUserDetailsUserNameKey];
//        NSString* dictionaryCourseEnrollments = userDetailsDictionary[OEXUserDetailsCourseEnrollmentsKey];
//        if(dictionaryUserName == nil || [dictionaryUserName stringByTrimmingCharactersInSet:
//                                         [NSCharacterSet whitespaceCharacterSet]].length == 0) {
//            return nil;
//        }
//
//        if(dictionaryCourseEnrollments == nil || [dictionaryCourseEnrollments stringByTrimmingCharactersInSet:
//                                                  [NSCharacterSet whitespaceCharacterSet]].length == 0) {
//            return nil;
//        }
//
//        _email = [userDetailsDictionary objectForKey:OEXUserDetailsEmailKey];
//        _username = [userDetailsDictionary objectForKey:OEXUserDetailsUserNameKey];
//        _course_enrollments = [userDetailsDictionary objectForKey:OEXUserDetailsCourseEnrollmentsKey];
//        _userId = [userDetailsDictionary objectForKey:OEXUserDetailsUserIdKey];
//        _name = [userDetailsDictionary objectForKey:OEXUserDetailsNameKey];
//        _url = [userDetailsDictionary objectForKey:OEXUserDetailsUrlKey];
//    }
//
//    return self;
//}
- (id)initWithUserDictionary:(NSDictionary *)userDetailsDictionary {
    self = [super init];
    
    if(self) {
        NSString* dictionaryUserName = userDetailsDictionary[OEXUserDetailsUserNameKey];
        NSString* dictionaryCourseEnrollments = userDetailsDictionary[OEXUserDetailsCourseEnrollmentsKey];
        
        if(dictionaryUserName == nil || [dictionaryUserName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]].length == 0) {
            return nil;
        }
        
        if(dictionaryCourseEnrollments == nil || [dictionaryCourseEnrollments stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]].length == 0) {
            return nil;
        }
        
        _email = [userDetailsDictionary objectForKey:OEXUserDetailsEmailKey];
        if ([_email isEqual:[NSNull null]]) {
            _email = nil;
        }
        _username = [userDetailsDictionary objectForKey:OEXUserDetailsUserNameKey];
        if ([_username isEqual:[NSNull null]]) {
            _username = nil;
        }
        _course_enrollments = [userDetailsDictionary objectForKey:OEXUserDetailsCourseEnrollmentsKey];
        if ([_course_enrollments isEqual:[NSNull null]]) {
            _course_enrollments = nil;
        }
        _userId = [userDetailsDictionary objectForKey:OEXUserDetailsUserIdKey];
        _name = [userDetailsDictionary objectForKey:OEXUserDetailsNameKey];
        if ([_name isEqual:[NSNull null]]) {
            _name = nil;
        }
        _url = [userDetailsDictionary objectForKey:OEXUserDetailsUrlKey];
        if ([_url isEqual:[NSNull null]]) {
            _url = nil;
        }
        //手机号码
        _mobile = [userDetailsDictionary objectForKey:OEXUserDetailsPhoneNubmerKey];
        if ([_mobile isEqual:[NSNull null]]) {
            _mobile = nil;
        }
        //昵称
        _nick_name = [userDetailsDictionary objectForKey:OEXUserDetailsNickNameKey];
        if ([_nick_name isEqual:[NSNull null]]) {
            _nick_name = nil;
        }
        
        //用户语言习惯
        _language = [userDetailsDictionary objectForKey:OEXUserDetailsCompanyLanguageKey];
        if ([_language isEqual:[NSNull null]]) {
            _language = nil;
        }
        NSLog(@"用户语言 ---->>>> %@",_language);
        
        [[NSUserDefaults standardUserDefaults] setValue:_language forKey:@"userLanguage"];
        NSString *str = [_language isEqualToString:@"en"] ? @"en" : @"zh-Hans";
        [LanguageChangeTool setUserlanguage:str];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"languageSelectedChange" object:nil];
        
        /*公司信息*/
        NSDictionary *companyDic = userDetailsDictionary[OEXUserDetailsCompanyKey];
        _logo = companyDic[OEXUserDetailsCompanyLogoKey];
        if ([_logo isEqual:[NSNull null]]) {
            _logo = nil;
        }
        
        _company_id = [NSString stringWithFormat:@"%@",[companyDic objectForKey:OEXUserDetailsCompanyIdKey]];
        if ([_company_id isEqual:[NSNull null]]) {
            _company_id = nil;
        }

        _remain_amount = [NSString stringWithFormat:@"%@",[companyDic objectForKey:OEXUserDetailsCompanyRemainAmoutKey]];
        if ([_remain_amount isEqual:[NSNull null]]) {
            _remain_amount = nil;
        }
        _total_amount = [NSString stringWithFormat:@"%@",[companyDic objectForKey:OEXUserDetailsCompanyTotalAmountKey]];
        if ([_total_amount isEqual:[NSNull null]]) {
            _total_amount = nil;
        }
        _remain_coin = [NSString stringWithFormat:@"%@",[companyDic objectForKey:OEXUserDetailsCompanyRemainCoinKey]];
        if ([_remain_coin isEqual:[NSNull null]]) {
            _remain_coin = nil;
        }
        _total_coin = [NSString stringWithFormat:@"%@",[companyDic objectForKey:OEXUserDetailsCompanyTotalCoinKey]];
        if ([_total_coin isEqual:[NSNull null]]) {
            _total_coin = nil;
        }
        _is_active = [NSString stringWithFormat:@"%@",[companyDic objectForKey:OEXUserDetailsCompanyIsActiveKey]];
        if ([_is_active isEqual:[NSNull null]]) {
            _is_active = nil;
        }
        _full_name = [companyDic objectForKey:OEXUserDetailsCompanyFullNameKey];
        if ([_full_name isEqual:[NSNull null]]) {
            _full_name = nil;
        }
        _short_name = [companyDic objectForKey:OEXUserDetailsCompanyShortNameKey];
        if ([_short_name isEqual:[NSNull null]]) {
            _short_name = nil;
        }
        _english_name = [companyDic objectForKey:OEXUserDetailsCompanyEnglishNameKey];
        if ([_english_name isEqual:[NSNull null]]) {
            _english_name = nil;
        }
        _introduction = [companyDic objectForKey:OEXUserDetailsCompanyIntroductionKey];
        if ([_introduction isEqual:[NSNull null]]) {
            _introduction = nil;
        }
        
        _domain_name = [companyDic objectForKey:OEXUserDetailsCompanyDomainNameKey];
        if ([_domain_name isEqual:[NSNull null]]) {
            _domain_name = nil;
        }
    }
    
    return self;
}


//- (NSData*)userDetailsData {
//    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
//    if(_username && _course_enrollments) {
//        [dict safeSetObject:_username forKey:OEXUserDetailsUserNameKey];
//        [dict setObjectOrNil:_email forKey:OEXUserDetailsEmailKey];
//        [dict safeSetObject:_course_enrollments forKey:OEXUserDetailsCourseEnrollmentsKey];
//        [dict setObjectOrNil:_userId forKey:OEXUserDetailsUserIdKey];
//        [dict setObjectOrNil:_url forKey:OEXUserDetailsUrlKey];
//        [dict setObjectOrNil:_name forKey:OEXUserDetailsNameKey];
//    }
//    else {
//        return nil;
//    }
//
//    NSError* error = nil;
//    NSData* data = [NSPropertyListSerialization dataWithPropertyList:dict format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
//    NSAssert(error == nil, @"UserDetails error => %@ ", [error description]);
//    return data;
//}
- (NSData *)userDetailsData {
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    NSLog(@"%@ ---->>> %@",_username,_course_enrollments);
    
    if(_username && _course_enrollments) {
        [dict safeSetObject:_username forKey:OEXUserDetailsUserNameKey];
        [dict setObjectOrNil:_email forKey:OEXUserDetailsEmailKey];
        [dict safeSetObject:_course_enrollments forKey:OEXUserDetailsCourseEnrollmentsKey];
        [dict setObjectOrNil:_userId forKey:OEXUserDetailsUserIdKey];
        [dict setObjectOrNil:_url forKey:OEXUserDetailsUrlKey];
        [dict setObjectOrNil:_name forKey:OEXUserDetailsNameKey];
        
        [dict setObjectOrNil:_mobile forKey:OEXUserDetailsPhoneNubmerKey]; //手机号码
        [dict setObjectOrNil:_nick_name forKey:OEXUserDetailsNickNameKey];//昵称
        [dict setObjectOrNil:_language forKey:OEXUserDetailsCompanyLanguageKey]; //语言习惯
        
        /*公司信息*/
        NSMutableDictionary *companyDic = [NSMutableDictionary dictionary];
        [companyDic setObjectOrNil:_company_id forKey:OEXUserDetailsCompanyIdKey];
        [companyDic setObjectOrNil:_logo forKey:OEXUserDetailsCompanyLogoKey];
        [companyDic setObjectOrNil:_remain_amount forKey:OEXUserDetailsCompanyRemainAmoutKey];
        [companyDic setObjectOrNil:_total_amount forKey:OEXUserDetailsCompanyTotalAmountKey];
        [companyDic setObjectOrNil:_remain_coin forKey:OEXUserDetailsCompanyRemainCoinKey];
        [companyDic setObjectOrNil:_total_coin forKey:OEXUserDetailsCompanyTotalCoinKey];
        [companyDic setObjectOrNil:_is_active forKey:OEXUserDetailsCompanyIsActiveKey];
        [companyDic setObjectOrNil:_full_name forKey:OEXUserDetailsCompanyFullNameKey];
        [companyDic setObjectOrNil:_short_name forKey:OEXUserDetailsCompanyShortNameKey];
        [companyDic setObjectOrNil:_english_name forKey:OEXUserDetailsCompanyEnglishNameKey];
        [companyDic setObjectOrNil:_introduction forKey:OEXUserDetailsCompanyIntroductionKey];
        [companyDic setObjectOrNil:_domain_name forKey:OEXUserDetailsCompanyDomainNameKey];
        
        [dict setObjectOrNil:companyDic forKey:OEXUserDetailsCompanyKey];
        
    } else {
        return nil;
    }

    NSError* error = nil;
    NSData* data = [NSPropertyListSerialization dataWithPropertyList:dict format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];//缓存
    NSAssert(error == nil, @"UserDetails error => %@ ", [error description]);
    return data;
}


- (id)initWithUserDetailsData:(NSData *)data {
    NSError* error = nil;
    NSDictionary* userDetailsDictionary = [NSPropertyListSerialization propertyListWithData:data options:0 format:NULL error:&error];
    NSAssert(error == nil, @"Error extracting user details: %@", error);
    
    return [self initWithUserDictionary:userDetailsDictionary];
}

@end
