//
//  OEXPersistentCredentialStorage.m
//  edXVideoLocker
//
//  Created by Abhradeep on 20/01/15.
//  Copyright (c) 2015 edX. All rights reserved.
//

#import "OEXPersistentCredentialStorage.h"

#import "edX-Swift.h"
#import "Logger+OEXObjC.h"

#import "OEXAccessToken.h"
#import "OEXUserDetails.h"

#import <Security/Security.h>

#define kAccessTokenKey @"kAccessTokenKey_enterprise"
#define kUserDetailsKey @"kUserDetailsKey_enterprise"
#define kCredentialsService @"kCredentialsService_enterprise"

@implementation OEXPersistentCredentialStorage

+ (instancetype)sharedKeychainAccess {
    static dispatch_once_t onceToken;
    static OEXPersistentCredentialStorage* sharedKeychainAccess = nil;
    dispatch_once(&onceToken, ^{
        sharedKeychainAccess = [[OEXPersistentCredentialStorage alloc] init];
    });
    return sharedKeychainAccess;
}

/* 保存用户token和信息 */
- (void)saveAccessToken:(OEXAccessToken*)accessToken userDetails:(OEXUserDetails*)userDetails {
    NSData* accessTokenData = [accessToken accessTokenData];
    NSData* userDetailsData = [userDetails userDetailsData];
    NSDictionary* sessionDictionary = @{kAccessTokenKey:accessTokenData, kUserDetailsKey:userDetailsData};
    [self saveService:kCredentialsService data:sessionDictionary];
}

- (void)clear {//清除用户缓存 cookie
    [self deleteService:kCredentialsService];
    
    NSHTTPCookieStorage* cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for(NSHTTPCookie* cookie in [cookieStorage cookies]) {
        [cookieStorage deleteCookie:cookie];
    }
    
    NSURLCredentialStorage* credentialStorage = [NSURLCredentialStorage sharedCredentialStorage];
    NSDictionary* allCredentials = credentialStorage.allCredentials;
    for(NSURLProtectionSpace* space in allCredentials.allKeys) {
        NSDictionary* spaceCredentials = allCredentials[space];
        for(NSURLCredential* credential in spaceCredentials.allValues) {
            [credentialStorage removeCredential:credential forProtectionSpace:space];
        }
    }
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (OEXAccessToken*)storedAccessToken {//获取已登录token
    return [OEXAccessToken accessTokenWithData:[[self loadService:kCredentialsService] objectForKey:kAccessTokenKey]];
}

- (OEXUserDetails*)storedUserDetails {//获取已登录的用户信息
    NSData* data = [[self loadService:kCredentialsService] objectForKey:kUserDetailsKey];
    if(data && [data isKindOfClass:[NSData class]]) {
        return [[OEXUserDetails alloc] initWithUserDetailsData:data];
    }
    else {
        return nil;
    }
}

- (void)saveService:(NSString*)service data:(id)data {
    OSStatus result;
    NSMutableDictionary* keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);   //删除 Keychain 中符号查询条件的记录
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge id)kSecValueData];
    result = SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL); //往 Keychain 里增加一条数据
#ifdef DEBUG
    NSAssert(result == noErr, @"Could not add credential to keychain");
#endif
}

- (id)loadService:(NSString*)service {
    id ret = nil;
    NSMutableDictionary* keychainQuery = [self getKeychainQuery:service];
    [keychainQuery setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [keychainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if(SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef*)&keyData) == noErr) { //查询Keychain里是否有符号条件的记录
        // TODO: Replace this with code that doesn't raise and swallow exceptions
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData*)keyData]; //反归档
        }
        @catch(NSException* e) {
            OEXLogInfo(@"STORAGE", @"Unarchive of %@ failed: %@", service, e);
        }
        @finally {}
    }
    if(keyData) {
        CFRelease(keyData); //释放掉一个类的所占的内存
    }
    return ret;
}

- (void)deleteService:(NSString*)service {
    NSMutableDictionary* keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery); //删除 Keychain 中符号查询条件的记录
}

- (NSMutableDictionary*)getKeychainQuery:(NSString*)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge id)kSecClassGenericPassword, (__bridge id)kSecClass,
            service, (__bridge id)kSecAttrService,
            service, (__bridge id)kSecAttrAccount,
            (__bridge id)kSecAttrAccessibleAfterFirstUnlock, (__bridge id)kSecAttrAccessible,
            nil];
}

@end
