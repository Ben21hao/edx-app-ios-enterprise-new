//
//  PurchaseManager.h
//  edX
//
//  Created by Elite Edu on 16/11/22.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "PurchaseModel.h"

//enum{
//    IAP0p100 = 1,
//    IAP1p200,
//    IAP4p300,
//    IAP9p500,
//    IAP24p800,
//    IAP28p1000,
//}buyCoinsTag;

typedef NS_ENUM(NSInteger,IAP) {
    IAP0p100 = 1,
    IAP1p200,
    IAP4p300,
    IAP9p500,
    IAP24p800,
    IAP28p1000
};

@interface PurchaseManager : NSObject<SKPaymentTransactionObserver,SKProductsRequestDelegate >
{
    int buyType;
}

@property (nonatomic,strong) PurchaseModel *purchaseModel;//数据模型
@property (nonatomic,copy) void(^rqToUpStateHandle)(int state,NSString *receiveStr);
@property (nonatomic,copy) void(^vertificationHandle)(id dataObject,NSString *tips);


- (void)reqToUpMoneyFromApple:(int)type;

- (void)verificationAction:(NSInteger)type;


///////////
- (void) requestProUpgradeProductData;

-(void)RequestProductData;

-(void)buy:(int)type;

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;

-(void) PurchasedTransaction: (SKPaymentTransaction *)transaction;

-(void) paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentTransaction *)transaction;
@end
