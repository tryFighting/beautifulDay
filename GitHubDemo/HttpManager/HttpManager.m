//
//  HttpManager.m
//  GitHubDemo
//
//  Created by zrq on 2018/3/28.
//  Copyright © 2018年 zrq. All rights reserved.
//

#import "HttpManager.h"
#import "CommonTool.h"
#import "SecurityUtil.h"
#import <MJExtension/MJExtension.h>
static HttpManager * manager = nil;
static AFHTTPSessionManager * requestManager = nil;
const static CGFloat kTimeoutInterval = 90.f;
@implementation HttpManager
///post请求
+ (void)postRequestWithUrl:(NSString *)url with:(NSDictionary *)messageDic success:(HttpSuccess)success failure:(HttpFailure)failure{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = kTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSUserDefaults *userdefault=[NSUserDefaults standardUserDefaults];
    //渠道号
    NSString *channel;
    if (messageDic[@"channel"]) {
        channel = messageDic[@"channel"];
    }else{
        channel =[userdefault objectForKey:@"channel"];
        channel=channel?channel:@"";
    }
    //工号
    NSString *pcard;
    if (messageDic[@"pcard"]) {
        pcard = messageDic[@"pcard"];
    }else{
        pcard =[userdefault objectForKey:@"username"];
        pcard=pcard?pcard:@"";
    }
    
    
    //设备号
    NSString *uuid=[CommonTool uuid];
    uuid=uuid?uuid:@"";
    
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]initWithDictionary:messageDic];
    //设备类型
    [dic setObject:[CommonTool getPhoneModel] forKey:@"deviceType"];
    //设备系统
    [dic setObject:[CommonTool getSystemVersion] forKey:@"deviceSystem"];
    //当前应用版本
    [dic setObject:[CommonTool getAppVersion] forKey:@"appVer"];
    [dic setObject:uuid forKey:@"uuid"];
    [dic setObject:channel forKey:@"channel"];
    [dic setObject:pcard forKey:@"pcard"];
    
    NSString *dicjsonstr=[dic mj_JSONString];
    NSLog(@"发送报文:%@",dicjsonstr);
    //字典转json
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //对字符串Base64加密
    NSString *baseStr = [SecurityUtil encodeBase64String:jsonStr];
    NSDictionary *para=@{@"param":baseStr};
    
    [manager POST:url parameters:para progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
    
    
}

///创建网络请求单例
+ (HttpManager *)shareManager{
    if (!manager) {
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            manager = [[HttpManager alloc] init];
            requestManager = [AFHTTPSessionManager manager];
        });
        
    }
    return manager;
}
@end
