//
//  DataManager.m
//  Ouffy
//
//  Created by Darshan Sonde on 01/06/2014.
//  Copyright (c) 2014 Darshan Sonde. All rights reserved.

#import "YLCoreDataManager.h"

/* Architecture

 BackgroundMasterContext
 ^
 | parent
 ReadContext
 ^
 | parent
 writeContext
 */
#define DMLog(...)

@interface YLCoreDataManager ()

- (void)initDataManager;

- (NSURL *)applicationDocumentsDirectory;

@property (nonatomic, strong,readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong,readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end


@implementation YLCoreDataManager
@synthesize mainContext = _mainContext;
@synthesize backgroundMasterContext = _backgroundMasterContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (YLCoreDataManager *) sharedInstance
{
	static id sharedDataManager = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedDataManager = [[[self class] alloc] init];
        [sharedDataManager initDataManager];
    });
    return sharedDataManager;
}

+(YLCoreDataManager *) testInstance
{
	static id sharedDataManager = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedDataManager = [[[self class] alloc] init];
        [sharedDataManager initForTesting];
    });
    return sharedDataManager;
}

- (id)init
{
    if (self = [super init]) {
    }
    return self;
}

- (void)initDataManager
{
}

-(void) dealloc
{
}

-(void) initForTesting
{
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    [_persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:nil];
}

#pragma mark - Core Data stack

-(NSManagedObjectContext*) backgroundMasterContext
{
    if(!_backgroundMasterContext) {
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if(coordinator) {
            _backgroundMasterContext =  [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            [_backgroundMasterContext setPersistentStoreCoordinator:coordinator];
        }
    }
    return _backgroundMasterContext;
}

-(NSManagedObjectContext*) mainContext
{
    if (!_mainContext) {
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if (coordinator) {
            _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            [_mainContext setParentContext:self.backgroundMasterContext];
        }
    }
    return _mainContext;
}

-(NSManagedObjectContext*) createWriteContext
{
    NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [newContext setParentContext:self.mainContext];
    return newContext;
}

- (NSManagedObjectModel *) managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];

    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        DMLog(@"Unresolved error forcing creation of file %@, %@", error, [error userInfo]);

        if(error) {
            DMLog(@"Error removeAllCacheData %@ %@",error,[error userInfo]);
            abort();
        }
    }
    return _persistentStoreCoordinator;
}

-(void) removeAllCachedData
{
    NSError *error=nil;
    _mainContext=nil;
    _backgroundMasterContext=nil;
    _managedObjectModel=nil;
    
    [_persistentStoreCoordinator removePersistentStore:[_persistentStoreCoordinator.persistentStores objectAtIndex:0] error:&error];
    if(error) {
        DMLog(@"Error removeAllCacheData %@ %@",error,[error userInfo]);
        abort();
    }
    error = nil;
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"OuffyModel.sqlite"];
    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
    if(error) {
        DMLog(@"Error removeAllCacheData %@ %@",error,[error userInfo]);
        abort();
    }
    error = nil;
    [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    if(error) {
        DMLog(@"Error removeAllCacheData %@, %@", error, [error userInfo]);
        abort();
    }
    _persistentStoreCoordinator=nil;
}

#pragma mark - File Manager

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - instance methods

- (void) saveAllWithContext:(NSManagedObjectContext*) writeContext
                    success:(YCDSuccessBlock)success
                    failure:(YCDFailureBlock)failure
{
    BOOL b = NO;
    NSError *error = nil;
    if([writeContext hasChanges]) {
        b=[writeContext save:&error];

        if(b) {
            NSManagedObjectContext *parentContext = [writeContext parentContext];
            if(parentContext) {
                [parentContext performBlock:^{
                    [self saveAllWithContext:parentContext success:success failure:failure];
                }];
            } else {
                if(success)
                    success();
            }
        } else {
            if(failure)
                failure(error);
        }
    }
    else {
        if(success)
            success();
    }
}


@end








