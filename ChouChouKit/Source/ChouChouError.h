//
//  ChouChouError.h
//  ChouChouKit
//
//  Created by Manju Kiran on 29/05/14.
//  Copyright (c) 2014 goIbibo. All rights reserved.
//

#import <Foundation/Foundation.h>

//Network Issues 10000 - 10999
//Local Storage Issue 11000- 11999
//Params Error 12000- 12999

typedef enum ChouChouErrorCode{
    CHOU_ERR_RECHABILITY_NETWORK_GENERIC = 10000,
    CHOU_ERR_RECHABILITY_NETWORK_UNAVAILABLE = 10001,
    CHOU_ERR_RECHABILITY_HOST_UNAVAILABLE = 10002,
    
    CHOU_ERR_NETWORK_GENERIC = 10500,
    CHOU_ERR_NETWORK_URLRESPONSE = 10501,
    CHOU_ERR_CONN_UNABLE_TO_START = 10502,
    CHOU_ERR_CONNECTION = 10503,
    CHOU_ERR_JSON_NOT_FOUND = 10504,
    CHOU_ERR_JSON_EMPTY = 10505,
    CHOU_ERR_JSON_EXCEPTION_SERIALIZATION = 10506,
    CHOU_REACHABILITY_ISSUE = 10507,
    
    CHOU_ERR_LOCAL_GENERIC = 11000,
    CHOU_LOCAL_STORAGE_UNAVAILABLE = 11001,
    CHOU_LOCAL_WRITING_FAILURE = 11002,
    CHOU_LOCAL_DATA_UNAVAILABLE = 11003,
    
    CHOU_ERR_PARAMS_GENERIC  = 12000,
    CHOU_ERR_PARAMS_INSUFFICIENT_DATA  = 12001,
    
    CHOU_ERR_TRY_CATCH_GENERIC = 13000
}ChouChouErrorCode;


@interface ChouChouError : NSError
@property (nonatomic, strong) NSException *exceptionDetail;
@property (nonatomic, strong) NSError *errorDetail;
@property (nonatomic, strong) NSHTTPURLResponse *urlResponse;
+ (ChouChouError*)chouchouErrorWithDomain:(NSString *)domain code:(ChouChouErrorCode)code userInfo:(NSDictionary *)dict;
+ (ChouChouError*)chouchouErrorWithNetworkError:(NSError*)networkError;
+ (ChouChouError*)chouchouErrorWithUrlResponse:(NSHTTPURLResponse*)urlResponse;
+ (ChouChouError*)chouchouErrorWithCouchBaseError:(NSError*)couchbaseError;
+ (ChouChouError*)chouchouErrorWithException:(NSException*)exception;
+ (ChouChouError*) chouchouErrorForNoResourceName;
+ (ChouChouError*) chouchouErrorForInsufficientParams;

@end
