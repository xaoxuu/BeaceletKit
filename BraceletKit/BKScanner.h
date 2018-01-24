//
//  BKScanner.h
//  BraceletKit
//
//  Created by xaoxuu on 23/01/2018.
//  Copyright © 2018 xaoxuu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BKDevice, CBCentralManager;
@protocol BKScanDelegate <NSObject>

@optional

/**
 发现设备
 
 @param device 设备
 */
- (void)scannerDidDiscoverDevice:(BKDevice *)device;

- (void)scannerForCentralManagerDidUpdateState:(CBCentralManager *)central;

- (void)scannerForCentralManagerDidDiscoverDevice:(BKDevice *)device;

@end


@interface BKScanner : NSObject


/**
 代理
 */
@property (weak, nonatomic) NSObject<BKScanDelegate> *delegate;

- (instancetype)initWithDelegate:(NSObject<BKScanDelegate> *)delegate;

/**
 扫描设备
 */
- (void)scanDevice;

/**
 停止扫描
 */
- (void)stopScan;


@end