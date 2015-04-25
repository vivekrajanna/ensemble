//
//  YLNetworkClient.h
//  YMLKitTestApp
//
//  Created by Shashank Sharma on 29/12/14.
//  Copyright (c) 2014 YMediaLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

#define YLNetworkClientErrorDomain @"YLNetworkClientErrorDomain"

typedef void(^YLNCCompletionHandler)(id responseObject, NSError *error);

typedef enum {
    GET,
    POST,
    PUT,
    HEAD,
    DELETE
} HTTPMethod;

typedef enum {
    YLNCParameterEncodingURL,
    YLNCParameterEncodingJSON,
    YLNCParameterEncodingPLIST
}YLNCParameterEncoding;

@interface YLNetworkClient : NSObject

+(instancetype) sharedClient;

@property (nonatomic, strong) NSString *readBaseUrl;
@property (nonatomic, strong) NSString *writeBaseUrl;

/**
 * Initialize with base urls.
 * (Shared client can be also assigned these values if same values are used throughout app.)
 *
 * @param urlStrings Base url strings for read, write and other APIs.
 * @return The oldest data point, if any.
 */
-(instancetype)initWithReadBaseUrl:(NSString *)readUrlString writeBaseUrl:(NSString *)writeUrlString;

-(void)callReadRestAPIPath:(NSString *)path method:(HTTPMethod)method params:(NSDictionary *)params encoding:(YLNCParameterEncoding)encoding additionalHeaders:(NSDictionary *)headers completionBlock:(YLNCCompletionHandler)completionHandler;
-(void)callWriteRestAPIPath:(NSString *)path method:(HTTPMethod)method params:(NSDictionary *)params encoding:(YLNCParameterEncoding)encoding additionalHeaders:(NSDictionary *)headers completionBlock:(YLNCCompletionHandler)completionHandler;

@end
