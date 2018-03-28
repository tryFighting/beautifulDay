//
//  CommonTool.h
//  GitHubDemo
//
//  Created by zrq on 2018/3/28.
//  Copyright © 2018年 zrq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonTool : NSObject
///uuid
+(NSString *)uuid;
///手机系统版本
+ (NSString *)getSystemVersion;
///获取手机类型
+ (NSString *)getPhoneModel;
///获取版本号
+ (NSString *)getAppVersion;
///获取运营商
+ (NSString *)getCarrierName;
@end
