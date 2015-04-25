//
//  ViewController.m
//  ensemble
//
//  Created by vivek on 4/23/15.
//  Copyright (c) 2015 YMEdiaLabs. All rights reserved.
//

#import "ViewController.h"
#import "YLNetworkClient.h"
#import  "Reachability.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    [[YLNetworkClient sharedClient] setReadBaseUrl:@"https://api.sphere.io"];
//    [[YLNetworkClient sharedClient] setWriteBaseUrl:@"https://api.sphere.io/hack-70"];
//    
//    ;
//    
//    [[YLNetworkClient sharedClient] callReadRestAPIPath:@"/hack-70/product-types" method:GET params:nil encoding:YLNCParameterEncodingJSON additionalHeaders:[NSDictionary dictionaryWithObject:@"Bearer LBQXgUQ2vZZwJo1CTX4pPMMcjv9lQd1n" forKey:@"Authorization"] completionBlock:^(id responseObject, NSError *error) {
//        
//        
//        
//    }];\

   NetworkStatus status = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    
    [[YLNetworkClient sharedClient] setReadBaseUrl:@"https://dev05-dw.saloncentric.com"];
    [[YLNetworkClient sharedClient] setWriteBaseUrl:@"https://dev05-dw.saloncentric.com"];
    
    ;
    

   NSDictionary *parms = [NSDictionary dictionaryWithObjects:@[@"l.pond@astoundcommerce.com",@"Loreal123"] forKeys:@[@"username",@"password"]];
    
    [[YLNetworkClient sharedClient] callWriteRestAPIPath:@"/dw/shop/v15_2/account/login?client_id=97727e8e-edd3-460b-ae73-77b969b1f3dc" method:POST params:parms encoding:YLNCParameterEncodingJSON additionalHeaders:nil completionBlock:^(id responseObject, NSError *error) {
       
    }];
    
    
 
    
    
    //var clientId='97727e8e-edd3-460b-ae73-77b969b1f3dc'; // "OCAPI Test" client
    
 
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
