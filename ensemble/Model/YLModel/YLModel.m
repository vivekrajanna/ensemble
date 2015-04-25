
//
//  YLModel.m
//  NextSpot
//
//  Created by Darshan Sonde on 16/05/13.
//  Copyright (c) 2013 ymedialabs. All rights reserved.
//

#import "YLModel.h"
#import "AFURLResponseSerialization.h"
#import "AFURLConnectionOperation.h"
#import "AFURLRequestSerialization.h"

NSString  *const YLModelErrorDomain = @"YLModelErrorDomain";


@interface NSNull(Integer)
-(NSInteger) integerValue;
@end

@implementation NSNull(Integer)
-(NSInteger)integerValue
{
    return 0;
}
@end

@interface YLModel ()
@end

@implementation YLModel

-(id) initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if(self) {
        AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
        self.requestSerializer = requestSerializer;
    }
    return self;
}

- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(YLSuccessBlock) success
        failure:(YLFailureBlock) failure
{
    if(self.reachabilityManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:@"Server is not reachable, please try after sometime." forKey:NSLocalizedDescriptionKey];
        if(failure)
            failure([NSError errorWithDomain:YLModelErrorDomain code:eErrorServerNetworkIssue userInfo:userInfo]);
        return;
    }
    
    [super GET:path
        parameters:parameters
           success:^(NSURLSessionDataTask *task, id responseObject) {
               success(responseObject);
           } failure:^(NSURLSessionDataTask *task, NSError *error) {
               if(failure)
                   failure(error);
           }];
}

- (void)deletePath:(NSString *)path
        parameters:(NSDictionary *)parameters
           success:(YLSuccessBlock) success
           failure:(YLFailureBlock) failure
{
    if(self.reachabilityManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:@"Server is not reachable, please try after sometime." forKey:NSLocalizedDescriptionKey];
        if(failure)
            failure([NSError errorWithDomain:YLModelErrorDomain code:eErrorServerNetworkIssue userInfo:userInfo]);
        return;
    }
    
    [super DELETE:path
           parameters:parameters
              success:^(NSURLSessionDataTask *task, id responseObject) {
                  success(responseObject);
              } failure:^(NSURLSessionDataTask *task, NSError *error) {
                  
                  if(failure)
                      failure(error);
              }];
}

- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(YLSuccessBlock) success
         failure:(YLFailureBlock) failure
{
    if(self.reachabilityManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:@"Server is not reachable, please try after sometime." forKey:NSLocalizedDescriptionKey];
        if(failure)
            failure([NSError errorWithDomain:YLModelErrorDomain code:eErrorServerNetworkIssue userInfo:userInfo]);
        return;
    }
    
    [super POST:path
         parameters:parameters
            success:^(NSURLSessionDataTask *task, id responseObject) {
                success(responseObject);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                
                if(failure)
                    failure(error);
            }];
}

@end
