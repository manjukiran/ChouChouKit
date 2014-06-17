//
//  ChouChouKit.m
//  ChouChouNative
//
//  Created by R Manju Kiran on 06/05/14.
//  Copyright (c) 2014 ibibo group. All rights reserved.
//

#import "ChouChouKit.h"
#import "ChouChouKitPrivate.h"
#import "ChouChouLogger.h"
#import "ChouChou+NSDictionary.h"
#import "ChouChouUrlConnection.h"
#import "ChouChouCBLiteManager.h"
#import "ChouChouSQLiteManager.h"
#import "Reachability.h"

static ChouChouKit *_chouInstance = nil;

#define kChouChouReachabilityIssueDomain @"ReachabilityIssue"
#define kChouChouExceptionIssueDomain @"TryCatchIssue"

@interface ChouChouKit ()
{
    
}

@property (nonatomic, copy) NSString *idMobile;
@property (nonatomic, copy) NSString *idDevice;
@property (nonatomic, copy) NSString *idEmail;

@property (nonatomic, strong) NSString *serverUrl;
@property (nonatomic, strong) NSString *idKey;
@property (nonatomic, strong) NSString *idApp;
@property (nonatomic, readwrite) ChouChouDebug debugLevel;


//@property (nonatomic, strong) ChouChouUrlConnection *connectionActive;
@property (nonatomic, strong) ChouChouOfflineManager* offlineDataManager;
@property (nonatomic, strong) Reachability *reachability;


- (void) setupReachabilityNotification;
- (void) handleNetworkChange: (NSNotification *) notice;

@end

@implementation ChouChouKit

#pragma mark - Prefs setter
-(void)setIDMobile:(NSString*)mobile{
    self.idMobile = mobile;
}

-(void)setIDDevice:(NSString*)deviceID{
    self.idDevice = [self deviceUUID];
}

-(void)setIDEmail:(NSString*)email{
    self.idEmail = email;
}

-(void)setIDApp:(NSString*)appID{
    self.idApp = appID;
}

-(void) setDebugLevelForInstance:(ChouChouDebug)debugLevel{
    self.debugLevel = debugLevel;
}

-(void) setIdKeyForInstance:(NSString *)idKey{
    self.idKey = idKey;
}

-(void) setServerUrlForInstance:(NSString *)serverUrl{
    self.serverUrl = serverUrl;
}


- (NSString*)deviceUUID{
    
    NSString *uuid = [[NSUserDefaults standardUserDefaults] objectForKey:@"IBIBOUUID"];
    
    if (uuid) {
        return uuid;
    }
    else{
        if(!uuid.length){
            CFUUIDRef theUUID = CFUUIDCreate(kCFAllocatorDefault);
            if (theUUID) {
                uuid = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, theUUID));
                CFRelease(theUUID);
            }
        }
        
        [[NSUserDefaults standardUserDefaults] setValue:uuid forKey:@"IBIBOUUID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return uuid;
    }
}



#pragma mark - Init

+(ChouChouKit*)initiateChouChou:(NSString*)key server:(NSString*)server storageType:(ChouChouStorageType)storageType debug:(ChouChouDebug)debug{
    if (!_chouInstance) {
        _chouInstance = [[ChouChouKit alloc] init];
        [_chouInstance setIdKeyForInstance:key];
        [_chouInstance setDebugLevelForInstance:debug];
        [_chouInstance setServerUrlForInstance:server];
        [_chouInstance setIDApp:@"1"];
        switch (storageType) {
            case CHOU_STORE_NO_LOCAL_STORAGE:_chouInstance.offlineDataManager =nil; break;
            case CHOU_STORE_COUCHBASE_LITE:{
                _chouInstance.offlineDataManager = [[ChouChouCBLiteManager alloc] init];
            }break;
            case CHOU_STORE_SQLITE:{
                _chouInstance.offlineDataManager = [[ChouChouSqliteManager alloc] init];
            }break;
            default:_chouInstance.offlineDataManager =nil; break;
        }
        [_chouInstance setupReachabilityNotification];
    }
    return _chouInstance;
}

+(ChouChouKit*)sharedInstance{
    return _chouInstance;
}


- (void) setupReachabilityNotification {
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleNetworkChange:)
                                                 name: kReachabilityChangedNotification object:nil];
    self.reachability = [Reachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
}

- (void) handleNetworkChange: (NSNotification *) notice {
    NetworkStatus status = [self.reachability currentReachabilityStatus];
    if (!status == NotReachable) {
#pragma warning Network Not Reachable Handle Error here
        NSLog(@"Network Not reachable, handle error here");
    }
}

#pragma mark -
#pragma mark - Local Storage

-(void)locallyUpdateResourceByID:(NSString*)resourceName
                          idDict:(NSDictionary*)idDict
                      updateDict:(NSDictionary*)updateDict
                         onError:(void (^)(ChouChouError*))onError
                       onSuccess:(void (^)(id))onSuccess{
    @try {
        if(self.offlineDataManager){
            [self.offlineDataManager updateDocWithData:resourceName idDictionary:idDict withProperties:updateDict onError:^(ChouChouError* error){
                if(onError){
                    onError(error);
                }
            }onSuccess:^(NSDictionary* dataDict){
                if(onSuccess){
                    onSuccess(dataDict);
                }
            }];
        }
    }
    @catch (NSException *exception) {
        if (onError) {
            ChouChouError *exceptionError = [ChouChouError chouchouErrorWithException:exception];
            if (exceptionError) {
                onError(exceptionError);
            }
        }
    }
}

-(void)locallyBlindStoreResourceByID:(NSString*)resourceName
                              idDict:(NSDictionary*)idDict
                          updateDict:(NSDictionary*)updateDict
                        storeLocally:(BOOL)storeLocally
                            forError:(ChouChouError*)forError
                              onDone:(void (^)())onDone{
    //Store it locally if needed. Will sync it later
    if(storeLocally && self.offlineDataManager!=nil){
        @try {
            if(([forError.domain isEqualToString:kChouChouReachabilityIssueDomain]) || ([forError.domain isEqualToString:@"NSURLErrorDomain"])){
                
                [self.offlineDataManager updateDocWithData:resourceName idDictionary:idDict withProperties:updateDict onError:^(ChouChouError* error){
                    if (onDone) {
                        onDone();
                    }
                }onSuccess:^(NSDictionary* dataDict){
                    if (onDone) {
                        onDone();
                    }
                }];
            }
            
            else{
                if (onDone) {
                    onDone();
                }
            }
        }
        @catch (NSException *exception) {
            onDone();
        }
        
    }
}


-(void)getLocalDataBecauseOfNetworkErrorAndCleanUp:(ChouChouError*)networkError resourceName:(NSString*)resourceName withProperties:(NSDictionary*)propertiesDic onError:(void (^)(ChouChouError*))onError dataOffline:(void (^)(id))dataOffline
{
    if(self.offlineDataManager){
        [self.offlineDataManager getDocWithData:resourceName withProperties:propertiesDic onError:^(ChouChouError* error){
//            if(onError){
//                onError(error);
//            }
        } onSuccess:^(NSArray* dataArray){
            if(dataOffline){
                dataOffline(dataArray);
            }
//            if(onError){
//                onError(networkError);
//            }
        }];
    }
//    else{
        if(onError && networkError){
            onError(networkError);
        }
//    }
//    Clean up
//    _connectionActive = nil;
}

#pragma mark -
#pragma mark - Services Exposed

/**
 Generic Request
 This wont be available in production mode. USe it just for debugging
 **/
-(void)getResource:(NSString*)resourceName withProperties:(NSDictionary*)propertiesDic storeLocally:(BOOL)storeLocally onError:(void (^)(ChouChouError*))onError dataOffline:(void (^)(id))dataOffline dataOnline:(void (^)(id))dataOnline{
    
    @try {
        if([self.reachability currentReachabilityStatus] == NotReachable){
            ChouChouError *locError = [[ChouChouError alloc] initWithDomain:kChouChouReachabilityIssueDomain code:CHOU_ERR_RECHABILITY_NETWORK_UNAVAILABLE userInfo:@{@"message": @"No internet connectivity : Reachability"}];
            if(onError){
                onError(locError);
            }
            if(self.offlineDataManager){
                [self.offlineDataManager getDocWithData:resourceName withProperties:propertiesDic onError:^(ChouChouError* error){
                    if(onError){
                        onError(error);
                    }
                } onSuccess:^(NSArray* dataArray){
                    if(dataOffline){
                        dataOffline(dataArray);
                    }
                }];
            }
        } else{
            if(!resourceName.length){
                ChouChouError *locError = [[ChouChouError alloc] initWithDomain:@"Params" code:CHOU_ERR_PARAMS_INSUFFICIENT_DATA userInfo:@{@"message": @"Resource name is required"}];
                if (onError) {
                    onError(locError);
                }
                return;
            }
//            if(_connectionActive){
//                [_connectionActive cancelActiveConnection];
//            }
            
           __block ChouChouUrlConnection  *urlConn = [[ChouChouUrlConnection alloc] init];
            [urlConn startAsyncConnection:resourceName connectionType:CHOU_CONN_GET getDic:propertiesDic postDic:nil autoConvertJson:YES onDidntStart:^(ChouChouError *error){
                if(onError){
                    onError(error);
                }
                urlConn = nil;
            } errorBlock:^(NSError *error) {
                if(onError){
                    onError([ChouChouError chouchouErrorWithNetworkError:error]);
                }
            } onUrlResponseError:^(NSHTTPURLResponse *response) {
                if(onError){
                    onError([ChouChouError chouchouErrorWithUrlResponse:response]);
                }
            } onJsonIssue:^(ChouChouError *error){
                if(onError){
                    onError(error);
                }
            } onSuccessFinish:^(id data) {
                if (dataOnline) {
                    dataOnline (data);
                }
                //I dont care much about store locally. If it doesnt happen, let it be that way - Sourabh
                if(storeLocally){
                    if(self.offlineDataManager && data){
                        if([data isKindOfClass:[NSArray class]]){
                            for(NSDictionary *dict in (NSArray*) data){
                                [self.offlineDataManager updateDocWithData:resourceName idDictionary:propertiesDic withProperties:dict onError:^(ChouChouError* error){
                                    //onError(error);
                                }onSuccess:^(NSDictionary* dataDict){
                                    // Data is already returned, this call was only to update existing docs with array
                                }];
                            }
                        }else if ([data isKindOfClass:[NSDictionary class]]){
                            [self.offlineDataManager updateDocWithData:resourceName idDictionary:propertiesDic withProperties:propertiesDic onError:^(ChouChouError* error){
                                //onError(error);
                            }onSuccess:^(NSDictionary* dataDict){
                                // Data is already returned, this call was only to update existing docs with array
                            }];
                        }
                    }
                }
            }];
        }
    }
    @catch (NSException *exception) {
        if (onError) {
            ChouChouError *exceptionError = [ChouChouError chouchouErrorWithException:exception];
            if (exceptionError) {
                onError(exceptionError);
            }
        }
    }
}

/**
 Method: getResource
 Usage: Exposed Method
 **/

-(void)getResourceByID:(NSString*)resourceName withProperties:(NSDictionary*)propertiesDic
          storeLocally:(BOOL)storeLocally onError:(void (^)(ChouChouError*))onError           dataOffline:(void (^)(id))dataOffline dataOnline:(void (^)(id))dataOnline{
    @try {
        //Validate request
        if(!resourceName.length || ![resourceName isKindOfClass:[NSString class]]){
            ChouChouError *locError = [[ChouChouError alloc] initWithDomain:@"Params" code:CHOU_ERR_PARAMS_INSUFFICIENT_DATA userInfo:@{@"message": @"Resource name required"}];
            if (onError) {
                onError(locError);
            }
            return;
        }
        
        if(![propertiesDic isKindOfClass:[NSDictionary class]] || ![[propertiesDic allKeys] count]){
            ChouChouError *locError = [[ChouChouError alloc] initWithDomain:@"Params" code:CHOU_ERR_PARAMS_INSUFFICIENT_DATA userInfo:@{@"message": @"Get dict keys not present"}];
            if (onError) {
                onError(locError);
            }
            return;
        }
        
        if([self.reachability currentReachabilityStatus] == NotReachable){
            ChouChouError *locError = [[ChouChouError alloc] initWithDomain:kChouChouReachabilityIssueDomain code:CHOU_ERR_RECHABILITY_NETWORK_UNAVAILABLE userInfo:@{@"message": @"No internet connectivity : Reachability"}];
            [self getLocalDataBecauseOfNetworkErrorAndCleanUp:locError resourceName:resourceName withProperties:propertiesDic onError:onError dataOffline:dataOffline];
            return;
        }
        
        // Call GET request
//        if(_connectionActive){
//            [_connectionActive cancelActiveConnection];
//        }
        __block ChouChouUrlConnection  *urlConn = [[ChouChouUrlConnection alloc] init];
        [urlConn startAsyncConnection:resourceName connectionType:CHOU_CONN_GET getDic:propertiesDic postDic:nil autoConvertJson:YES onDidntStart:^(ChouChouError *error){
            [self getLocalDataBecauseOfNetworkErrorAndCleanUp:error resourceName:resourceName withProperties:propertiesDic onError:onError dataOffline:dataOffline];
        } errorBlock:^(NSError *networkError) {
            [self getLocalDataBecauseOfNetworkErrorAndCleanUp:[ChouChouError chouchouErrorWithNetworkError:networkError] resourceName:resourceName withProperties:propertiesDic onError:onError dataOffline:dataOffline];
        } onUrlResponseError:^(NSHTTPURLResponse *response) {
            ChouChouError *urlRespError = [ChouChouError chouchouErrorWithUrlResponse:response];
            [self getLocalDataBecauseOfNetworkErrorAndCleanUp:urlRespError resourceName:resourceName withProperties:propertiesDic onError:onError dataOffline:dataOffline];
        } onJsonIssue:^(ChouChouError *jsonError){
            [self getLocalDataBecauseOfNetworkErrorAndCleanUp:jsonError resourceName:resourceName withProperties:propertiesDic onError:onError dataOffline:dataOffline];
        } onSuccessFinish:^(id data) {
            if(storeLocally){
                if([data isKindOfClass:[NSArray class]]){
                    for(NSDictionary*dict in (NSArray*)data){
                        if(self.offlineDataManager){
                            [self.offlineDataManager updateDocWithData:resourceName idDictionary:propertiesDic withProperties:dict onError:^(ChouChouError* error){
//                                if(onError){
//                                    onError(error);
//                                }
                            }onSuccess:^(NSDictionary* dataDict){
                                if(dataOffline){
                                    dataOffline(dataDict);
                                }
                            }];
                        }
                    }
                }else if ([data isKindOfClass:[NSDictionary class]]){
                    if(self.offlineDataManager){
                        [self.offlineDataManager updateDocWithData:resourceName idDictionary:propertiesDic withProperties:(NSDictionary*)data onError:^(ChouChouError* error){
//                            if(onError){
//                                onError(error);
//                            }
                        }onSuccess:^(NSDictionary* dataDict){
                            if(dataOffline){
                                dataOffline(dataDict);
                            }
                        }];
                    }
                }
            }
            dataOnline (data);
        }];
    }
    @catch (NSException *exception) {
        if (onError) {
            ChouChouError *exceptionError = [ChouChouError chouchouErrorWithException:exception];
            if (exceptionError) {
                onError(exceptionError);
            }
        }
    }
}

-(void)deleteResourceByID:(NSDictionary*)propertiesDic resourceName:(NSString*)resourceName onError:(void (^)(ChouChouError*))onError onSuccess:(void (^)(BOOL))onSuccess{
    
    @try {
        //Data validation first
        if(!resourceName.length){
            ChouChouError *locError = [[ChouChouError alloc] initWithDomain:@"Params" code:CHOU_ERR_PARAMS_INSUFFICIENT_DATA userInfo:@{@"message": @"Insufficient data for operation"}];
            if(onError){
                onError(locError);
            }
            return;
        }
        
        //Check rechability
        if([self.reachability currentReachabilityStatus] == NotReachable){
            ChouChouError *locError = [[ChouChouError alloc] initWithDomain:kChouChouReachabilityIssueDomain code:CHOU_ERR_RECHABILITY_NETWORK_UNAVAILABLE userInfo:@{@"message": @"No internet connectivity : Reachability"}];
            if(onError){
                onError(locError);
            }
            return;
        }
        
        //Cancel any active connection. Only one request is supported at a time
//        if(_connectionActive){
//            [ChouChouLogger logEvent:@"Cancelling active connection" params:nil debug:CHOU_DEBUG_FULL];
//            [_connectionActive cancelActiveConnection];
//        }
        
        //Finally make the request
        __block ChouChouUrlConnection  *urlConn = [[ChouChouUrlConnection alloc] init];
        [urlConn startAsyncConnection:resourceName connectionType:CHOU_CONN_DELETE getDic:propertiesDic postDic:nil autoConvertJson:YES onDidntStart:^(ChouChouError *error){
            if(onError){
                onError(error);
            }
            urlConn = nil;
        } errorBlock:^(NSError *error) {
            if(onError){
                onError([ChouChouError chouchouErrorWithNetworkError:error]);
            }
        } onUrlResponseError:^(NSHTTPURLResponse *response) {
            if(onError){
                ChouChouError *urlRespError = [ChouChouError chouchouErrorWithUrlResponse:response];
                onError(urlRespError);
            }
        } onJsonIssue:^(ChouChouError *error){
            if(onError){
                onError(error);
            }
        } onSuccessFinish:^(id data) {
            //If we are getting 200 response it means everything went well and we can blindly assume that data was deleted from server. Delete it from local database too without any check.
            if(self.offlineDataManager){
                [self.offlineDataManager deleteDocWithIdentifier:resourceName idDictionary:propertiesDic onError:^(ChouChouError* error){
                    if (onError) {
                        onError(error);
                    }
                }onSuccess:^(BOOL success){
                    if(onSuccess){
                        onSuccess(success);
                    }
                }];
            }
        }];
    }
    @catch (NSException *exception) {
        if (onError) {
            ChouChouError *exceptionError = [ChouChouError chouchouErrorWithException:exception];
            if (exceptionError) {
                onError(exceptionError);
            }
        }
    }
}

-(void) submitResourceWithType:(NSString *)resourceName withProperties:(NSDictionary *)propertiesDic getIDDic:(NSDictionary*)getIDDic storeLocally:(BOOL)storeLocally onError:(void (^)(ChouChouError *))onError onSuccess:(void (^)(id))onSuccess{
    
    @try {
        //Checks: 1. Insufficient data for get service. Get service should return single object
        if (![[getIDDic allKeys] count]) {
            if (onError) {
                ChouChouError *err = [ChouChouError chouchouErrorWithDomain:@"InsufficientData" code:CHOU_ERR_PARAMS_INSUFFICIENT_DATA userInfo:@{@"message": @"Unique ID is required to sync in submit call"}];
                onError(err);
            }
            return;
        }
        
        //Checks: 2. Properties for posting
        if (![[propertiesDic allKeys] count]) {
            if (onError) {
                ChouChouError *err = [ChouChouError chouchouErrorWithDomain:@"InsufficientData" code:CHOU_ERR_PARAMS_INSUFFICIENT_DATA userInfo:@{@"message": @"Properties dictionary is reuiqred for post in submit call"}];
                onError(err);
            }
            return;
        }
        
        [self getResourceByID:resourceName withProperties:getIDDic storeLocally:storeLocally onError:^(ChouChouError *error) {
            // Server error
            if (onError) {
                [self postResource:resourceName postDic:propertiesDic storeLocally:storeLocally onError:^(ChouChouError *error) {
                    if(onError){
                        [self locallyBlindStoreResourceByID:resourceName idDict:getIDDic updateDict:propertiesDic storeLocally:storeLocally forError:error onDone:^{
                            onError(error);
                        }];
                    }
                } onSuccess:^(NSDictionary *onlineData) {
                    if(onSuccess){
                        onSuccess(onlineData);
                    }
                }];
            }
            
        } dataOffline:^(NSDictionary*offlineData) {
            // We dont need offline data
        } dataOnline:^(NSDictionary*onlineData) {
            //Resource found in server. Place put request to update it. Since its 200 response, Data exists in server.
            if([onlineData isKindOfClass:[NSArray class]]){
                NSDictionary *newOnlineData = [NSDictionary dictionaryWithDictionary:[(NSArray*)onlineData objectAtIndex:0]];
                onlineData = newOnlineData;
            }
            [self putResourceByID:@"id" resourceName:resourceName postDic:propertiesDic getIDDic:getIDDic storeLocally:storeLocally onError:^(ChouChouError *error) {
                [self locallyBlindStoreResourceByID:resourceName idDict:getIDDic updateDict:propertiesDic storeLocally:storeLocally forError:error onDone:^{
                    if(onError){
                        onError(error);
                    }
                }];
            } onSuccess:^(NSDictionary *onlineData) {
                if(onSuccess){
                    onSuccess(onlineData);
                }
            }];
        }];
    }
    @catch (NSException *exception) {
        if (onError) {
            ChouChouError *exceptionError = [ChouChouError chouchouErrorWithException:exception];
            if (exceptionError) {
                onError(exceptionError);
            }
        }
    }
}

#pragma mark - Services Internal
//Internal services are called by other SDK services.

/**
 Method: postResource
 Usage: Internal by SDK by submitResource(). Not to be exposed
 **/

-(void)postResource:(NSString*)resourceName postDic:(NSDictionary*)postDic storeLocally:(BOOL)storeLocally onError:(void (^)(ChouChouError*))onError onSuccess:(void (^)(id))onSuccess{
    
    @try {
        //Validate request
        if(!resourceName.length){
            ChouChouError *locError = [[ChouChouError alloc] initWithDomain:@"Params" code:CHOU_ERR_PARAMS_INSUFFICIENT_DATA userInfo:@{@"message": @"Resource name required"}];
            if (onError) {
                onError(locError);
            }
            return;
        }
        
        if(![[postDic allKeys] count]){
            ChouChouError *locError = [[ChouChouError alloc] initWithDomain:@"Params" code:CHOU_ERR_PARAMS_INSUFFICIENT_DATA userInfo:@{@"message": @"postDic keys not present"}];
            if (onError) {
                onError(locError);
            }
            return;
        }
        
        //Check internet
        if([self.reachability currentReachabilityStatus] == NotReachable){
            if (onError) {
                ChouChouError *locError = [[ChouChouError alloc] initWithDomain:kChouChouReachabilityIssueDomain code:CHOU_ERR_RECHABILITY_NETWORK_UNAVAILABLE userInfo:@{@"message": @"No internet connectivity : Reachability"}];
                onError((ChouChouError*)locError);
            }
            return;
        }
        
        //Cancel any other connection
//        if(_connectionActive){
//            [_connectionActive cancelActiveConnection];
//        }
//
        
        //Now make request
        
        __block ChouChouUrlConnection  *urlConn = [[ChouChouUrlConnection alloc] init];
        [urlConn startAsyncConnection:resourceName connectionType:CHOU_CONN_POST getDic:nil postDic:postDic autoConvertJson:YES onDidntStart:^(ChouChouError *error){
            onError(error);
            urlConn = nil;
        } errorBlock:^(NSError *error) {
            onError([ChouChouError chouchouErrorWithNetworkError:error]);
        } onUrlResponseError:^(NSHTTPURLResponse *response) {
            ChouChouError *urlRespError = [ChouChouError chouchouErrorWithUrlResponse:response];
            onError(urlRespError);
        } onJsonIssue:^(ChouChouError *error){
            onError(error);
        } onSuccessFinish:^(id data) {
            if(!storeLocally){
                if (onSuccess) {
                    onSuccess(data);
                }
            }else{
                if (onSuccess) {
                    onSuccess(data);
                }
                if(self.offlineDataManager){
                    [self.offlineDataManager createDocWithData:resourceName withProperties:postDic onError:^(ChouChouError* postError){
                        if(onError){
                            onError(postError);
                        }
                    } onSuccess:^(NSDictionary* postedData){
                        if (onSuccess) {
                            onSuccess(postedData);
                        }
                    }];
                }
            }
        }];
    }
    @catch (NSException *exception) {
        if (onError) {
            ChouChouError *exceptionError = [ChouChouError chouchouErrorWithException:exception];
            if (exceptionError) {
                onError(exceptionError);
            }
        }
    }
}


/**
 Method: putResource
 Usage: Internal by SDK by submitResource(). Not to be exposed
 **/

-(void)putResourceByID:(NSString*)identifierType resourceName:(NSString*)resourceName postDic:(NSDictionary*)postDic getIDDic:(NSDictionary*)getIDDic storeLocally:(BOOL)storeLocally onError:(void (^)(ChouChouError*))onError onSuccess:(void (^)(id))onSuccess{
    
    @try {
        //No need to verify postDic & getIDDic because its verified by submit() which is calling this method
        
        //Validate request
        if(!resourceName.length){
            ChouChouError *locError = [[ChouChouError alloc] initWithDomain:@"Params" code:CHOU_ERR_PARAMS_INSUFFICIENT_DATA userInfo:@{@"message": @"Resource name required"}];
            if (onError) {
                onError(locError);
            }
            return;
        }
        
        if(![[postDic allKeys] count]){
            ChouChouError *locError = [[ChouChouError alloc] initWithDomain:@"Params" code:CHOU_ERR_PARAMS_INSUFFICIENT_DATA userInfo:@{@"message": @"postDic keys not present"}];
            if (onError) {
                onError(locError);
            }
            return;
        }
        if([self.reachability currentReachabilityStatus] == NotReachable){
            ChouChouError *locError = [[ChouChouError alloc] initWithDomain:kChouChouReachabilityIssueDomain code:CHOU_ERR_RECHABILITY_NETWORK_UNAVAILABLE userInfo:@{@"message": @"No internet connectivity : Reachability"}];
            if (onError) {
                onError(locError);
            }
//            _connectionActive = nil;
            return;
        }
        
        //Cancel active connection
//        if(_connectionActive){
//            [_connectionActive cancelActiveConnection];
//        }
       
        //Make the request finally
        NSDictionary* identifierDict = @{@"identifier": identifierType};
        __block ChouChouUrlConnection  *urlConn = [[ChouChouUrlConnection alloc] init];
        [urlConn startAsyncConnection:resourceName connectionType:CHOU_CONN_PUT getDic:identifierDict postDic:postDic autoConvertJson:YES onDidntStart:^(ChouChouError *error){
            [self locallyBlindStoreResourceByID:resourceName idDict:getIDDic updateDict:postDic storeLocally:storeLocally forError:error onDone:^{
                onError(error);
            }];
            urlConn = nil;
        } errorBlock:^(NSError *error) {
            ChouChouError *ccError = [ChouChouError chouchouErrorWithNetworkError:error];
            [self locallyBlindStoreResourceByID:resourceName idDict:getIDDic updateDict:postDic storeLocally:storeLocally forError:ccError onDone:^{
                onError(ccError);
            }];
            urlConn = nil;
        } onUrlResponseError:^(NSHTTPURLResponse *response) {
            ChouChouError *ccError = [ChouChouError chouchouErrorWithUrlResponse:response];
            [self locallyBlindStoreResourceByID:resourceName idDict:getIDDic updateDict:postDic storeLocally:storeLocally forError:ccError onDone:^{
                onError(ccError);
            }];
            urlConn = nil;
        } onJsonIssue:^(ChouChouError *error){
            [self locallyBlindStoreResourceByID:resourceName idDict:getIDDic updateDict:postDic storeLocally:storeLocally forError:error onDone:^{
                onError(error);
            }];
            urlConn = nil;
        } onSuccessFinish:^(id data) {
            if (onSuccess) {
                onSuccess(data);
            }
            [self locallyBlindStoreResourceByID:resourceName idDict:getIDDic updateDict:postDic storeLocally:storeLocally forError:nil onDone:nil];
            urlConn = nil;
        }];
    }
    @catch (NSException *exception) {
        if (onError) {
            ChouChouError *exceptionError = [ChouChouError chouchouErrorWithException:exception];
            if (exceptionError) {
                onError(exceptionError);
            }
        }
    }
}

-(void) deleteAllLocalResourcesOfType:(NSString *)resourceName{
    [[self offlineDataManager] deleteAllLocalResourcesOfType:resourceName];
}

@end


