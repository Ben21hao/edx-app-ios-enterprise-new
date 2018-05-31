//
//  PurchaseManager.m
//  edX
//
//  Created by Elite Edu on 16/11/22.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "PurchaseManager.h"
#import <AFNetworking.h>

//在内购项目中创的商品单号
#define ProductID_IAP0p100 @"mobile.enrerprise.eliteu.cn01"//100
#define ProductID_IAP1p200 @"mobile.enrerprise.eliteu.cn02" //200
#define ProductID_IAP4p300 @"mobile.enrerprise.eliteu.cn03" //300
#define ProductID_IAP9p500 @"mobile.enrerprise.eliteu.cn04" //500
#define ProductID_IAP24p800 @"mobile.enrerprise.eliteu.cn05" //800
#define ProductID_IAP28p1000 @"mobile.enrerprise.eliteu.cn06" //1000

@implementation PurchaseManager

- (instancetype)init {
    if (self = [super init]) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        _purchaseModel = [[PurchaseModel alloc] init];
    }
    return self;
}

- (void)verificationAction:(NSInteger)type{ // 1 充值，2 购买课程或待支付
    
    NSMutableDictionary *dic = [self.purchaseModel autoParameteDictionary:type];
    
    NSMutableDictionary *newDic = [[NSMutableDictionary alloc] init];
    
    NSString *file = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSMutableDictionary *fileDic = [[NSMutableDictionary alloc] initWithContentsOfFile:file];
    NSString *version = [fileDic objectForKey:@"CFBundleShortVersionString"];
    [newDic setValue:version forKey:@"version"];//版本号
    [newDic setValue:[[UIDevice currentDevice] systemVersion] forKey:@"os_version"];//系统版本
    [dic addEntriesFromDictionary:newDic];//向字典中添加字典对象
    
    NSString *path = type == 1 ? @"/api/mobile/v0.5/finance/apple_pay_receipt_verify/" : @"/api/courses/v1/apple_pay_receipt_verify/";
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",ELITEU_URL,path];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager shareManager];
    [manager POST:urlStr parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //状态返回200为成功
        NSDictionary *responDic = (NSDictionary *)responseObject;
        
        if ([responDic[@"code"] intValue] != 200) {
            if (self.vertificationHandle) {
                self.vertificationHandle(nil,@"请求失败");
                NSLog(@"-----验证失败---------");
            }
        } else {
            if (self.vertificationHandle) {
                self.vertificationHandle(responDic,TDLocalizeSelect(@"RECHARGE_SUCCESS", nil));
                NSLog(@"-----验证成功---------");
            }
        }
        
        NSLog(@"%@",responDic[@"msg"]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (self.vertificationHandle) {
            self.vertificationHandle(nil,@"请求失败");
            NSLog(@"-----请求失败---------");
        }
    }];
}

- (BOOL)isNewWorkFail {
    return ![[AFNetworkReachabilityManager sharedManager] isReachable];
}

- (void)reqToUpMoneyFromApple:(int)type {
    [self buy:type];
}

-(void)buy:(int)type
{
    buyType = type;
    if ([SKPaymentQueue canMakePayments]) {
        [self RequestProductData];
        NSLog(@"允许程序内付费购买");
    } else {
        NSLog(@"不允许程序内付费购买");
        UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:TDLocalizeSelect(@"SYSTEM_WARING", nil)
                                                            message:@"您的手机没有打开程序内付费购买"
                                                           delegate:nil cancelButtonTitle:TDLocalizeSelect(@"关闭",nil) otherButtonTitles:nil];
        
        [alerView show];
        
    }
}

-(void)RequestProductData
{
    NSLog(@"---------请求对应的产品信息------------");
    
    NSArray *product = nil;
    switch (buyType) {
        case IAP0p100:
            product=[[NSArray alloc] initWithObjects:ProductID_IAP0p100,nil];
            break;
        case IAP1p200:
            product=[[NSArray alloc] initWithObjects:ProductID_IAP1p200,nil];
            break;
        case IAP4p300:
            product=[[NSArray alloc] initWithObjects:ProductID_IAP4p300,nil];
            break;
        case IAP9p500:
            product=[[NSArray alloc] initWithObjects:ProductID_IAP9p500,nil];
            break;
        case IAP24p800:
            product=[[NSArray alloc] initWithObjects:ProductID_IAP24p800,nil];
            break;
        case IAP28p1000:
            product=[[NSArray alloc] initWithObjects:ProductID_IAP28p1000,nil];
            break;
        default:
            break;
    }
    NSSet *nsset = [NSSet setWithArray:product];
    SKProductsRequest *request=[[SKProductsRequest alloc] initWithProductIdentifiers: nsset];
    request.delegate=self;
    [request start];
    
}

//<SKProductsRequestDelegate> 请求协议
//收到的产品信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    
    NSLog(@"-----------收到产品反馈信息--------------");
    NSArray *myProduct = response.products;
    NSLog(@"产品Product ID:%@",response.invalidProductIdentifiers);
    NSLog(@"产品付费数量: %d", (int)[myProduct count]);
    // populate UI
    
    NSString *identifier;
    switch (buyType) {
        case IAP0p100:
            identifier= ProductID_IAP0p100;    //支付100
            break;
        case IAP1p200:
            identifier= ProductID_IAP1p200;    //支付200
            break;
        case IAP4p300:
            identifier=ProductID_IAP4p300;    //支付300
            break;
        case IAP9p500:
            identifier=ProductID_IAP9p500;    //支付500
            break;
        case IAP24p800:
            identifier=ProductID_IAP24p800;    //支付800
            break;
        case IAP28p1000:
            identifier=ProductID_IAP28p1000;    //支付1000
            break;
        default:
            break;
    }
    SKProduct *pro = nil;
    for(SKProduct *product in myProduct){
        NSLog(@"product info");
        NSLog(@"SKProduct 描述信息%@", [product description]);
        NSLog(@"产品标题 %@" , product.localizedTitle);
        NSLog(@"产品描述信息: %@" , product.localizedDescription);
        NSLog(@"价格: %@" , product.price);
        NSLog(@"Product id: %@" , product.productIdentifier);
        
        if ([product.productIdentifier isEqualToString:identifier]) {
            pro = product;
        }
    }
    if (pro == nil) {
        NSLog(@"------ 空 -------");
        return;
    }
    SKPayment *payment = [SKPayment paymentWithProduct:pro];
    NSLog(@"---------发送购买请求------------");
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}
- (void)requestProUpgradeProductData
{
    NSLog(@"------请求升级数据---------");
    NSSet *productIdentifiers = [NSSet setWithObject:@"com.productid"];
    SKProductsRequest* productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
    
}
//弹出错误信息
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"-------弹出错误信息----------");
    UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:TDLocalizeSelect(@"SYSTEM_WARING", nil) message:@"网络错误，请稍后再试"
                                                       delegate:nil cancelButtonTitle:TDLocalizeSelect(@"OK", nil) otherButtonTitles:nil];
    [alerView show];
    
}

-(void) requestDidFinish:(SKRequest *)request
{
    NSLog(@"----------反馈信息结束--------------");
    
}

-(void) PurchasedTransaction: (SKPaymentTransaction *)transaction{
    NSLog(@"-----PurchasedTransaction----");
    NSArray *transactions =[[NSArray alloc] initWithObjects:transaction, nil];
    [self paymentQueue:[SKPaymentQueue defaultQueue] updatedTransactions:transactions];
}

//<SKPaymentTransactionObserver> 千万不要忘记绑定，代码如下：
//----监听购买结果
//[[SKPaymentQueue defaultQueue] addTransactionObserver:self];

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {//交易结果
    NSLog(@"-----paymentQueue--------");
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:{//交易完成
                
                NSURL *receiveUrl = [[NSBundle mainBundle] appStoreReceiptURL];
                NSData *receiveData = [NSData dataWithContentsOfURL:receiveUrl];
                NSString *receiveStr = [receiveData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
//                NSString *payStr = [NSString stringWithFormat:@"@{\"receipt-data\" : \"%@\"}",receiveStr];
//                NSData *payLoadData = [payStr dataUsingEncoding:NSUTF8StringEncoding];
//                NSString *appleReive = [payLoadData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
                if (self.rqToUpStateHandle) {
                    self.rqToUpStateHandle(SKPaymentTransactionStatePurchased,receiveStr);
                }
                
                [self completeTransaction:transaction];
                NSLog(@"-----交易完成 --------");
                
            } break;
            case SKPaymentTransactionStateFailed: {//交易失败
                [self failedTransaction:transaction];
                NSLog(@"-----交易失败 --------");
                if (self.rqToUpStateHandle) {
                    self.rqToUpStateHandle(SKPaymentTransactionStateFailed,@"购买失败，请重新尝试购买");
                }
                
            }
                break;
            case SKPaymentTransactionStateRestored://已经购买过该商品
                [self restoreTransaction:transaction];
                NSLog(@"-----已经购买过该商品 --------");
                
            case SKPaymentTransactionStatePurchasing:      //商品添加进列表
                NSLog(@"-----商品添加进列表 --------");
                
                break;
            default:
                break;
        }
    }
}

#define SANDBOX @"https://sandbox.itunes.apple.com/verifyReceipt"
//正式环境验证
#define AppStore @"https://buy.itunes.apple.com/verifyReceipt"
/**
 *  验证购买，避免越狱软件模拟苹果请求达到非法购买问题
 *
 */
//-(void)verifyPurchaseWithPaymentTransaction{
//    //从沙盒中获取交易凭证并且拼接成请求体数据
//    NSURL *receiptUrl=[[NSBundle mainBundle] appStoreReceiptURL];
//    NSData *receiptData=[NSData dataWithContentsOfURL:receiptUrl];
//    
//    NSString *receiptString=[receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];//转化为base64字符串
//    
//    NSString *bodyString = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\"}", receiptString];//拼接请求数据
//    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
//    
//    
//    //创建请求到苹果官方进行购买验证
//    NSURL *url=[NSURL URLWithString:SANDBOX];
//    NSMutableURLRequest *requestM=[NSMutableURLRequest requestWithURL:url];
//    requestM.HTTPBody=bodyData;
//    requestM.HTTPMethod=@"POST";
//    //创建连接并发送同步请求
//    NSError *error=nil;
//    NSData *responseData=[NSURLConnection sendSynchronousRequest:requestM returningResponse:nil error:&error];
//    if (error) {
//        NSLog(@"验证购买过程中发生错误，错误信息：%@",error.localizedDescription);
//        return;
//    }
//    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
//    NSLog(@"%@",dic);
//    
//    if([dic[@"status"] intValue]==0){
//        NSLog(@"购买成功！");
//        NSDictionary *dicReceipt= dic[@"receipt"];
//        NSDictionary *dicInApp=[dicReceipt[@"in_app"] firstObject];
//        NSString *productIdentifier= dicInApp[@"product_id"];//读取产品标识
//        //如果是消耗品则记录购买数量，非消耗品则记录是否购买过
//        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
//        if ([productIdentifier isEqualToString:@"123"]) {
//            NSInteger purchasedCount=[defaults integerForKey:productIdentifier];//已购买数量
//            [defaults setInteger:(purchasedCount+1) forKey:productIdentifier];
//        }else{
//            [defaults setBool:YES forKey:productIdentifier];
//        }
//        [SVProgressHUD showSuccessWithStatus:@"购买成功 ++++ "];
//        //在此处对购买记录进行存储，可以存储到开发商的服务器端
//
//    }else{
//        [[UIApplication sharedApplication].keyWindow.rootViewController.view makeToast:@"购买失败，未通过验证！" duration:1.08 position:CSToastPositionCenter];
//        NSLog(@"购买失败，未通过验证！");
//    }
//}

//监听购买结果
//- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transaction{
//    
//    
//    for(SKPaymentTransaction *tran in transaction){
//        
//        switch (tran.transactionState) {
//            case SKPaymentTransactionStatePurchased:{
//                NSLog(@"交易完成");
//                [self verifyPurchaseWithPaymentTransaction];
//                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
//                
//            }
//                break;
//            case SKPaymentTransactionStatePurchasing:
//                NSLog(@"商品添加进列表");
//                
//                break;
//            case SKPaymentTransactionStateRestored:{
//                NSLog(@"已经购买过商品");
//                
//                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
//            }
//                break;
//            case SKPaymentTransactionStateFailed:{
//                NSLog(@"交易失败");
//                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
//                [SVProgressHUD showErrorWithStatus:@"购买失败"];
//            }
//                break;
//            default:
//                break;
//        }
//    }
//}

-(void) paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentTransaction *)transaction{
    
}

-(void) paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    NSLog(@"-------paymentQueue----");
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction

{
    NSLog(@"-----completeTransaction--------");
    // Your application should implement these two methods.
    NSString *product = transaction.payment.productIdentifier;
    if ([product length] > 0) {
        
        NSArray *tt = [product componentsSeparatedByString:@"."];
        NSString *bookid = [tt lastObject];
        if ([bookid length] > 0) {
            [self recordTransaction:bookid];
            [self provideContent:bookid];
        }
    }
    
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

//记录交易
-(void)recordTransaction:(NSString *)product{
    NSLog(@"-----记录交易--------");
}

//处理下载内容
-(void)provideContent:(NSString *)product{
    NSLog(@"-----下载--------");
}
//处理失败
- (void) failedTransaction: (SKPaymentTransaction *)transaction{
    NSLog(@"失败");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@" 交易恢复处理");
    
}
-(void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];//解除监听
    
}

@end
