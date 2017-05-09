//
//  TDRequestManager.m
//  edX
//
//  Created by Ben on 2017/5/8.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDRequestManager.h"
#import "TDBaseToolModel.h"

@interface TDRequestManager ()

@property (nonatomic,strong) TDBaseToolModel *baseTool;

@end

@implementation TDRequestManager

/*
 加入自己公司的课程
 */
- (void)addOwnCompanyCourse:(NSString *)course_id username:(NSString *)username companyID:(NSString *)company_id {
    
    self.baseTool = [[TDBaseToolModel alloc] init];
    if (![self.baseTool networkingState]) {
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:course_id forKey:@"course_id"];
    [dic setValue:username forKey:@"username"];
    [dic setValue:company_id forKey:@"company_id"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [NSString stringWithFormat:@"%@/api/mobile/enterprise/v0.5/companyjoincourses/",ELITEU_URL];
    [manager POST:url parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        int code = [responseDic[@"code"] intValue]; // 300 加入异常，400已经加过
        if (code == 200) {
            if (self.addOwnCompanyCourseHandle) {
                self.addOwnCompanyCourseHandle();
            }
        } else if (code == 400) {
            [[[UIApplication sharedApplication] keyWindow].rootViewController.view makeToast:@"课程已经加入" duration:1.08 position:CSToastPositionCenter];
        } else {
           [[[UIApplication sharedApplication] keyWindow].rootViewController.view makeToast:@"课程加入异常" duration:1.08 position:CSToastPositionCenter];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [[[UIApplication sharedApplication] keyWindow].rootViewController.view makeToast:NSLocalizedString(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        NSLog(@"error--%@",error);
    }];
    
}

@end
