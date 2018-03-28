//
//  HttpManager.h
//  GitHubDemo
//
//  Created by zrq on 2018/3/28.
//  Copyright © 2018年 zrq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
typedef NS_ENUM(NSUInteger,HttpRequestType){
    HttpRequestTypeGet = 0,
    HttpRequestTypePost
} ;
typedef void(^HttpSuccess) (id json);
typedef void(^HttpFailure)(NSError *error);
@interface HttpManager : NSObject
/*
 get请求
 */

/*
post请求
*/
+ (void)postRequestWithUrl:(NSString *)url with:(NSDictionary *)messageDic success:(HttpSuccess)success failure:(HttpFailure)failure;
/*
 当前网络状态
 */
@property(assign,nonatomic)AFNetworkReachabilityStatus networkStatus;
/*
 网络管理类的单例
 */
+ (HttpManager *)shareManager;
@end
