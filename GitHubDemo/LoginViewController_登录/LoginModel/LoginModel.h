//
//  LoginModel.h
//  GitHubDemo
//
//  Created by zrq on 2018/4/2.
//  Copyright © 2018年 zrq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginModel : NSObject
///登录数据模型
+ (NSArray *)getCompanyArray;
///单位名称
@property (copy, nonatomic) NSString *comName;
///单位代码
@property (copy, nonatomic) NSString *comCode;
///登录名称
@property (copy, nonatomic) NSString *loginName;
///登录密码
@property (copy, nonatomic) NSString *password;
@end
