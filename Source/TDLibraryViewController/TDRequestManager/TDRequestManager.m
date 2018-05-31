//
//  TDRequestManager.m
//  edX
//
//  Created by Ben on 2017/5/8.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDRequestManager.h"
#import "TDBaseToolModel.h"
#import "OEXAuthentication.h"

#import <MJExtension/MJExtension.h>

@interface TDRequestManager ()

@property (nonatomic,strong) TDBaseToolModel *baseTool;

@end

@implementation TDRequestManager


#pragma mark -  加入自己公司的课程
- (void)addOwnCompanyCourse:(NSString *)course_id username:(NSString *)username companyID:(NSString *)company_id {
    
    self.baseTool = [[TDBaseToolModel alloc] init];
    if (![self.baseTool networkingState]) {
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:course_id forKey:@"course_id"];
    [dic setValue:username forKey:@"username"];
    [dic setValue:company_id forKey:@"company_id"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager shareManager];
    NSString *url = [NSString stringWithFormat:@"%@/api/mobile/enterprise/v0.5/companyjoincourses/",ELITEU_URL];
    [manager POST:url parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        int code = [responseDic[@"code"] intValue]; // 300 加入异常，400 课程已经加入
        if (code == 200 || code == 400) {
            
        } else if (code == 301) { //加入失败，名额不足，无法享受企业免费报课
            [[[UIApplication sharedApplication] keyWindow].rootViewController.view makeToast:TDLocalizeSelect(@"ADD_FAILED_TEXT", nil) duration:1.08 position:CSToastPositionCenter];
        } else {
           [[[UIApplication sharedApplication] keyWindow].rootViewController.view makeToast:TDLocalizeSelect(@"ADD_FAILED_TEXT", nil) duration:1.08 position:CSToastPositionCenter];
        }
        if (self.addOwnCompanyCourseHandle) {
            self.addOwnCompanyCourseHandle(code);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (self.addOwnCompanyCourseHandle) {
            self.addOwnCompanyCourseHandle(1001);
        }
        [[[UIApplication sharedApplication] keyWindow].rootViewController.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        NSLog(@"error--%@",error);
    }];
}

#pragma mark - 获取用户详细信息
- (void)getUserDetailMessage:(NSString *)username {
    
    self.baseTool = [[TDBaseToolModel alloc] init];
    if (![self.baseTool networkingState]) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/user/v1/accounts/%@",ELITEU_URL,username];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager shareManager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer]; // 返回的格式 JSON
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];// 可接受的文本参数规格
    manager.requestSerializer = [AFJSONRequestSerializer serializer]; //先讲请求设置为json
    [manager.requestSerializer setValue:@"application/merge-patch+json" forHTTPHeaderField:@"Content-Type"];// 开始设置请求头
    
    NSString* authValue = [NSString stringWithFormat:@"%@", [OEXAuthentication authHeaderForApiAccess]];
    [manager.requestSerializer setValue:authValue forHTTPHeaderField:@"Authorization"];//安全验证
    
    [manager PATCH:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *languageStr = [NSString stringWithFormat:@"%@",responseObject[@"language"]];
        if (self.getUserMessageHandle) {
            self.getUserMessageHandle(languageStr);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
//        [[[UIApplication sharedApplication] keyWindow].rootViewController.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        NSLog(@"获取个人信息出错 -- %ld, %@",(long)error.code, error.userInfo[@"com.alamofire.serialization.response.error.data"]);
    }];
}


@end


