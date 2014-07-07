//
//  ChouChouManagedObject.h
//  ChouChouKit
//
//  Created by R Manju Kiran on 14/05/14.
//  Copyright (c) 2014 ibibo Web Pvt. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChouChouError.h"

@interface NSDictionary (ChouChouManagedObject)

-(NSString*)lastUpdatedTimeStampChouChou;
@end


/**
 Dictionary Params:
 id     : ID of remote mongo DB object
 _id    : ID of local database object
 **/
@interface ChouChouManagedObject : NSObject

@property (nonatomic, strong) NSMutableDictionary *contentData;
@property (nonatomic, copy)   NSString *docName;

@property (nonatomic, copy) NSString *uniqueID;
@property (nonatomic, copy) NSString *uniqueIDKey;

/**
 Converts dictionary to mutable and all its children array/dictionary to mutable and set it to @b contentData property. Modify this property and call sync to sync it with server/localdatabase.
 
 @also Also See : ChouchouOfflineDataManager : for Offline Storage
 **/
-(id) initWithDictionary :(NSDictionary*) dictionary;

/**
 Sync @b contentData property with remote server & local database. It performs fetch remote data followed by merging with local data followed by put request. If remote data is not available or offline storage is not being used, it performs a post request.
 **/

-(void)syncMe:(BOOL)storeLocally onError:(void (^)(ChouChouError*))onError onSuccess:(void (^)())onSuccess;

-(NSDateFormatter*)syncDateFormatter;
-(NSDate*)lastUpdatedDate;

//Methods which could be overridden for your own sync logics
-(NSDictionary*) getLatestContentMergedDictWithRemoteDict:(NSDictionary*)remDict;

/* Keys used to fetch an object uniquely. Overriding is highly recommended for usage specific behaviour */
-(NSDictionary*)syncUniqueKeysDictionary;


//Fetch Resources


-(void) getAllObjectsForProperties:(NSDictionary*) propertiesDict
                      storeLocally:(BOOL)storeLocally
                           onError:(void(^)(ChouChouError*))onError
                       offlineData: (void(^)(NSDictionary*))offlineData
                         onSuccess:(void(^)(NSArray*))onSuccess;

-(void) getResourcewithSyncDict:(NSDictionary*)syncDict
                  storeLocally:(BOOL)storeLocally
                       onError:(void (^)(ChouChouError*))onError
                   dataOffline:(void (^)(id))dataOffline
                    dataOnline:(void (^)(id))dataOnline;

-(void) submitResourceWithSyncDict:(NSDictionary*)syncDict
                      storeLocally:(BOOL)storeLocally
                           onError:(void (^)(ChouChouError *))onError
                         onSuccess:(void (^)(id))onSuccess;


-(void)deleteResourceByID:(NSDictionary*)propertiesDic
                  onError:(void (^)(ChouChouError*))onError
                onSuccess:(void (^)(BOOL))onSuccess;


-(void)locallyUpdateResourcewithSyncDict:(NSDictionary*)syncDict
                            storeLocally:(BOOL)storeLocally
                                 onError:(void (^)(ChouChouError *))onError
                               onSuccess:(void (^)(id))onSuccess;


+(void) clearAllObjectsOfMyResourceType :(ChouChouManagedObject*)object;

@end
