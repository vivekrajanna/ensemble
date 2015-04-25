//
//  DataManager.h
//  Ouffy
//
//  Created by Darshan Sonde on 01/06/2014.
//  Copyright (c) 2014 Darshan Sonde. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef void (^YCDSuccessBlock)();
typedef void (^YCDFailureBlock)(NSError *error);

@interface YLCoreDataManager : NSObject

+ (YLCoreDataManager *) sharedInstance;
+ (YLCoreDataManager *) testInstance;

@property (nonatomic, strong, readonly) NSManagedObjectContext *mainContext;
@property (nonatomic, strong, readonly) NSManagedObjectContext *backgroundMasterContext;


-(NSManagedObjectContext*) createWriteContext;

-(void) removeAllCachedData;///< deletes the sql file. use carefully
- (void) saveAllWithContext:(NSManagedObjectContext*) writeContext
                    success:(YCDSuccessBlock)success
                    failure:(YCDFailureBlock)failure;

@end