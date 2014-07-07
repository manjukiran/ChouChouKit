//
//  ChouChouError.m
//  ChouChouKit
//
//  Created by Sourabh Verma on 29/05/14.
//  Copyright (c) 2014 ibibo Web Pvt. Ltd. All rights reserved.
//

#import "ChouChouError.h"

@implementation ChouChouError

+ (ChouChouError*)chouchouErrorWithDomain:(NSString *)domain code:(ChouChouErrorCode)code userInfo:(NSDictionary *)dict{
    ChouChouError *err = [[ChouChouError alloc] initWithDomain:domain code:code userInfo:dict];
    return err;
}

+ (ChouChouError*)chouchouErrorWithNetworkError:(NSError*)networkError{
    ChouChouError *error = [ChouChouError errorWithDomain:[networkError domain] code:CHOU_ERR_RECHABILITY_NETWORK_GENERIC userInfo:[networkError userInfo]];
    error.errorDetail = networkError;
    return error;
}

+ (ChouChouError*)chouchouErrorWithUrlResponse:(NSHTTPURLResponse*)urlResponse{
    ChouChouError *error = [ChouChouError errorWithDomain:@"NSHTTPURLResponse" code:CHOU_ERR_NETWORK_URLRESPONSE userInfo:urlResponse.allHeaderFields];
    error.urlResponse = urlResponse;
    return error;
}

+ (ChouChouError*)chouchouErrorWithException:(NSException*)exception{
    ChouChouError *error = [ChouChouError errorWithDomain:@"NSException" code:CHOU_ERR_TRY_CATCH_GENERIC userInfo:[exception userInfo]];
    error.exceptionDetail = exception;
    return error;
}

+ (ChouChouError*)chouchouErrorWithCouchBaseError:(NSError*)couchbaseError{
    ChouChouError *error = [ChouChouError errorWithDomain:[couchbaseError domain] code:CHOU_ERR_LOCAL_GENERIC userInfo:[couchbaseError userInfo]];
    error.errorDetail = couchbaseError;
    return error;
}

+(ChouChouError*) chouchouErrorForNoResourceName {
    ChouChouError *locError = [[ChouChouError alloc] initWithDomain:@"IncompleteImplementaion" code:CHOU_ERR_PARAMS_INSUFFICIENT_DATA userInfo:@{@"message": @"Resource name aka docname is not set in derived class"}];
    return locError;
}

+(ChouChouError*) chouchouErrorForInsufficientParams {
    ChouChouError *locError = [[ChouChouError alloc] initWithDomain:@"InsufficientParams" code:CHOU_ERR_PARAMS_INSUFFICIENT_DATA userInfo:@{@"message": @"Insufficient Params"}];
    return locError;
}

-(NSString*)errorDescShort{
    switch (self.code) {
        case CHOU_ERR_PARAMS_INSUFFICIENT_DATA: return @"CHOU_INSUFFICIENT_DATA";
        case CHOU_REACHABILITY_ISSUE: return @"CHOU_REACHABILITY_ISSUE";
        case CHOU_ERR_NETWORK_URLRESPONSE: return @"CHOU_ERR_URLRESPONSE";
        case CHOU_ERR_CONN_UNABLE_TO_START: return @"CHOU_ERR_CONN_UNABLE_TO_START";
        case CHOU_ERR_CONNECTION: return @"CHOU_ERR_CONNECTION";
        case CHOU_ERR_JSON_EMPTY: return @"CHOU_ERR_JSON_EMPTY";
        case CHOU_LOCAL_STORAGE_UNAVAILABLE: return @"CHOU_LOCAL_STORAGE_UNAVAILABLE";
        case CHOU_LOCAL_WRITING_FAILURE: return @"CHOU_LOCAL_WRITING_FAILURE";
        case CHOU_LOCAL_DATA_UNAVAILABLE: return @"CHOU_LOCAL_DATA_UNAVAILABLE";
        default: return @"Unknown Error";
    }
}

-(NSString*)userDislayErrorMsg{
    if (_exceptionDetail) {
        if (_exceptionDetail.description) {
            return _exceptionDetail.description;
        }
        else if (_exceptionDetail.name) {
            return _exceptionDetail.name;
        }
        else {
            return @"Unknown exception";
        }
    }
    else if(_errorDetail){
        return [_errorDetail localizedDescription];
    }
    else if(_urlResponse){
        return [NSHTTPURLResponse localizedStringForStatusCode:_urlResponse.statusCode];
    }
    else{
        switch (self.code) {
            case CHOU_ERR_PARAMS_INSUFFICIENT_DATA: return @"Format Error";
            case CHOU_REACHABILITY_ISSUE: return @"Network unreachable, please try again";
            case CHOU_ERR_NETWORK_URLRESPONSE: return [self localizedDescription];
            case CHOU_ERR_CONN_UNABLE_TO_START: return @"Unable to establish connection";
            case CHOU_ERR_CONNECTION: return @"Error while connecting";
            case CHOU_ERR_JSON_EMPTY: return @"Invalid server response";
            case CHOU_LOCAL_STORAGE_UNAVAILABLE: return @"Local Error: LSU";
            case CHOU_LOCAL_WRITING_FAILURE: return @"Local Error: LWF";
            case CHOU_LOCAL_DATA_UNAVAILABLE: return @"Local Error: LDU";
            default: return @"Unknown Error while processing your request";
        }
    }
}

@end

