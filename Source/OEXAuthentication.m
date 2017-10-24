//
//  OEXAuthentication.m
//  edXVideoLocker
//
//  Created by Jotiram Bhagat on 25/06/14.
//  Copyright (c) 2014 edX. All rights reserved.
//

#import "OEXAuthentication.h"

#import "NSDictionary+OEXEncoding.h"
#import "NSError+OEXKnownErrors.h"
#import "NSMutableDictionary+OEXSafeAccess.h"
#import "NSString+OEXFormatting.h"

#import "OEXAccessToken.h"
#import "OEXAppDelegate.h"
#import "OEXConfig.h"
#import "OEXExternalAuthProvider.h"
#import "OEXFacebookAuthProvider.h"
#import "OEXFBSocial.h"
#import "OEXGoogleAuthProvider.h"
#import "OEXGoogleSocial.h"
#import "OEXHTTPStatusCodes.h"
#import "OEXInterface.h"
#import "OEXNetworkConstants.h"
#import "OEXUserDetails.h"
#import "OEXSession.h"
#import "edX-Swift.h"

NSString* const facebook_login_endpoint = @"facebook";
NSString* const google_login_endpoint = @"google-oauth2";

typedef void (^ OEXSocialLoginCompletionHandler)(NSString* accessToken, NSError* error);

@interface OEXAuthentication ()
@property(nonatomic, strong) OEXAccessToken* edxToken;
@end

typedef void (^OEXNSDataTaskRequestHandler)(NSData* data, NSURLResponse* response, NSError* error) ;

// All our NSURLResponses are HTTP responses, so this wraps up the cast into one place
OEXNSDataTaskRequestHandler OEXWrapURLCompletion(OEXURLRequestHandler completion) {
    return ^(NSData* data, NSURLResponse* response, NSError* error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Hacky - We should be using a networking library that manages this for us
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            completion(data, (NSHTTPURLResponse*)response, error);
        });
    };
}

@implementation OEXAuthentication

//This method gets called when user try to login with username password - 当用户尝试使用用户名口令登录时，该方法将被调用
+ (void)requestTokenWithUser:(NSString* )username password:(NSString* )password completionHandler:(OEXURLRequestHandler)completionBlock {
    
    NSString* body = [self plainTextAuthorizationHeaderForUserName:username password:password];
    
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders:[sessionConfig defaultHTTPHeaders]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [OEXConfig sharedConfig].apiHostURL, AUTHORIZATION_URL]];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig];
    [[session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        
            NSHTTPURLResponse* httpResp = (NSHTTPURLResponse*) response;
            if(httpResp.statusCode == OEXHTTPStatusCode200OK) {
                
                NSError* error;
                NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                OEXAccessToken* token = [[OEXAccessToken alloc] initWithTokenDetails:dictionary];
                
                id code = dictionary[@"code"];
//                NSLog(@"接口--------->>>%@ ------>> %@",code,dictionary);
                
                [[NSUserDefaults standardUserDefaults] setValue:code forKey:@"User_Login_Failed_Code"];//400 密码错误， 402 账号未激活， 403 账号未激活 ，404 账号不存在
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [OEXAuthentication handleSuccessfulLoginWithToken:token completionHandler:completionBlock];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(data, httpResp, error);
                });
            }
        }] resume];
}

+ (void)executePOSTRequestWithPath:(NSString*)path parameters:(NSDictionary*)parameters completion:(OEXURLRequestHandler)completion {
    NSURL* hostURL = [[OEXConfig sharedConfig] apiHostURL];
    NSURL* endpoint = [NSURL URLWithString:path relativeToURL:hostURL];
    
    NSString* body = [parameters oex_stringByUsingFormEncoding];
    NSData* bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:endpoint];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:bodyData];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig];
    [[session dataTaskWithRequest:request completionHandler:OEXWrapURLCompletion(completion)] resume];
}

+ (void)requestTokenWithProvider:(id <OEXExternalAuthProvider>)provider externalToken:(NSString *)token completion:(OEXURLRequestHandler)completionBlock {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES]; //状态栏显示网络标志
    
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
    [parameters safeSetObject:token forKey:@"access_token"];
    [parameters safeSetObject:[[OEXConfig sharedConfig] oauthClientID] forKey:@"client_id"];
    NSString* path = [NSString oex_stringWithFormat:URL_EXCHANGE_TOKEN parameters:@{@"backend" : provider.backendName}];
    
    [self executePOSTRequestWithPath:path parameters:parameters completion:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
        if(!error) {
            NSHTTPURLResponse* httpResp = (NSHTTPURLResponse*) response;
            if(httpResp.statusCode == 200) {
                NSError* error;
                NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                NSAssert(error == nil, @"Invalid JSON from server");
                OEXAccessToken* token = [[OEXAccessToken alloc] initWithTokenDetails:dictionary];
                [self handleSuccessfulLoginWithToken:token completionHandler:completionBlock];
                return;
            }
            else if(httpResp.statusCode == 401) {
                error = [NSError errorWithDomain:@"Not valid user" code:401 userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObject:@"You are not associated with edx please signup up from website"] forKeys:[NSArray arrayWithObject:@"failed"]]];
            }
        }
        OEXWrapURLCompletion(completionBlock)(data, response, error);
    }];
}

//通过 email 重置密码
+ (void)resetPasswordWithEmailId:(NSString*)email completionHandler:(OEXURLRequestHandler)completionBlock {
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
    [parameters safeSetObject:email forKey:@"email"];
    [parameters safeSetObject:@"1" forKey:@"is_company"]; //标明是企业版
    [self executePOSTRequestWithPath:URL_RESET_PASSWORD parameters:parameters completion:completionBlock];
}

// This retuns header for password authentication method - 这头返回密码验证的方法
+ (NSString*)plainTextAuthorizationHeaderForUserName:(NSString*)userName password:(NSString*)password {
    NSString* clientID = [[OEXConfig sharedConfig] oauthClientID];
    
    NSMutableDictionary* arguments = [[NSMutableDictionary alloc] init];
    [arguments safeSetObject:clientID forKey:@"client_id"];
    [arguments safeSetObject:@"password" forKey:@"grant_type"];
    [arguments safeSetObject:userName forKey:@"username"];
    [arguments safeSetObject:password forKey:@"password"];
    [arguments safeSetObject:@"1" forKey:@"is_enterprise"]; //企业版
    
    return [arguments oex_stringByUsingFormEncoding];
}

// This methods is used to get user details when user access token is available 当用户访问令牌可用时，此方法用于获取用户详细信息
- (void)getUserDetailsWith:(OEXAccessToken*)edxToken completionHandler:(OEXURLRequestHandler)completionBlock {
    self.edxToken = edxToken;

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config
                                                          delegate:self
                                                     delegateQueue:nil];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [OEXConfig sharedConfig].apiHostURL, URL_GET_USER_INFO]]];
    NSString* authValue = [NSString stringWithFormat:@"%@ %@", edxToken.tokenType, edxToken.accessToken];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:OEXWrapURLCompletion(completionBlock)];
    [task resume];
}

// Returns authentication header for every authenticated webservice call - 返回认证头每个认证的WebService调用
+ (NSString*)authHeaderForApiAccess {
    OEXSession* session = [OEXSession sharedSession];
    if(session.token.accessToken && session.token.tokenType) {
        NSString* header = [NSString stringWithFormat:@"%@ %@", session.token.tokenType, session.token.accessToken];
        return header;
    }
    else {
        return @"";
    }
}

#pragma mark NSURLSession Delegate

- (void)            URLSession:(NSURLSession*)session
                          task:(NSURLSessionTask*)task
    willPerformHTTPRedirection:(NSHTTPURLResponse*)redirectResponse
                    newRequest:(NSURLRequest*)request
             completionHandler:(void (^)(NSURLRequest*))completionHandler {
    
    NSMutableURLRequest* mutablerequest = [request mutableCopy];
    NSString* authValue = [NSString stringWithFormat:@"%@ %@", self.edxToken.tokenType, self.edxToken.accessToken];
    [mutablerequest setValue:authValue forHTTPHeaderField:@"Authorization"];

    completionHandler([mutablerequest copy]);
}

#pragma mark - Social Login Methods

//登录成功
+ (void)handleSuccessfulLoginWithToken:(OEXAccessToken*)token completionHandler:(OEXURLRequestHandler)completionHandler {
    
    OEXAuthentication* auth = [[OEXAuthentication alloc] init];
    [auth getUserDetailsWith:token completionHandler:^(NSData* userdata, NSURLResponse* userresponse, NSError* usererror) {
        
        NSHTTPURLResponse* httpResp = (NSHTTPURLResponse*) userresponse;
        if(httpResp.statusCode == 200) {
            NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:userdata options:kNilOptions error:nil];
            OEXUserDetails* userDetails = [[OEXUserDetails alloc] initWithUserDictionary:dictionary];
            if(token != nil && userDetails != nil) {
                [[OEXSession sharedSession] saveAccessToken:token userDetails:userDetails];//保存登录信息
            }
            else {
                // On the off chance that something messed up and we have nil
                // for token or user details,
                // stub in some error values
                usererror = [NSError oex_unknownError];
                userresponse = [[NSHTTPURLResponse alloc] initWithURL:userresponse.URL statusCode:OEXHTTPStatusCode400BadRequest HTTPVersion:nil headerFields:nil];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
                OEXWrapURLCompletion(completionHandler)(userdata, userresponse, usererror);
            });
    }];
}

//注册用户
+ (void)registerUserWithParameters:(NSDictionary*)parameters completionHandler:(OEXURLRequestHandler)handler {
    
    //    默认配置使用的是持久化的硬盘缓存，存储证书到用户钥匙链。存储cookie到shareCookie。
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [OEXConfig sharedConfig].apiHostURL, SIGN_UP_URL]]];
    [request setHTTPMethod:@"POST"];

    NSString* postString = [parameters oex_stringByUsingFormEncoding]; //字典转字符串
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]]; //转成二进制
    
    //    session也会遵循NSURLRequest的限定，但是如果configuration有更加严格的限定，仍以configuration为主。
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    [[session dataTaskWithRequest:request completionHandler:OEXWrapURLCompletion(handler)] resume];
}

@end
