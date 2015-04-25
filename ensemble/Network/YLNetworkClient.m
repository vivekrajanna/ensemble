//
//  YLNetworkClient.m
//  YMLKitTestApp
//
//  Created by Shashank Sharma on 29/12/14.
//  Copyright (c) 2014 YMediaLabs. All rights reserved.
//

#import "YLNetworkClient.h"
#import "Reachability.h"

static YLNetworkClient *sharedClient_;

@interface YLNetworkClient () <NSURLSessionDelegate>

@property (nonatomic, strong) Reachability *reachable;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionConfiguration *sessionConfig;

@end

@implementation YLNetworkClient

+(instancetype)sharedClient
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient_ = [[YLNetworkClient alloc] init];
    });
    
    return sharedClient_;
}

//Query components for GET HTTP method
+(NSArray *)queryComponentsForParams:(id)params forKey:(NSString *)key
{
    NSMutableArray *pairs = [NSMutableArray array];
    
    if ([params isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *dict = (NSDictionary *)params;
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES];
        
        for (NSString *subKey in [[params allKeys] sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            
            if (key) {
                [pairs addObjectsFromArray:[YLNetworkClient queryComponentsForParams:dict[subKey] forKey:[NSString stringWithFormat:@"%@[%@]", key, subKey]]];
            }
            else {
                [pairs addObjectsFromArray:[YLNetworkClient queryComponentsForParams:dict[subKey] forKey:subKey]];
            }
        }
    }
    if ([params isKindOfClass:[NSArray class]]) {
        
        NSArray *array = (NSArray *)params;
        for (id object in array) {
            
            [pairs addObjectsFromArray:[YLNetworkClient queryComponentsForParams:object forKey:[NSString stringWithFormat:@"%@[]", key]]];
        }
    }
    if ([params isKindOfClass:[NSSet class]]) {
        
        NSSet *set = (NSSet *)params;
        for (id object in set) {
            
            [pairs addObjectsFromArray:[YLNetworkClient queryComponentsForParams:object forKey:key]];
        }
    }
    if ([params isKindOfClass:[NSString class]]) {
        
        NSString *string = (NSString *)params;
        return [NSArray arrayWithObject:[NSURLQueryItem queryItemWithName:key value:string]];
    }
    
    return pairs;
}

//Serialized JSON for POST HTTP payload
+(NSString *)queryStringForJSONObject:(id)object
{
    NSString *queryString = nil;
    if ([object isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *dictionary = (NSDictionary *)object;
        NSMutableArray *subQueryStringArray = [NSMutableArray array];
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES];
        for (NSString *subKey in [[dictionary allKeys] sortedArrayUsingDescriptors:@[ descriptor ]]) {
            
            [subQueryStringArray addObject:[NSString stringWithFormat:@"\"%@\":%@",subKey,[YLNetworkClient queryStringForJSONObject:dictionary[subKey]]]];
        }
        queryString = [NSString stringWithFormat:@"{%@}",[subQueryStringArray componentsJoinedByString:@","]];
    }
    else if ([object isKindOfClass:[NSArray class]]) {
        
        NSArray *array = (NSArray *)object;
        NSMutableArray *subQueryStringArray = [NSMutableArray array];
        for (id subObject in array) {
            
            [subQueryStringArray addObject:[YLNetworkClient queryStringForJSONObject:subObject]];
        }
        queryString = [NSString stringWithFormat:@"[%@]",[subQueryStringArray componentsJoinedByString:@","]];
    }
    else if ([object isKindOfClass:[NSSet class]]) {
        
        NSSet *set = (NSSet *)object;
        NSMutableArray *subQueryStringArray = [NSMutableArray array];
        for (id subObject in set) {
            
            [subQueryStringArray addObject:[YLNetworkClient queryStringForJSONObject:subObject]];
        }
        queryString = [NSString stringWithFormat:@"[%@]",[subQueryStringArray componentsJoinedByString:@","]];
    }
    else if ([object isKindOfClass:[NSString class]]) {
        
        return [NSString stringWithFormat:@"\"%@\"",object];
    }
    
    return queryString;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self setupClient];
    }
    return self;
}

-(instancetype)initWithReadBaseUrl:(NSString *)readUrlString writeBaseUrl:(NSString *)writeUrlString
{
    self = [super init];
    if (self) {
        self.readBaseUrl = readUrlString;
        self.writeBaseUrl = writeUrlString;
        [self setupClient];
    }
    
    return self;
}

-(void)dealloc
{
    [self.session invalidateAndCancel];
}

-(void)setupClient
{
    self.reachable = [Reachability reachabilityWithHostName:@"www.apple.com"];
    self.readBaseUrl = self.readBaseUrl?self.readBaseUrl:@"";
    self.writeBaseUrl = self.writeBaseUrl?self.writeBaseUrl:@"";
    self.sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    [self.sessionConfig setHTTPAdditionalHeaders:@{@"Accept":@"application/json"}];
    self.session = [NSURLSession sessionWithConfiguration:self.sessionConfig delegate:self delegateQueue:nil];
}

-(BOOL)isReachable
{
    if ([self.reachable currentReachabilityStatus] != NotReachable) {
        return YES;
    }
    return NO;
}

-(NSString *)methodParameterForHTTPMethod:(HTTPMethod)method
{
    NSString *param = nil;
    
    switch (method) {
        case GET:
            param = @"GET";
            break;
        case POST:
            param = @"POST";
            break;
        case PUT:
            param = @"PUT";
            break;
        case HEAD:
            param = @"HEAD";
            break;
        case DELETE:
            param = @"DELETE";
            break;
            
        default:
            break;
    }
    
    return param;
}

-(NSString *)fullPathForRelativePath:(NSString *)path onServer:(NSInteger)server
{
    NSString *urlString = nil;
    if ([path hasPrefix:@"https://"] || [path hasPrefix:@"http://"]) {
        urlString = path;
    }
    else {
        switch (server) {
            case 0:
                urlString = [NSString stringWithFormat:@"%@%@",self.readBaseUrl,path];
                break;
            case 1:
                urlString = [NSString stringWithFormat:@"%@%@",self.writeBaseUrl,path];
                break;
                
            default:
                break;
        }
    }
    
    return urlString;
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        if([challenge.protectionSpace.host isEqualToString:@"dev05-dw.saloncentric.com"]){
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
        }
    }
}

-(void)executeRequest:(NSURLRequest *)request completionBLock:(YLNCCompletionHandler)completionHandler
{
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        if (httpResponse.statusCode == 200) {
            
            NSError *jsonError;
            id responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
            
            completionHandler(responseObject, jsonError);
        }
        else if (completionHandler) {
            completionHandler(response, error);
        }
    }];
    
    [task resume];
}

-(void)callReadRestAPIPath:(NSString *)path method:(HTTPMethod)method params:(NSDictionary *)params encoding:(YLNCParameterEncoding)encoding additionalHeaders:(NSDictionary *)headers completionBlock:(YLNCCompletionHandler)completionHandler
{
    NSURLRequest *request = [self createRequestWithPath:path onServer:0 method:method parameters:params encoding:encoding additionalHeaders:headers];
    [self executeRequest:request completionBLock:completionHandler];
}

-(void)callWriteRestAPIPath:(NSString *)path method:(HTTPMethod)method params:(NSDictionary *)params encoding:(YLNCParameterEncoding)encoding additionalHeaders:(NSDictionary *)headers completionBlock:(YLNCCompletionHandler)completionHandler
{
    NSURLRequest *request = [self createRequestWithPath:path onServer:1 method:method parameters:params encoding:encoding additionalHeaders:headers];
    [self executeRequest:request completionBLock:completionHandler];
}

-(NSURLRequest *)createRequestWithPath:(NSString *)path onServer:(NSInteger)server method:(HTTPMethod)method parameters:(NSDictionary *)parameters encoding:(YLNCParameterEncoding)encoding additionalHeaders:(NSDictionary *)headers
{
    
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:server==0?self.readBaseUrl:self.writeBaseUrl];
    urlComponents.path = path;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[urlComponents URL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPMethod:[self methodParameterForHTTPMethod:method]];
    [request setAllHTTPHeaderFields:headers];
    
    if (parameters) {
        
        switch (method) {
            case GET:
            case HEAD:
            case DELETE:
            {
                urlComponents.queryItems = [YLNetworkClient queryComponentsForParams:parameters forKey:nil];
                [request setURL:[urlComponents URL]];
                break;
            }
            case POST:
            case PUT:
            {
                NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
                NSError *error = nil;
                
                switch (encoding) {
                        
                    case YLNCParameterEncodingURL:
                    {
                        urlComponents.queryItems = [YLNetworkClient queryComponentsForParams:parameters forKey:nil];
                        [request setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
                        [request setHTTPBody:[[urlComponents percentEncodedQuery] dataUsingEncoding:NSUTF8StringEncoding]];
                        break;
                    }
                    case YLNCParameterEncodingJSON:
                    {
                        NSData *postData = [[YLNetworkClient queryStringForJSONObject:parameters] dataUsingEncoding:NSUTF8StringEncoding];
                        [request setHTTPBody:postData];
                        [request setValue:[NSString stringWithFormat:@"application/json; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
                        break;
                    }
                    case YLNCParameterEncodingPLIST:
                    {
                        NSData *postData = [NSPropertyListSerialization dataWithPropertyList:parameters format:NSPropertyListXMLFormat_v1_0 options:NSPropertyListWriteInvalidError error:&error];
                        [request setHTTPBody:postData];
                        [request setValue:[NSString stringWithFormat:@"application/x-plist; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
                        break;
                    }
                    default:
                        break;
                }
                
                if (error) {
                    return nil;
                }
            }
            break;
            default:
                break;
        }
    }
    
    return request;
}

#pragma mark - NSURLSessionDelegate

@end
