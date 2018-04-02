//
//  LoginModel.m
//  GitHubDemo
//
//  Created by zrq on 2018/4/2.
//  Copyright © 2018年 zrq. All rights reserved.
//

#import "LoginModel.h"

@implementation LoginModel
+ (NSArray *)getCompanyArray {
    return @[@{@"title":@"寿险",
               @"code":@"1"},
             @{@"title":@"财险",
               @"code":@"2"},
             @{@"title":@"养老",
               @"code":@"3"},
             @{@"title":@"寿险电销(电商)",
               @"code":@"4"},
             @{@"title":@"财险电销(电商)",
               @"code":@"5"}];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.comCode = @"1";
        self.comName = @"寿险";
        self.loginName = @"";
        self.password = @"";
    }
    return self;
}
@end
