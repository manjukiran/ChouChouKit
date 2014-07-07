//
//  ChouChouUrlConnection.h
//  ChouChouKit
//
//  Created by Sourabh Verma on 08/05/14.
//  Copyright (c) 2014 ibibo Web Pvt. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChouChouKit.h"

typedef enum ChouConnectionType{
    CHOU_CONN_POST,
    CHOU_CONN_GET,
    CHOU_CONN_DELETE,
    CHOU_CONN_PUT
}ChouConnectionType;

@interface ChouChouUrlConnection : NSObject

-(NSURLConnection*)startAsyncConnection:(NSString*)resourceName connectionType:(ChouConnectionType)connectionType getDic:(NSDictionary*)getDictionary postDic:(NSDictionary*)postDictionary autoConvertJson:(BOOL)convertJson onDidntStart:(void (^)(ChouChouError*))onDidntStart errorBlock:(void (^)(NSError*))errorBlock onUrlResponseError:(void (^)(NSHTTPURLResponse*))onUrlResponseError onJsonIssue:(void (^)(ChouChouError*))onJsonIssue onSuccessFinish:(void (^)(id))onSuccessFinish;

-(void)cancelActiveConnection;


@property (nonatomic, readwrite) ChouConnectionType postMethod;
@property (nonatomic, strong) NSURLConnection *connectionRef;
@end
