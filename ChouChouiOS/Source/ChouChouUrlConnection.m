//
//  ChouChouUrlConnection.m
//  ChouChouLite_iOS
//
//  Created by Sourabh Verma on 08/05/14.
//  Copyright (c) 2014 ibibo group pvt ltd (http://www.goibibo.com/ && http://www.ibibo.com/). All rights reserved.
//

#import "ChouChouUrlConnection.h"
#import "ChouChouKitPrivate.h"
#import "ChouChouKit.h"
#import "ChouChou+NSDictionary.h"
#import "ChouChouLogger.h"
#import "ChouChouError.h"

@interface ChouChouUrlConnection() <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    //Data
    NSMutableData *connectionData;
    NSError *connectionError;
    NSURLResponse *connectionResponse;
    
    //Preferences
    BOOL autoConvertJson;
    
    BOOL hadError;
    BOOL invalidURLResponse;
}

//Blocks
@property (nonatomic, copy) void (^urlResponseError)(NSHTTPURLResponse*);
@property (nonatomic, copy) void (^finishedBlock)(id);

@property (nonatomic, copy) void (^jsonValidationIssue)(ChouChouError*);
@property (nonatomic, copy) void (^errorBlock)(NSError*);

@end

@implementation ChouChouUrlConnection

#pragma mark - Create connection

-(void)hideActivityIndicators{
    //
}


-(NSURLConnection*)startAsyncConnection:(NSString*)resourceName connectionType:(ChouConnectionType)connectionType getDic:(NSDictionary*)getDictionary postDic:(NSDictionary*)postDictionary autoConvertJson:(BOOL)convertJson onDidntStart:(void (^)(ChouChouError*))onDidntStart errorBlock:(void (^)(NSError*))errorBlock onUrlResponseError:(void (^)(NSHTTPURLResponse*))onUrlResponseError onJsonIssue:(void (^)(ChouChouError*))onJsonIssue onSuccessFinish:(void (^)(id))onSuccessFinish{
    
    //Bring header forward
    
    //Save preferences
    self.urlResponseError = onUrlResponseError;
    self.finishedBlock = onSuccessFinish;
    self.jsonValidationIssue = onJsonIssue;
    self.errorBlock = errorBlock;
    autoConvertJson = convertJson;
    self.postMethod =  connectionType;
    //    vc = viewController;
    
    //Place server
    
    
    NSString *formattedUrl = [[ChouChouKit sharedInstance].serverUrl stringByAppendingFormat:@"/%@", resourceName];
    
    //Configure get params
    if(getDictionary){
        //No need of slash here for chou chou
        formattedUrl = [formattedUrl stringByAppendingFormat:@"?%@", [getDictionary postStringForNetwork]];
    }
    
    //Start connection
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:formattedUrl]];
    
    
    switch (_postMethod) {
        case CHOU_CONN_GET:     [urlRequest setHTTPMethod:@"GET"];      break;
        case CHOU_CONN_DELETE:  [urlRequest setHTTPMethod:@"DELETE"];   break;
        case CHOU_CONN_POST:    [urlRequest setHTTPMethod:@"POST"];     break;
        case CHOU_CONN_PUT:     [urlRequest setHTTPMethod:@"PUT"];      break;
        default:    break;
    }
    
    if(_postMethod == CHOU_CONN_PUT){
        NSLog(@"PUT Method : \nURL %@  \nPut Dictionary%@",formattedUrl,postDictionary);
    }
    
    //Set header Dic
    @try {
        [urlRequest setValue:[ChouChouKit sharedInstance].idApp forHTTPHeaderField:@"appid"];
        [urlRequest setValue:[ChouChouKit sharedInstance].idKey forHTTPHeaderField:@"appkey"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    @catch (NSException *exception) {
        [ChouChouLogger logException:exception method:[NSString stringWithFormat:@"%s", __func__] class:NSStringFromClass([self class])];
    }
    @finally {
        //
    }
    
    if(postDictionary){
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postDictionary
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        NSString *postString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [urlRequest setHTTPBody:[postString  dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    self.connectionRef = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    if(_connectionRef){
        [_connectionRef start];
    }
    else{
        [self hideActivityIndicators];
        hadError = YES;
        
        if(onDidntStart){
            ChouChouError *error = [ChouChouError errorWithDomain:@"Network" code:CHOU_ERR_CONN_UNABLE_TO_START userInfo:@{@"message": @"Unable to start connection"}];
            onDidntStart(error);
        }
    }
    
    return _connectionRef;
}

#pragma mark - NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [self hideActivityIndicators];
    
    //[IBSVAnalytics logConnFailWithError:error WebServiceType:webService category:logCategory];
    connectionError = error;
    
    hadError = YES;
    if(_errorBlock){
        _errorBlock(error);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    //[IBSVAnalytics logConnRecvResponse:response WebServiceType:webService category:logCategory];
    
    // cast the response to NSHTTPURLResponse so we can look for 404 etc
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
#if DEBUG_LOGGING_ON
    NSLog(@"connection:didReceiveResponse: Status:%d %@", [httpResponse statusCode], [NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]]);
#endif
    
    if (!httpResponse) {
        invalidURLResponse = YES;
        if(_urlResponseError){
            _urlResponseError(nil);
        }
    }
    else if ([httpResponse statusCode] != 200) {
        invalidURLResponse = YES;
        if(_urlResponseError){
            _urlResponseError(httpResponse);
        }
    }
    
    connectionData = [[NSMutableData alloc] init];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [connectionData appendData:data];
}

/*
 [
 {
 "data":[
 {
 "passport":0,
 "ts":11111111
 },
 {
 "visa":0,
 "ts":11111111
 }
 ],
 "id_and":"and_123456",
 "id_email":"rithish@gmail.com",
 "id_ios":"ios_654321",
 "ts":1385115510,
 "id":"38e677eb9526aac6"
 }
 ]
 */

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [self hideActivityIndicators];
    
    //[IBSVAnalytics logConnFinished:webService category:logCategory];
    
    if(hadError){
        //[IBSVAnalytics logConnFinError:webService category:logCategory event:@"Connection Error" error:nil parameters:analyticsDic];
    }
    else if(invalidURLResponse){
        //[IBSVAnalytics logConnFinError:webService category:logCategory event:@"Url Response Error" error:nil parameters:analyticsDic];
    }
    else if(![connectionData length]){
        //[IBSVAnalytics logConnFinError:webService category:logCategory event:@"No Data" error:nil parameters:analyticsDic];
        
        if(_errorBlock){
            _errorBlock(nil);
        }
    }
    else{
        
        NSString *fullStr = [[NSString alloc] initWithData:connectionData encoding:NSUTF8StringEncoding];
        NSLog(@"connectionDidFinishLoading: %@",  fullStr);
        
        if(connectionData.length){
            if(autoConvertJson){
                @try {
                    NSError *error = nil;
                    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:connectionData options:kNilOptions error:&error];
                    
                    if (jsonData && [jsonData isKindOfClass:[NSArray class]] ) {
                        if([(NSArray*)jsonData count]>0){
                            if(_finishedBlock){
                                _finishedBlock(jsonData);
                                return;
                            }
                        }else{
                            if(_errorBlock){
                                NSError *error = [NSError errorWithDomain:@"No Data" code:CHOU_ERR_JSON_EXCEPTION_SERIALIZATION userInfo:@{@"message": @"No data from Server"}];
                                _errorBlock(error);
                            }
                        }
                        
                    }else if(jsonData && [jsonData isKindOfClass:[NSDictionary class]]){
                        if(_finishedBlock){
                            _finishedBlock(jsonData);
                            return;
                        }
                    }
                    else{
                        //[IBSVAnalytics logConnFinError:webService category:logCategory event:@"Invalid Json" error:nil parameters:analyticsDic];
                        
                        if(_jsonValidationIssue){
                            ChouChouError *error = [ChouChouError errorWithDomain:@"Json Issue" code:CHOU_ERR_JSON_NOT_FOUND userInfo:@{@"message": @"Invalid Response from Server"}];
                            _jsonValidationIssue(error);
                            return;
                        }
                    }
                }
                @catch (NSException *exception) {
                    if(_jsonValidationIssue){
                        ChouChouError *error = [ChouChouError errorWithDomain:@"Json catch exception" code:CHOU_ERR_JSON_EXCEPTION_SERIALIZATION userInfo:[exception userInfo]];
                        _jsonValidationIssue(error);
                        return;
                    }
                }
            }
            else{
                if(_finishedBlock){
                    _finishedBlock(connectionData);
                    return;
                }
            }
        }
        else{
            if(_errorBlock){
                NSError *error = [NSError errorWithDomain:@"No Data" code:CHOU_ERR_JSON_EXCEPTION_SERIALIZATION userInfo:@{@"message": @"No data from Server"}];
                _errorBlock(error);
            }
        }
    }
}

-(NSString *)fixJSON:(NSString *)s {
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:
                                   @"[{,]\\s*(\\w+)\\s*:"
                                                                            options:0
                                                                              error:NULL];
    NSMutableString *b = [NSMutableString stringWithCapacity:([s length] * 1.1)];
    __block NSUInteger offset = 0;
    [regexp enumerateMatchesInString:s
                             options:0
                               range:NSMakeRange(0, [s length])
                          usingBlock:^(NSTextCheckingResult *result,
                                       NSMatchingFlags flags, BOOL *stop)
     {
         NSRange r = [result rangeAtIndex:1];
         [b appendString:[s substringWithRange:NSMakeRange(offset,
                                                           r.location - offset)]];
         [b appendString:@"\""];
         [b appendString:[s substringWithRange:r]];
         [b appendString:@"\""];
         offset = r.location + r.length;
     }];
    [b appendString:[s substringWithRange:NSMakeRange(offset,
                                                      [s length] - offset)]];
    return b;
}

-(void)cancelActiveConnection{
    /*
    if(_connectionRef){
        [_connectionRef cancel];
        self.connectionRef = nil;
        
        //Disable all callback and alerts
        self.urlResponseError = nil;
        self.finishedBlock = nil;
        self.jsonValidationIssue = nil;
        self.errorBlock = nil;
    }
     */
}

@end
